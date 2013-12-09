require 'spec_helper_without_rails'

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/access'

require 'rails_info/logs'
require 'rails_info/logs/test'
require 'rails_info/logs/test/rspec'

describe RailsInfo::Logs::Test::Rspec do
  describe '#process' do
    context 'failing method expactations' do
      it 'principally works' do
        body = "
          Failures:
          1) NotificationRules user stream should notify subscribers about reactions
           Failure/Error: expect { Reaction.make! }.to notify(:feedback => :subscribers).about(Reaction, :created).via(:user_stream)
             expected #<Proc:0x007ff75134a6c0@/Users/mgawlista/workspace/reqorder2_copy/spec/notifications/notification_spec.rb:72> to notify feedback subscribers about Reaction created via user_stream, but it didn't:{:class=>Reaction(id: integer, content: text, feedback_id: integer, user_id: integer, created_at: datetime, updated_at: datetime, deleted: boolean, hidden_by_id: integer, hidden_at: datetime, reason_for_hiding: string, likes_count: integer, official: boolean, mood_content: string, mood_type: integer, photo_file_name: string, photo_content_type: string, photo_file_size: integer, photo_updated_at: datetime, editable: boolean, official_by: integer, slug: string, editor_id: integer, reason_for_editing: text, edited_at: datetime, internal_state: string, trigger_object_created_or_internal_state_changed_at: datetime), :role=>[:feedback, :subscribers], :event_method=>:created, :options=>{:via=>:user_stream}} not found in []
           # ./spec/notifications/notification_spec.rb:72:in `block (3 levels) in <top (required)>'
           Finished in 1.00 second
           1 example, 1 failure, 0 pending
        "
        @rails_info_log = ::RailsInfo::Logs::Test::Rspec.new(log: { body: body })
        @rails_info_log.hash.should == {
          './spec/notifications/notification_spec.rb' => {
            'NotificationRules user stream should notify subscribers about reactions' => 
            {
              failure_code: 'Failure/Error: expect { Reaction.make! }.to notify(:feedback => :subscribers).about(Reaction, :created).via(:user_stream)', 
              exception_class: '', 
              exception_message: "expected #<Proc:0x007ff75134a6c0@/Users/mgawlista/workspace/reqorder2_copy/spec/notifications/notification_spec.rb:72> to notify feedback subscribers about Reaction created via user_stream, but it didn't:{:class=>Reaction(id: integer, content: text, feedback_id: integer, user_id: integer, created_at: datetime, updated_at: datetime, deleted: boolean, hidden_by_id: integer, hidden_at: datetime, reason_for_hiding: string, likes_count: integer, official: boolean, mood_content: string, mood_type: integer, photo_file_name: string, photo_content_type: string, photo_file_size: integer, photo_updated_at: datetime, editable: boolean, official_by: integer, slug: string, editor_id: integer, reason_for_editing: text, edited_at: datetime, internal_state: string, trigger_object_created_or_internal_state_changed_at: datetime), :role=>[:feedback, :subscribers], :event_method=>:created, :options=>{:via=>:user_stream}} not found in []", 
              stack_trace: "# ./spec/notifications/notification_spec.rb:72:in `block (3 levels) in <top (required)>'"
            }
          }
        }
      end
    end
  end 
end
