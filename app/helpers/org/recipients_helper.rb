module Org::RecipientsHelper


  RELATION = %w(本人 母 父 祖父 祖母 兄 姉 その他)

  def form_params
#		if @account.new_record?
#      {:url => create_before_confirm_org_recipients_path, :method => :post}
#    else
      {:url => update_before_confirm_org_recipients_path(:id => current_account.id), :method => :post}
#    end
  end

  def confirmation_params
    if @account.new_record?
      {:url => org_recipients_path, :method => :post}
    else
      {:url => org_recipient_path(@account), :method => :put}
    end
  end

  def options_for_select_relation(selected_value)
    selected_value = selected_value.to_sym if selected_value.present?
    list = RELATION.map{|key, value| [key, key]}
    options_for_select(list, selected_value)
  end

  def user_form_params
    {:url => user_up_before_confirm_org_recipients_path(:id => @user.id), :method => :post}
  end

  def user_confirmation_params
    {:url => user_up_org_recipients_path(:id => @user.id), :method => :post}
  end

end
