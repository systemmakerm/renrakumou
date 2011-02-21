class MailUser < ActiveRecord::Base

  belongs_to  :mail_summary
  belongs_to  :user

  attr_accessible :mail_summary_id,  :organization_id, :user_id

end
