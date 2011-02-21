class RecipientMailer < ActionMailer::Base

  def receive(email)
    account = Account.new(:login => email.from[0],
                          :password => "111111",
                          :password_confirmation => "111111",
                          :status => 4,
                          :state => 'active',
                          :activated_at => Time.now)
    chname = Chname.find(:first, :conditions => ["address = ?", email.to[0]])
    domain = Domain.find(:first, :conditions => ["chname_id = ?", chname.id])
    account.build_recipient(:organization_id => domain.organization_id)
    account.save!
    RecipientMailer.deliver_sender_url(domain.organization_id, account.id, email.from[0], email.to[0], account.recipient.organization.name)
  end

  def sender_url(org_id, account_id, rec_addr, from_addr, organization_name)
    recipients  rec_addr
    from        "#{from_addr}"
    subject     "#{organization_name}連絡網よりご登録のお願い"
    @sent_on   = Time.now
    body  :organization_name => "#{organization_name}",
          :goto_url => "#{CONFIG["host"]}/sessions/rcnum?og=#{org_id}&ac=#{account_id}"
  end

  def sender_login(email, organization_name)
		from CONFIG["mail"]["public_from"]
		recipients email
		subject "#{organization_name}Renrakumouより登録完了のお知らせ"
		body :sentence => "下記URLよりログイン画面にアクセスできます。",
         :url => "#{CONFIG["host"]}/session/new",
         :organization_name => "#{organization_name}"
  end
  

  def sample_rec_url(org_id, account_id, rec_addr, from_addr)
    recipients  rec_addr
    from        "#{from_addr}"
    subject     "ご登録のお願い"
    @sent_on   = Time.now
    body  :sentence => "メール送信ありがとうございます。\n下記アドレスよりをクリックされると登録画面に進むことができます。",
          :goto_url => "http://localhost:3000/sessions/rcnum?og=#{org_id}&ac=#{account_id}"
  end

end
