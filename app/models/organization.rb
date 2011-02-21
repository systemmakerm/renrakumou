class Organization < ActiveRecord::Base

  require "rubygems"
  require "rqr"

  belongs_to :account
  has_many :administrators
  has_many :groups
  has_many :users
  has_one  :domain

  attr_accessible :name, :leader_name, :kana, :sex, :zip, :prefecture, :address1, :address2, :tel, :fax, :purpose

  SEX = %w(男 女)

  validates_presence_of %w(name leader_name sex zip prefecture address1 tel purpose)

  def leader_sex?
    SEX[self.sex]
  end

  def implementation?
    return "運用中" if self.valid_date > Date.today
    return "停止"
  end

  def password_check?(params_account)
    result = true
    if params_account[:password].present? || params_account[:password_confirmation].present?
      if params_account[:password].blank? && params_account[:password_confirmation].present?
        result = false
      end
      if params_account[:password].present? && params_account[:password].length < 6
        result = false
      end
      if params_account[:password].present? && params_account[:password_confirmation].blank?
        result = false
      end
      if params_account[:password_confirmation].present? && params_account[:password_confirmation].length < 6
        result = false
      end
      if params_account[:password_confirmation].present? && params_account[:password_confirmation].present? && params_account[:password] != params_account[:password_confirmation]
        result = false
      end
    end
    return result
  end
  
  def password_error_messages(params_account)
    if params_account[:password].present? || params_account[:password_confirmation].present?
      if params_account[:password].blank? && params_account[:password_confirmation].present?
        errors.add_to_base("パスワードが未入力です。")
      end
      if params_account[:password].present? && params_account[:password].length < 6
        errors.add_to_base("パスワードは６文字以上で入力してください。")
      end
      if params_account[:password].present? && params_account[:password_confirmation].blank?
        errors.add_to_base("確認用パスワードが未入力です。")
      end
      if params_account[:password_confirmation].present? && params_account[:password_confirmation].length < 6
        errors.add_to_base("確認用パスワードは６文字以上で入力してください。")
      end
      if params_account[:password_confirmation].present? && params_account[:password_confirmation].present? && params_account[:password] != params_account[:password_confirmation]
        errors.add_to_base("パスワードと確認用パスワードが不一致です。")
      end
    end
  end

  def password_update?(params_account)
    if self.password_check?(params_account)
      if params_account[:password].present? && params_account[:password_confirmation].present?
        return true
      end
    end
    false
  end

  def rec_addr_qr_create
    RQR::QRCode.create do |qr|
      qr.save("#{self.domain.chname.address}", "#{CONFIG[:qr_save_path]}rec_qrcode#{self.id}.jpg")
    end
  end

  def domain_create
    ary = ("a".."z").to_a + ("0".."9").to_a
    loop do
      code = (Array.new(6) do
                ary[rand(ary.size)]
              end).join
      unless Domain.find(:first, :conditions => ["virtual_domain = ?", code])
        chname = Chname.new(:address => "#{code}#{CONFIG[:org_address]}",
                            :goto => "administrator")
        chname.save!
        domain = Domain.new(:organization_id => self.id,
                            :virtual_domain => "org#{self.id}",
                            :chname_id => chname.id)
        domain.save!
        break
      end
    end
  end

  def rec_mail_addr
    self.domain.chname.address
  end

end
