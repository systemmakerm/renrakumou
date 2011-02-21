module Org::Useradmin::RecipientsHelper

  RELATION = %w(母 父 祖父 祖母 兄 姉 本人 その他)

  def form_params
		if @account.new_record?
      {:url => create_before_confirm_org_useradmin_recipients_path, :method => :post}
    else
      {:url => update_before_confirm_org_useradmin_recipients_path(:id => @account.id), :method => :post}
    end
  end

  def confirmation_params
    if @account.new_record?
      {:url => org_useradmin_recipients_path, :method => :post}
    else
      {:url => org_useradmin_recipient_path(@account), :method => :put}
    end
  end
  
  def options_for_select_relation(selected_value)
    selected_value = selected_value.to_sym if selected_value.present?
    list = RELATION.map{|key, value| [key, key]}
    options_for_select(list, selected_value)
  end

end
