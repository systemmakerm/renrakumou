class Selection < ActiveRecord::Base

  belongs_to  :mail_summary
  attr_accessible :selections_attributes, :body,  :number, :mail_summary_id

 
end
