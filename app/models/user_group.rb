class UserGroup < ActiveRecord::Base

  attr_accessible :group_id, :user_id, :organization_id

  belongs_to :user
  belongs_to :group

end
