class RecipientGroup < ActiveRecord::Base

  belongs_to :recipient
  belongs_to :group

end
