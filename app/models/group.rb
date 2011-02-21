class Group < ActiveRecord::Base
  has_many :user_groups, :dependent => :destroy, :validate => false
  has_many :users, :through => :user_groups
  has_many :recipient_groups, :dependent => :destroy, :validate => false
  has_many :recipients, :through => :recipient_groups
  has_many :mail_groups, :dependent => :destroy, :validate => false
#  acts_as_nested_set
  attr_accessible :name,  :depth, :group_id,  :organization_id

  validates_presence_of :name

  def parent_name
    Group.find(self.parent_id).name if self.parent_id
  end

  named_scope :by_organization_depth_one, lambda{|value|
    { :conditions => ["organization_id = ? and depth = 1", value] }
  }

  def full_name
    if self.depth > 1
      group_names = []
      group_names << self.name
      thegroup = self
      (self.depth - 1).times do |i|
        thegroup = Group.find(thegroup.parent_id)
        group_names << thegroup.name
      end
      name = ""
      self.depth.times do |i|
        name = name + group_names.pop
      end
    else
      name = self.name
    end
    return name
  end

  def parent_name
    Group.find(self.parent_id).full_name if self.parent_id
  end

  def child_groups
    ary = []
    unless Group.find(:first, :conditions => ["parent_id=?", self.id]).blank?
      return Group.find(:all, :conditions => ["parent_id=?", self.id], :order => 'name')
    end
    return ary
  end

  def child_count
    unless Group.find(:first, :conditions => ["parent_id=?", self.id]).blank?
      return Group.find(:all, :conditions => ["parent_id=?", self.id]).count
    end
    0
  end

  def user_group_users
    users = []
    if self.user_groups.present?
      self.user_groups.each do |user_group|
        users << user_group.user if user_group.user && user_group.user.recipients.present?
      end
    end
    return users
  end

  def recipient_group_users
    users = []
    unless self.recipient_groups.blank?
      self.recipient_groups.each do |recipient_group|
        users << recipient_group.recipient.user if recipient_group.recipient && recipient_group.recipient.user
      end
    end
    return users
  end

  def group_all_users
    self.user_group_users | self.recipient_group_users
  end

  def group_users_recipients
    recipients = []
    unless self.user_groups.blank?      
      self.user_groups.each do |user_group|
        recipients << user_group.user.recipients if user_group.user && user_group.user.recipients.present?
      end
      recipients.flatten!  
    end
    return recipients
  end

  def group_recipients
    recipients = []
    if self.recipient_groups.present?
      self.recipient_groups.each do |recipient_group|
        recipients << recipient_group.recipient if recipient_group.recipient
      end
    end
    return recipients
  end

  def group_all_recipients
    self.group_users_recipients | self.group_recipients
  end

end
