#!/usr/bin/env ./script/runner
require 'pp'
require 'digest/sha1'
require 'rubygems'

#This script is generate 500 recipients in the organization_id==1
#testaddress@example.com is example for gmail's account
def create_recs(i, group_ids, group_count)
  user = User.new(:organization_id => 1,
                  :number => "#{i+1}",
                  :name => "test#{i+1}")
  user.user_groups.build(:organization_id => 1,
                         :group_id => group_ids[rand(group_count)])
  puts "No.#{i+1}user belong #{user.user_groups.last.group.full_name}" if user && user.valid?
  user.save!
  account = Account.new(:status => 4,
                        :login => "testaddress+#{i+1}@example.com",
                        :login_confirmation => "testaddress+#{i+1}@example.com",
                        :password => "123456",
                        :password_confirmation => "123456",
                        :state => 'active',
                        :activated_at => Time.now)
  account.build_recipient(:organization_id => 1,
                          :user_id => user.id,
                          :name => "test#{i+1}",
                          :relation => "本人")
  if account && account.valid?
    ActiveRecord::Base.transaction do
      account.save!
      puts "No.#{i+1} addount and recipient save!"
    end
  else
    pp "Sorry, account valid is failure. login: #{account.login}\n"
  end
rescue => ex
	puts "#{ex.class}:#{ex.message}"
end

group_ids = Group.find(:all, :conditions => ["organization_id = ? and depth = ?", 1, 3]).map(&:id)
group_count = group_ids.length
500.times do |i|
  create_recs(i, group_ids, group_count)
end