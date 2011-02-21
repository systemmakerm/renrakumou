class OrganizationObserver < ActiveRecord::Observer
  observe

  def after_create(organization)
    if organization.account.status == 1
      organization.account.login
      organization.account.password
      OrganizationMailer.deliver_signup_notification(organization.account)
    end
  end

  def after_save(organization)
    if organization.account.status == 1
      if organization.account[:login]
        OrganizationMailer.deliver_activation(organization.account) if organization.account.recently_activated?
      end
    end
  end

end
