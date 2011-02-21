class ErrorMail < ActiveRecord::Base

  belongs_to :mail_summary
  belongs_to :recipient
  
end
