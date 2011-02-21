module Org::Useradmin::UsersHelper

  def form_params
		if @user.new_record?
      {:url => create_before_confirm_org_useradmin_users_path}
    else
      {:url => update_before_confirm_org_useradmin_users_path(:id => @user.id)}
    end
  end

  def confirmation_params
    if @user.new_record?
      {:url => org_useradmin_users_path, :method => :post}
    else
      {:url => org_useradmin_user_path(@user), :method => :put}
    end
  end

  def user_form_back
    if @user.new_record?
      return link_to("ユーザー検索に戻る", search_org_useradmin_users_path)
    else
      return link_to("ユーザー明細に戻る", detail_org_useradmin_users_path(:id => @user.id))
    end
  end

end
