class AccountObserver < ActiveRecord::Observer
  observe Account

  def after_create(account)
    if account.status == 1
      account.login
      account.password
      OrganizationMailer.deliver_signup_notification(account)
    end
  end

  def after_save(account)
    if account.status == 1
      if account[:login]
        OrganizationMailer.deliver_activation(account) if account.recently_activated?
      end
    end
  end
  
end
