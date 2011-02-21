class Domain < ActiveRecord::Base

  attr_accessible :organization_id, :virtual_domain, :chname_id

  belongs_to :chname

end
