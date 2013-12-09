require 'spec_helper_without_rails'

require 'active_support/core_ext/object/blank'
#require 'active_support/core_ext/array/access'

require 'rails_info/logs'
require 'rails_info/logs/server'

describe RailsInfo::Logs::Server do
=begin
 Started POST \"/users/bronze\" for 127.0.0.1 at 2012-07-05 19:33:44 +0200
Creating scope :visible. Overwriting existing method Reaction.visible.
  Processing by DeviseCustomized::RegistrationsController#create as HTML
  Parameters: {\"utf8\"=>'', \"authenticity_token\"=>\"k4xMIcuqMThMsdlbsVJ7GFgzNDw/HgGGp1ldElFULoY=\", \"user\"=>{\"screen_name\"=>\"mgawlista\", \"email\"=>\"gawlista@googlemail.com\", \"password\"=>\"[FILTERED]\", \"password_confirmation\"=>\"[FILTERED]\"}, \"community_id\"=>\"bronze\"}
  [1m[35mCACHE (0.0ms)[0m  SELECT `communities`.* FROM `communities` WHERE `communities`.`deleted` = 0 AND `communities`.`slug` = 'bronze' LIMIT 1
  [1m[35mSQL (276.4ms)[0m  INSERT INTO `users` (`city`, `city_permissions`, `confirmation_sent_at`, `confirmation_token`, `confirmed_at`, `created_at`, `current_sign_in_at`, `current_sign_in_ip`, `delete_token`, `deleted`, `developer`, `email`, `encrypted_password`, `facebook`, `facebook_id`, `facebook_permissions`, `failed_attempts`, `forename`, `google_id`, `initial_community_id`, `last_sign_in_at`, `last_sign_in_ip`, `linkedin`, `linkedin_permissions`, `locked_at`, `master`, `name_permissions`, `notification_email`, `password_salt`, `phone`, `phone_permissions`, `photo_content_type`, `photo_file_name`, `photo_file_size`, `photo_updated_at`, `remember_created_at`, `reset_password_sent_at`, `reset_password_token`, `screen_name`, `screen_name_permissions`, `sign_in_count`, `slug`, `street`, `street_permissions`, `surname`, `tagline`, `tagline_permissions`, `twitter`, `twitter_permissions`, `unconfirmed_email`, `unlock_token`, `updated_at`, `url`, `website`, `website_permissions`, `xing`, `xing_permissions`, `zipcode`, `zipcode_permissions`) VALUES (NULL, 0, '2012-07-05 17:33:50', 'xVQj9z8xGm1bzqqJBjUn', NULL, '2012-07-05 17:33:50', NULL, NULL, NULL, 0, NULL, 'gawlista@googlemail.com', '$2a$10$KnrBV6m64g0zqKwUnQRR/exiUN9HtzJCGLSUse.jPTxLp0WQtNec2', NULL, NULL, 0, 0, NULL, NULL, 2, NULL, NULL, NULL, 0, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mgawlista', 0, 0, 'mgawlista', NULL, 0, NULL, NULL, 0, NULL, 0, NULL, NULL, '2012-07-05 17:33:50', NULL, NULL, 0, NULL, 0, NULL, 0)
Rendered devise/shared/_header.html.erb (70.4ms)
[paperclip] Saving attachments.
  [1m[35m (148.3ms)[0m  COMMIT
  [1m[36mCommunity Load (0.5ms)[0m  [1mSELECT `communities`.* FROM `communities` WHERE `communities`.`id` = 2 LIMIT 1[0m
Redirected to http://localhost:3000/bronze
  [1m[32mSOLR Request (45541.1ms)[0m  [ path=#<RSolr::Client:0x007fbf26dc8b28> parameters={data: [1m[1m<?xml version=\"1.0\" encoding=\"UTF-8\"?><commit/>[0m, headers: [1m[1m{\"Content-Type\"=>\"text/xml\"}[0m, method: [1m[1mpost[0m, params: [1m[1m{:wt=>:ruby}[0m, query: [1m[1mwt=ruby[0m, path: [1m[1mupdate[0m, uri: [1m[1mhttp://localhost:8982/solr/update?wt=ruby[0m} ]
Completed 302 Found in 125493ms 
=end  
  describe '#process' do
    describe '#parse_request' do
      subject {
        ::RailsInfo::Logs::Server.new(
          log: { 
            body: "Started POST \"/users/bronze\" for 127.0.0.1 at 2012-07-05 19:33:44 +0200
Processing by DeviseCustomized::RegistrationsController#create as HTML
Parameters: {\"authenticity_token\"=>\"k4xMIcuqMThMsdlbsVJ7GFgzNDw/HgGGp1ldElFULoY=\", \"user\"=>{\"screen_name\"=>\"mgawlista\"}}
            " 
          }
        )
      }
      
      it 'parses request correctly' do
        subject.hash.should == {
          'DeviseCustomized::RegistrationsController#create #1' => {
            'Request' => {
              'Route' => "POST \"/users/bronze\"",
              'Format' => 'HTML',
              'Parameters' => {"authenticity_token"=>"k4xMIcuqMThMsdlbsVJ7GFgzNDw/HgGGp1ldElFULoY=", "user"=>{"screen_name"=>"mgawlista"}},
            }
          }
        }
      end
    end
    
    describe '#parse_read' do
      context 'line ending LIMIT 1' do
        subject {
          ::RailsInfo::Logs::Server.new(
            log: { 
              body: "Processing by DeviseCustomized::RegistrationsController#create as HTML
[1m[35mCACHE (0.0ms)[0m  SELECT `communities`.* FROM `communities` WHERE `communities`.`deleted` = 0 AND `communities`.`slug` = 'bronze' LIMIT 1
              " 
            }
          )
        }
        
        it 'will be parsed correctly' do
          subject.hash.should == {
            'DeviseCustomized::RegistrationsController#create #1' => {
              'Request' => { 'Route' => '', 'Format' => 'HTML' },
              'READ' => [
                "SELECT `communities`.* FROM `communities` WHERE `communities`.`deleted` = 0 AND `communities`.`slug` = 'bronze' LIMIT 1",
              ]
            }
          }
        end
      end
      
      context 'line ending LIMIT 1[.' do
        subject {
          ::RailsInfo::Logs::Server.new(
            log: { 
              body: "Processing by DeviseCustomized::RegistrationsController#create as HTML
[1m[36mCommunity Load (0.5ms)[0m  [1mSELECT `communities`.* FROM `communities` WHERE `communities`.`id` = 2 LIMIT 1[0m
              " 
            }
          )
        }
          
        it 'will be parsed correctly' do
          subject.hash.should == {
            'DeviseCustomized::RegistrationsController#create #1' => {
              'Request' => { 'Route' => '', 'Format' => 'HTML' },
              'READ' => [
                "SELECT `communities`.* FROM `communities` WHERE `communities`.`id` = 2 LIMIT 1",
              ]
            }
          }
        end
      end
    end
    
    describe '#process_insert' do
      subject {
        ::RailsInfo::Logs::Server.new(
          log: { 
            body: "Started POST \"/users/bronze\" for 127.0.0.1 at 2012-07-05 19:33:44 +0200
Processing by DeviseCustomized::RegistrationsController#create as HTML
[1m[35mSQL (276.4ms)[0m  INSERT INTO `users` (`city`, `city_permissions`, `confirmation_sent_at`, `confirmation_token`, `confirmed_at`, `created_at`, `current_sign_in_at`, `current_sign_in_ip`, `delete_token`, `deleted`, `developer`, `email`, `encrypted_password`, `facebook`, `facebook_id`, `facebook_permissions`, `failed_attempts`, `forename`, `google_id`, `initial_community_id`, `last_sign_in_at`, `last_sign_in_ip`, `linkedin`, `linkedin_permissions`, `locked_at`, `master`, `name_permissions`, `notification_email`, `password_salt`, `phone`, `phone_permissions`, `photo_content_type`, `photo_file_name`, `photo_file_size`, `photo_updated_at`, `remember_created_at`, `reset_password_sent_at`, `reset_password_token`, `screen_name`, `screen_name_permissions`, `sign_in_count`, `slug`, `street`, `street_permissions`, `surname`, `tagline`, `tagline_permissions`, `twitter`, `twitter_permissions`, `unconfirmed_email`, `unlock_token`, `updated_at`, `url`, `website`, `website_permissions`, `xing`, `xing_permissions`, `zipcode`, `zipcode_permissions`) VALUES (NULL, 0, '2012-07-05 17:33:50', 'xVQj9z8xGm1bzqqJBjUn', NULL, '2012-07-05 17:33:50', NULL, NULL, NULL, 0, NULL, 'gawlista@googlemail.com', '$2a$10$KnrBV6m64g0zqKwUnQRR/exiUN9HtzJCGLSUse.jPTxLp0WQtNec2', NULL, NULL, 0, 0, NULL, NULL, 2, NULL, NULL, NULL, 0, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'mgawlista', 0, 0, 'mgawlista', NULL, 0, NULL, NULL, 0, NULL, 0, NULL, NULL, '2012-07-05 17:33:50', NULL, NULL, 0, NULL, 0, NULL, 0)
            " 
          }
        )
      }
      
      it 'parses INSERT entries correctly' do
        action = 'DeviseCustomized::RegistrationsController#create #1'
        subject.hash[action]['Request'].should == { 'Route' => "POST \"/users/bronze\"", 'Format' => 'HTML' }
       
        compare_data(
          subject.hash[action]['WRITE']['users'],
          { '-action-' => 'INSERT', 'id' => nil, 'city' => 'NULL', 'WHERE' => nil }
        )
      end
    end
    
    describe '#process_update' do
      subject {
        ::RailsInfo::Logs::Server.new(
          log: { 
            body: "Started POST \"/users/bronze\" for 127.0.0.1 at 2012-07-05 19:33:44 +0200
Processing by DeviseCustomized::RegistrationsController#create as HTML
[1m[35m (0.4ms)[0m  UPDATE `feedbacks` SET `editable` = 0, `updated_at` = '2012-07-09 16:33:31' WHERE `feedbacks`.`type` IN ('Question') AND `feedbacks`.`id` = 3
            "
          }
        )
      }
      
      it 'parses UPDATE entries correctly' do
        action = 'DeviseCustomized::RegistrationsController#create #1'
        subject.hash[action]['Request'].should == { 'Route' => "POST \"/users/bronze\"", 'Format' => 'HTML' }
        
        compare_data(
          subject.hash[action]['WRITE']['feedbacks'],
          { 
            '-action-' => 'UPDATE', 'id' => '3', 'editable' => '0', 'updated_at' => '2012-07-09 16:33:31', 
            'WHERE' => "`feedbacks`.`type` IN ('Question') AND `feedbacks`.`id` = 3" 
          }
        )
      end
    end
  end 
end

def compare_data(table, data)
  data.keys.each_index do |current_index|
    index = data.keys[current_index] == 'WHERE' ? table['columns'].length - 1 : current_index
    column = data.keys[current_index]
    table['columns'][index].should == column
    
    table['rows'].first[column].should == data[column] unless data[column] == nil
  end
end
