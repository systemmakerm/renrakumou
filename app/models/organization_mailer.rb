class OrganizationMailer < ActionMailer::Base

  #団体仮登録後の本登録画面用通知
  def signup_notification(account)
    setup_email(account)
    @subject    = 'Renrakumou - 新規団体登録のお知らせ'
    @body[:url]  = "#{CONFIG["host"]}/activate/#{account.activation_code}"
  end

  #団体本登録完了の通知
  def activation(user)
    setup_email(user)
    @subject    = 'Renrakumou - 団体登録完了のお知らせ'
    @body[:url]  = "#{CONFIG["host"]}"
    @body[:login]  = "#{CONFIG["login"]}"
  end

  # スーパー管理者へメール通知(団体登録通知)
  def disapproval_mail(user)
    admin_email(user)
    attr = User::USER_ATTR[(user.user).user_attr]
    @subject          += ('承認依頼通知')
    @body[:url]        = "#{CONFIG["host"]}"
    @body[:login_name] = user.user.login
    @body[:user_name]  = user.name
  end

  def dissolve(comment, organization)
    @recipients  = "renrakumou@example.com"
    @from        = CONFIG["mail"]["sender_from"]
    @subject     = "団体「" + organization + "」様の運用停止のお知らせ"
    @sent_on     = Time.now
    @body[:organization] = organization
    @body[:comment] = comment
  end
  
  protected

    def setup_email(account)
      @recipients  = "#{account.login}"
      @from        = CONFIG["mail"]["sender_from"]
      @subject     = "Renrakumou"
      @sent_on     = Time.now
      @body[:org_id] = account.organization.id
      @body[:organization_name] = account.organization.name
    end

end
