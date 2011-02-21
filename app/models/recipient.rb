class Recipient < ActiveRecord::Base

  belongs_to :organization
  belongs_to :user
  belongs_to :account
  has_many :recipient_groups, :dependent => :destroy, :validate => false
  has_many :mail_recipients, :dependent => :destroy, :validate => false
  attr_accessible :name,  :organization_id, :tel1, :tel2, :user_id, :relation

#  validates_presence_of %w(organization_id user_id name relation)

  def validate
  end


  def recipient_group_check
    unless self.recipient_groups.blank?
      group_id_ary = []
      self.recipient_groups.each{|recipient_group| group_id_ary << recipient_group.group_id.to_s}
      return group_id_ary
    end
    nil
  end

  def send_login_url
    RecipientMailer.deliver_send_login(self.account.login, self.organization.name)
  end

  def update_recipient_group(params_recipient_groups)
    recipient_group_ids = self.recipient_groups.map(&:group_id) if self.recipient_groups
    param_group_ids = params_recipient_groups.map{|group_id| group_id.to_i} if params_recipient_groups.present?
    if recipient_group_ids.present? && param_group_ids.present?
      self.build_recipient_groups(param_group_ids - recipient_group_ids)
      self.del_recipient_groups(recipient_group_ids - param_group_ids)
    elsif param_group_ids.present?
      self.build_recipient_groups(param_group_ids)
    elsif self.recipient_groups.present?
      self.recipient_groups.delete_all
    end
  end

  def build_recipient_groups(build_ids)
    unless build_ids.blank?
      build_ids.each do |group_id|
        self.recipient_groups.build(:group_id => group_id,
                                :organization_id => self.organization_id)
      end
    end
  end

  def del_recipient_groups(del_ids)
    unless del_ids.blank?
      del_ids.each do |group_id|
        recipient_group = RecipientGroup.find(:first, :conditions => ["recipient_id=? and group_id=?", self.id, group_id])
        recipient_group.destroy
      end
    end
  end

  private


end
