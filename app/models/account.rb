require 'digest/sha1'

class Account < ActiveRecord::Base
  attr_accessible :login, :login_confirmation, :password, :password_confirmation,
                  :status,  :state,   :activated_at

  has_one :organization
  accepts_nested_attributes_for :organization, :allow_destroy => true

  has_one :recipient, :dependent => :destroy
  accepts_nested_attributes_for :recipient, :allow_destroy => true

  has_one :administrator, :dependent => :destroy
  accepts_nested_attributes_for :administrator, :allow_destroy => true

  validates_presence_of     :login#, :password,  :password_confirmation
  validates_length_of       :password, :within => 6..100, :if => :password #r@a.wk
  validates_length_of       :password_confirmation, :within => 6..100, :if => :password_confirmation #r@a.wk
  validates_confirmation_of :login

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  #  validates_presence_of     :login
  #  validates_length_of       :login,    :within => 3..40
  #  validates_uniqueness_of   :login
  #  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message
  #
  #  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  #  validates_length_of       :name,     :maximum => 100
  #
  #  validates_presence_of     :email
  #  validates_length_of       :email,    :within => 6..100 #r@a.wk
  #  validates_uniqueness_of   :email
  #  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #

  def validate
  end

  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    accounts = find_in_state :all, :active, :conditions => {:login => login.downcase} # need to get the salt
#    accounts = Account.find(:all, :conditions => ["login=?", login])
    success_account = []
    accounts.each do |a|
      success_account << a if a && a.authenticated?(password)
    end
    return success_account
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def super_admin?
    false
    return true if self.status == 0
  end

  def organization?
    false
    return true if self.status == 1
  end

  def admin?
    false
    return true if self.status == 2
  end

  def recipient?
    false
    return true if self.status == 3
  end

  def status_name
    case self.status
    when 0
    when 1
      self.organization.leader_name
    when 2
      self.administrator.name
    when 3
      self.recipient.name
    end
  end

  def attr_update(params_account)
    if self.password_update?(params_account)
      self.attributes = params_account
    else
      self.attributes = {:login => params_account[:login],
                         :login_confirmation => params_account[:login_confirmation]}
    end
  end

  def password_update?(params_account)
    if params_account[:password].present? || params_account[:password_confirmation].present?
      return true
    end
    false
  end

  def recipient_email_uniq_in_user?(login, recipient_id=nil)
    if recipient_id && (recipients = self.recipient.user.recipients)
      logins = []
      recipients.each do |recipient|
        logins << recipient.account.login if recipient.id != recipient_id
      end
      if logins.include?(login)
        errors.add_to_base("1人のユーザーに同じメールアドレスがすでに登録されています。")
        return false
      end
    elsif self.recipient.user.recipients
      recipients = self.recipient.user.recipients
      logins = recipients.map{|recipient| recipient.account.login}
      if logins.include?(login)
        errors.add_to_base("1人のユーザーに同じメールアドレスがすでに登録されています。")
        return false
      end
    end
    true
  end

  
  protected
    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end
end
