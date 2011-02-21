class MailSummary < ActiveRecord::Base

  attr_accessible :subject, :body, :organization_id, :address_for_map, :all_send, :relation

  belongs_to  :organization

  has_many :selections, :dependent => :destroy, :validate => false
  accepts_nested_attributes_for :selections, :allow_destroy => true

  has_one :delivery_reserve_time, :dependent => :destroy, :validate => false
  accepts_nested_attributes_for :delivery_reserve_time, :allow_destroy => true

  has_one :delivery_time, :dependent => :destroy, :validate => false
  accepts_nested_attributes_for :delivery_time, :allow_destroy => true

  has_many :mail_groups, :dependent => :destroy, :validate => false
  accepts_nested_attributes_for :mail_groups, :allow_destroy => true

  has_many :mail_recipients, :dependent => :destroy, :validate => false
  accepts_nested_attributes_for :mail_recipients, :allow_destroy => true

  has_many :mail_users, :dependent => :destroy, :validate => false
  accepts_nested_attributes_for :mail_users, :allow_destroy => true

  has_many :answers, :dependent => :destroy, :validate => false
  accepts_nested_attributes_for :answers, :allow_destroy => true

  validates_presence_of %w(subject body)


  def sorted_selections
    self.selections.sort_by{|selection| selection.number}
  end

  def self.publication
		send_time = Time.local(Time.now.year,Time.now.month,Time.now.day,Time.now.hour,Time.now.min,0)
		mail_summary = DeliveryReserveTime.find(:first,:conditions => ["delivery_reserve_time = ?",send_time]).mail_summary
		unless mail_summary.nil?
      mail_summary.just_delivery
		end
	rescue => ex
    puts "deliver_error! smtp connect ok?"
		puts "#{ex.class}:#{ex.message}"
  end

  def just_delivery
    addresses = []
    if self.all_send == 1
      recipients = Recipient.find(:all, :conditions => ["organization_id = ?", self.organization_id])
      recipients.each{|recipient| addresses << [recipient.account.login, recipient.id, recipient.relation]}
    else
      if self.mail_groups.present?
        self.mail_groups.each do |mail_group|
          if mail_group.group.user_groups.present?
            mail_group.group.user_groups.each do |user_group|
              if !user_group.user.nil? && user_group.user.recipients.present?
                user_group.user.recipients.each do |recipient|
                  addresses << [recipient.account.login, recipient.id, recipient.relation]
                end
              end
            end
          end
          if mail_group.group.recipient_groups.present?
            mail_group.group.recipient_groups.each do |recipient_group|
                addresses << [recipient_group.recipient.account.login, recipient_group.recipient.id, recipient_group.recipient.relation]
            end
          end
        end
      end
      if self.mail_recipients.present?
        self.mail_recipients.each do |mail_recipient|
          addresses << [mail_recipient.recipient.account.login, mail_recipient.recipient.id, mail_recipient.recipient.relation]
        end
      end
      if self.mail_users.present?
        self.mail_users.each do |mail_user|
          if mail_user.user.recipients.present?
            mail_user.user.recipients.each do |recipient|
              addresses << [recipient.account.login, recipient.id, recipient.relation]
            end
          end
        end
      end
    end
    unless addresses.empty?
      if self.relation == 1
        addresses.delete_if{|address, recipient_id, relation| relation != "本人"}
      elsif self.relation == 2
        addresses.delete_if{|address, recipient_id, relation| relation == "本人"}
      end
      org_mail_addr = self.organization.domain.chname.address
      addresses.uniq!
      body = self.body + "\n"
      if self.selections.present?
        selects = []
        self.sorted_selections.each do |selection|
          selects << "#{selection.number}.#{selection.body} #{CONFIG["get_answer"]}?id=#{selection.id}"
        end
      end
      addresses.each do |address, recipient_id, relation|
        the_selects = selects.map{|select| select + "&recipient_id=#{recipient_id}\n"} if selects.present?
        SendPublicMailer.deliver_publication(org_mail_addr, address, self.subject, body, the_selects)
      end
      ActiveRecord::Base.transaction do
        self.build_delivery_time(:delivery_time => Time.now,
                                 :organization_id => self.organization_id
        )
        self.save!
      end
    end
  end

  def select_delivery(recipient_ids)
    addresses = []
    recipient_ids.each do |recipient_id|
      addresses << [Recipient.find(recipient_id).account.login, recipient_id]
    end
    unless addresses.empty?
      addresses.uniq!
      body = self.body + "\n"
      if self.selections.present?
        selects = []
        self.sorted_selections.each do |selection|
          selects << "#{selection.number}.#{selection.body} #{CONFIG["get_answer"]}?id=#{selection.id}"
        end
      end
      unless self.address_for_map.blank?
      end
      addresses.each do |address, recipient_id|
        the_selects = selects.map{|select| select + "&recipient_id=#{recipient_id}\n"} if selects.present?
        SendPublicMailer.deliver_publication(address, self.subject, body, the_selects)
      end
    end
  end

  def group_build(group_id)
    self.mail_groups.build(:group_id => group_id,
                    :organization_id => self.organization_id)
  end

  def user_build(user_id)
    self.mail_users.build(:user_id => user_id,
                    :organization_id => self.organization_id)
  end

  def recipient_build(recipient_id)
    self.mail_recipients.build(:recipient_id => recipient_id,
                    :organization_id => self.organization_id)
  end


  def group_ids_build(group_ids)
    group_ids.each do |group_id|
      self.mail_groups.build(:group_id => group_id,
                             :organization_id => self.organization_id)
    end
  end

  def mail_groups_del(delete_ids)
    mail_groups = MailGroup.find(:all,
     :conditions=>["mail_summary_id=? and group_id in (?)", self.id, delete_ids])
    mail_groups.each{|mail_group| mail_group.destroy}
  end

  def user_ids_build(user_ids)
    user_ids.each do |user_id|
      self.mail_users.build(:user_id => user_id,
                            :organization_id => self.organization_id)
    end
  end

  def mail_users_del(delete_ids)
    mail_users = MailUser.find(:all,
     :conditions=>["mail_summary_id=? and user_id in (?)", self.id, delete_ids])
    mail_users.each{|mail_user| mail_user.destroy}
  end

  def recipient_ids_build(recipient_ids)
    recipient_ids.each do |recipient_id|
      self.mail_recipients.build(:recipient_id => recipient_id,
                                 :organization_id => self.organization_id)
    end
  end

  def mail_recipients_del(delete_ids)
    mail_recipients = MailRecipient.find(:all,
     :conditions=>["mail_summary_id=? and recipient_id in (?)", self.id, delete_ids])
    mail_recipients.each{|mail_recipient| mail_recipient.destroy}
  end

  def builds_selections(select_bodies)
    i = 1
    select_bodies.each do |body|
      if body != ""
        self.selections.build(:body => body,
                              :number => i,
                              :organzation_id => self.organization_id)
        i += 1
      end
    end
  end

  def update_mail_groups(param_group_ids)
    mail_group_ids = self.mail_groups.map(&:group_id) if self.mail_groups #送信先グループの差分生成
    if mail_group_ids.present? && param_group_ids.present?
      unless (build_ids = param_group_ids - mail_group_ids).blank?
        self.group_ids_build(build_ids)
      end
      unless (del_ids = mail_group_ids - param_group_ids).blank?
        self.mail_groups_del(del_ids)
      end
    elsif param_group_ids.present?
      self.group_ids_build(param_group_ids)
    elsif self.mail_groups.present?
      self.mail_groups.delete_all
    end
  end

  def update_mail_users(param_user_ids)
    mail_user_ids = self.mail_users.map(&:user_id) if self.mail_users #送信先 ユーザーの差分生成
    if mail_user_ids.present? && param_user_ids.present?
      if (build_user_ids = param_user_ids - mail_user_ids).present?
        self.user_ids_build(build_user_ids)
      end
      if (del_user_ids = mail_user_ids - param_user_ids).present?
        self.mail_users_del(del_user_ids)
      end
    elsif param_user_ids.present?
      self.user_ids_build(param_user_ids)
    elsif self.mail_users.present?
      self.mail_users.delete_all
    end
  end

  def update_mail_recipients(param_recipient_ids)
    mail_recipient_ids = self.mail_recipients.map(&:recipient_id) if self.mail_recipients #送信先 受信者の差分生成
    if mail_recipient_ids.present? && param_recipient_ids.present?
      unless (build_rec_ids = param_recipient_ids - mail_recipient_ids).blank?
        self.recipient_ids_build(build_rec_ids)
      end
      unless (del_rec_ids = mail_recipient_ids - param_recipient_ids).blank?
        self.mail_recipients_del(del_rec_ids)
      end
    elsif param_recipient_ids.present?
      self.recipient_ids_build(param_recipient_ids)
    elsif self.mail_recipients.present?
      self.mail_recipients.delete_all
    end
  end
  
  def update_selections(select_bodies)
    selections = self.sorted_selections if self.selections #回答選択肢の差分生成
    i = 1
    select_bodies.each do |body|
      selection = selections.shift unless selections.blank?
      if body == ""
        selection.destroy if selection
      else
        if selection
          selection.attributes = {:body => body, :number => i}
          selection.save!
        else
          self.selections.build(:body => body, :number => i,
                     :organzation_id => self.organization_id)
        end
        i += 1
      end
    end
  end

  def delete_groups_users_recs
    self.mail_groups.delete_all
    self.mail_users.delete_all
    self.mail_recipients.delete_all
  end

  def all_recipient_ids
    recipient_ids = []
    if self.mail_users.present?
      self.mail_users.each do |mail_user|
        if mail_user.user && mail_user.user.recipients.present?
          mail_user.user.recipients.each do |recipient|
            recipient_ids << recipient.id
          end
        end
      end
    end
    if self.mail_groups.present?
      self.mail_groups.each do |mail_group|
        if mail_group.group && mail_group.group.user_groups.present?
          mail_group.group.user_groups.each do |user_group|
            if user_group.user && user_group.user.recipients.present?
              recipient_ids += user_group.user.recipients.map(&:id)
            end
          end
        end
        if mail_group.group && mail_group.group.recipient_groups.present?
          recipient_ids += mail_group.group.recipient_groups.map(&:recipient_id)
        end
      end
    end
    if self.mail_recipients.present?
      recipient_ids += self.mail_recipients.map(&:recipient_id)
    end
    recipient_ids.uniq!
    return recipient_ids
  end

end
