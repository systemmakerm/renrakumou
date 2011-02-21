class DeliveryReserveTime < ActiveRecord::Base

  attr_accessible :delivery_reserve_times_attributes , :delivery_reserve_time, :organization_id, :mail_summary_id

  belongs_to :mail_summary
end
