class User < ActiveRecord::Base
  require 'fastercsv'
  has_many :recipients, :dependent => :destroy, :validate => false

  has_many :user_groups, :dependent => :destroy, :validate => false
  accepts_nested_attributes_for :user_groups, :allow_destroy => true
  has_many :mail_users, :dependent => :destroy, :validate => false

  has_many :groups, :through => :user_groups

  validates_presence_of %w(number name)
  validates_uniqueness_of :number, :scope => :organization_id

  def number_unique?
    if self.new_record?
      if User.find(:first, :conditions => ["organization_id = ? and number = ?", self.organization_id, self.number])
        errors.add_to_base("入力された登録番号はすでに登録されています。")
        return false
      end
    end
    true
  end

  def group_pickup
    Group.find(:all, :conditions => ["organization_id = ? and depth=?", self.organization_id, 1])
  end

  def user_group_check
    unless self.user_groups.blank?
      group_id_ary = []
      self.user_groups.each{|user_group| group_id_ary << user_group.group_id.to_s}
      return group_id_ary
    end
    nil
  end

  def has_mailaddr?
    if self.recipients
      users_addrs = ""
      self.recipients.each do |recipient|
        users_addrs += recipient.account.login + "\n" if recipient.relation == "本人"
      end
      return users_addrs == "" ? "未登録" : users_addrs
    end
    "未登録"
  end
  
  def has_other_mailaddr?
    if self.recipients
      other_addrs = ""
      self.recipients.each do |recipient|
        other_addrs += recipient.account.login + "\n"if recipient.relation != "本人"
      end
      return other_addrs == "" ? "未登録" : other_addrs
    end
    "未登録"
  end

  def self.parse_user_csv(params, users=[])
    users_data_array = FasterCSV.parse(params[:file][:csv], :headers => true)
    users_data_array.each do |user|
      users << User.new(:number => user[0],
                        :name   => user[1],
                        :memo   => user[2]
                       )
    end
    return users
  end

  def self.create_users(params, current_account, users=[])
    params_user_array = params.to_a.sort {|a, b| (a[0].to_i <=> b[0].to_i) }
    params_user_array.each do |usr|
      users << User.new(:name   => usr[1][:name],
                        :number => usr[1][:number],
                        :memo   => usr[1][:memo],
                        :organization_id => current_account.organization.id)
    end
    return users
  end

  def self.params_find_users(params, users=[])
    users_array = params.to_a.sort{|a, b| (a[0].to_i <=> b[0].to_i) }
    users_array.each do |user|
      users << User.find(user[1][:id])
    end
    return users
  end

  def self.formatting_keywords(keywords)
    cond_k,cond_v = [],[]
    keywords.each do |keyword|
      key = "%#{keyword}%"
      cond_k << "name LIKE ?"
      cond_v << key
    end
    conditions = cond_k.join(" AND ")
    return conditions, *cond_v
  end

  def update_user_group(params_user_groups)
    user_group_ids = self.user_groups.map(&:group_id) if self.user_groups
    param_group_ids = params_user_groups.map{|group_id| group_id.to_i} if params_user_groups.present?
    if user_group_ids.present? && param_group_ids.present?
      self.build_user_groups(param_group_ids - user_group_ids)
      self.del_user_groups(user_group_ids - param_group_ids)
    elsif param_group_ids.present?
      self.build_user_groups(param_group_ids)
    elsif self.user_groups.present?
      self.user_groups.delete_all
    end
  end

  def build_user_groups(build_ids)
    unless build_ids.blank?
      build_ids.each do |group_id|
        self.user_groups.build(:group_id => group_id,
                                :organization_id => self.organization_id)
      end
    end
  end

  def del_user_groups(del_ids)
    unless del_ids.blank?
      del_ids.each do |group_id|
        user_group = UserGroup.find(:first, :conditions => ["recipient_id=? and group_id=?", self.id, group_id])
        user_group.destroy
      end
    end
  end

end
