class MailRecipient < ActiveRecord::Base

  belongs_to  :mail_summary
  belongs_to  :recipient

  attr_accessible :mail_summary_id,  :organization_id, :recipient_id

end
