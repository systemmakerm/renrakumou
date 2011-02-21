module Org::Sendmail::MailSummariesHelper

  ANSSITUATION = %w(回答済み 未回答)

  def form_params
		if @mail_summary.new_record?
      {:url => create_body_before_confirm_org_sendmail_mail_summaries_path, :method => :post}
    else
      {:url => update_body_before_confirm_org_sendmail_mail_summaries_path(:id => @mail_summary.id), :me6thod => :post}
    end
  end

  def select_params
		if @mail_summary.new_record?
      {:url => create_before_confirm_org_sendmail_mail_summaries_path, :method => :post}
    else
      {:url => update_before_confirm_org_sendmail_mail_summaries_path(:id => @mail_summary.id), :method => :post}
    end
  end

  def confirmation_params
		if @mail_summary.new_record?
      {:url => org_sendmail_mail_summaries_path, :method => :post}
    else
      {:url => org_sendmail_mail_summary_path(:id => @mail_summary.id), :method => :put}
    end
  end

  def radio_checked?(val,status)
    val.to_i == status.to_i
  end

  def options_for_select_sent_group(mail_summary, selected_value=nil)
    unless selected_value.nil?
      value = selected_value.to_i
    end
    mail_group_ids = mail_summary.mail_groups.map(&:group_id) if mail_summary.mail_groups.present?
    groups = Group.find(:all, :conditions=>["id in (?)", mail_group_ids])
    list = [["全て", 0]]
    groups.each do |group|
      list << [group.full_name, group.id]
      if group.child_groups
        group.child_groups.each do |child|
          list << [child.full_name, child.id]
          if child.child_groups
            child.child_groups.each do |grand_child|
              list << [grand_child.full_name, grand_child.id]
            end
          end
        end
      end
    end
    options_for_select(list, value)
  end

  def options_for_ans_situation(selected_value=nil)
    unless selected_value.nil?
      value = selected_value.to_i
    end
    list = [["全て", 0]]
    ANSSITUATION.each_with_index do |ans_situ, i|
      list << [ans_situ, i + 1]
    end
    options_for_select(list, value)
  end

  def recipient_answer(mail_summary_id, recipient_id)
    if answer = Answer.find(:first, :conditions => ["mail_summary_id=? and recipient_id=?", mail_summary_id, recipient_id])
      if select = Selection.find(:first, :conditions => ["mail_summary_id=? and number=?", mail_summary_id, answer.number])
        return "#{select.number.to_s}"
      end      
    end
    "未回答"
  end

  def retry_checkbox(mail_summary_id, recipient_id)
    unless Answer.find(:first, :conditions => ["mail_summary_id=? and recipient_id=?", mail_summary_id, recipient_id])
      return check_box_tag("recipient[]", recipient_id,
        checkbox_is_selected?(params[:recipient], recipient_id), :id =>"recipient_#{recipient_id}")
    end
  end

  def has_smtp_error?(mail_summary_id, recipient_id)
#    if error_mail = ErrorMail.find(:first, :conditions=>["mail_summary_id=? and recipient_id=?", mail_summary_id, recipient_id])
#      link_to("有り", detail_error_org_sendmail_mail_summaries_path(:id => error_mail.id, :mail_summary_id => mail_summary_id),
#        :popup => ["送信エラー詳細", "heighdt=210, width=550"])
#    end
  end

  def all_send_checkbox_is_selected?(params)
    return params == "1" if params
    false
  end

end
