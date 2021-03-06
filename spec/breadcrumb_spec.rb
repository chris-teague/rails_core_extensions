require 'rails_core_extensions/breadcrumb'

require 'action_view'

describe RailsCoreExtensions::Breadcrumb do
  before do
    class TestModel1
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::CaptureHelper
      attr_accessor :output_buffer
      include RailsCoreExtensions::Breadcrumb
    end
  end

  after { Object.send(:remove_const, 'TestModel1') }

  subject { TestModel1.new }
  let(:helper_context) {
    {:can_show => true, :action => action}
  }

  context '#breadcrumbs (* = link)' do
    let(:user_class) { double(:table_name => 'users', :model_name => double(:singular_route_key => 'user')) }
    let(:user) { double(:to_s => 'Alice', :new_record? => new_record, :class => user_class) }
    context 'for a new record' do
      let(:action) { 'new' }
      let(:new_record) { true }

      it 'should breadcrumb: *Users / New' do
        result = subject.breadcrumbs(user, '/users', helper_context)
        result.should be_html_safe
        result.should ==
          %q(<ul class="breadcrumb"><li><a href="/users">Users</a></li><li class="active">New</li></ul>)
      end
    end

    context 'for a existing record' do
      let(:new_record) { false }

      context 'when editing' do
        let(:action) { 'edit' }
        it 'should breadcrumb: *Users / *Alice / Edit' do
          subject.should_receive(:link_to).with('Users', '/users').and_return('<a href="/users">Users</a>'.html_safe)
          subject.should_receive(:link_to).with('Alice', user).and_return('<a href="/users/1">Alice</a>'.html_safe)
          result = subject.breadcrumbs(user, '/users', helper_context)
          result.should be_html_safe
          result.should ==
            %q(<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><a href="/users/1">Alice</a></li><li class="active">Edit</li></ul>)
        end
      end

      context 'when showing' do
        let(:action) { 'show' }
        it 'should breadcrumb: *Users / Alice' do
          result = subject.breadcrumbs(user, '/users', helper_context)
          result.should be_html_safe
          result.should ==
            %q(<ul class="breadcrumb"><li><a href="/users">Users</a></li><li>Alice</li></ul>)
        end
      end
    end
  end
end
