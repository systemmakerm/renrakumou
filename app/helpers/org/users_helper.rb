module Org::UsersHelper

  RELATION = %w(母 父 祖父 祖母 兄 姉 本人 その他)

  def form_params
		if @user.new_record?
      {:url => create_before_confirm_org_users_path}
    else
      {:url => update_before_confirm_org_users_path(:id => @user.id)}
    end
  end

  def confirmation_params
    if @user.new_record?
      {:url => org_users_path, :method => :post}
    else
      {:url => org_user_path(@user), :method => :put}
    end
  end

  def rec_form_params
    {:url => rec_update_before_confirm_org_users_path(:id => @account.id)}
  end

  def rec_confirmation_params
    {:url => recipient_create_org_users_path, :method => :post}
  end

  def options_for_select_relation(selected_value)
    selected_value = selected_value.to_sym if selected_value.present?
    list = RELATION.map{|key, value| [key, key]}
    options_for_select(list, selected_value)
  end

end
