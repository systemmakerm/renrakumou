Dir[File.join(File.dirname(__FILE__), 'actionmailer_ja/**/*.rb')].sort.each { |lib| require lib }
ActionMailer::Base.class_eval do
  include ActionMailer::Ja
end
