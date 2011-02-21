class Chname < ActiveRecord::Base

  attr_accessible :address, :goto

  has_one :domain

end
