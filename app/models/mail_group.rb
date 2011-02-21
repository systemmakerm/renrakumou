class MailGroup < ActiveRecord::Base

  belongs_to  :mail_summary
  belongs_to  :group

  attr_accessible :mail_summary_id, :group_id,  :organization_id

end
