class Org::Useradmin::GroupsController < ApplicationController
  before_filter :group_find, :only => %w[index search_users]

  def index
  end

  def search_users
    get_users
  end

  def confirmation
    if params[:group_by_move].present?
      @move_group = Group.find(params[:group_by_move].to_i)
    else
      flash[:notice] = "移動先を選択していません。 "
      return redirect_to search_users_org_useradmin_groups_url
    end
    if params[:user]
      @users = User.all(:conditions => ["id in (?)", params[:user]])
    else
      flash[:notice] = "ユーザーにチェックが入っていません。"
      return redirect_to search_users_org_useradmin_groups_url
    end
  end

  def selected_update
    return redirect_to search_users_org_useradmin_groups_url if params[:cancel]
    group = Group.find(params[:group])
    users = User.params_find_users(params[:user])

    ActiveRecord::Base.transaction do
      users.each do |user|
        user.user_groups.delete_all if !user.user_groups.empty?
        UserGroup.create!(
          :group_id        => group.id,
          :user_id         => user.id,
          :organization_id => current_account.organization.id)
      end
    end
    flash[:notice] = "移動が完了しました。"
    redirect_to search_users_org_useradmin_groups_url
  rescue => e
  end

  private
    def group_find
      @groups = Group.find(:all,
                      :conditions => ["organization_id = ?",
                                      current_account.organization.id])
    end

    def get_users
      @users = User.scoped(:conditions => ["users.organization_id = ?",
                                           current_account.organization.id])
      scope_by_number if params[:number].present?
      scope_by_keyword if params[:keywords].present?
      scope_by_group   if params[:group].present?
      @users = @users.all(:order => "number")
      render 'index'
    end

    def scope_by_number
      @users = @users.scoped(:conditions => ["number like ?", "%#{params[:number]}%"])
    end

    def scope_by_keyword
      keywords   = params[:keywords].split(/[ |　|\t]/)
      conditions = @users.formatting_keywords(keywords)
      @users = @users.scoped(:conditions => conditions)
    end

    def scope_by_group
      @users = @users.scoped(:include    => :user_groups,
                             :conditions => ["user_groups.group_id = ?",
                                             params[:group].to_i ] )
    end

end
