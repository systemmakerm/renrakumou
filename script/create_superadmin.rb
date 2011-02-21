#!/usr/bin/env ./script/runner
require 'pp'
require 'digest/sha1'
require 'rubygems'

def create_superadmin
  return puts "Failure! Superadmin is already created!" if Account.find(:first, :conditions => ["status = ?", 0])
  account = Account.new(:status => 0,
                        :login => "renrakumou@example.com",
                        :login_confirmation => "renrakumou@example.com",
                        :password => "password here",
                        :password_confirmation => "password here",
                        :state => 'active',
                        :activated_at => Time.now)
  puts "account valid is ok\n" if account && account.valid?
  account.build_organization(:name => "スーパー管理者",
                              :leader_name => "スーパー管理者",
                              :sex => 0,
                              :zip => "xxx-xxxx",
                              :prefecture => "島根県",
                              :address1 => "samplecity",
                              :tel => "XXXX-XX-XXXX",
                              :purpose => "連絡網管理")
  account.organization.valid_date = Date.new(2030, 12, 31)
  puts account.organization.valid_date
  puts "organization valid is ok\n" if account.organization && account.organization.valid?
  success = account && account.valid?
  if success && account.errors.empty?
    puts "id: #{account.login}\n団体名称：#{account.organization.name}\n"
    ActiveRecord::Base.transaction do
      account.save!
    end
  else
    pp "Sorry, account valid is failure. login: #{account.login}\n"
  end
rescue => ex
	puts "#{ex.class}:#{ex.message}"
end

create_superadmin