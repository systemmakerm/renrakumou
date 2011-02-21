class SendPublicMailer < ActionMailer::Base
  
  def publication(org_mail_addr, toAddress, mailsubject, mailbody, selects, addr_url=nil)
		from org_mail_addr
		recipients toAddress
		subject mailsubject
		body :body => mailbody, :select => selects, :adr_url => addr_url
	end
  
end
