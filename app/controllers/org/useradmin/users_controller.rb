class Org::Useradmin::UsersController < ApplicationController
  
  def new
    @user = User.new(:organization_id => current_account.organization.id)
    @group_ids = []
    render 'user_form'
  end

  def edit
    @user = User.find(params[:id])
    @group_ids = @user.user_group_check
    render 'user_form'
  end

  def show
    @user = User.find(params[:id])
  end

  def create_before_confirm
    @user = User.new(params[:user])
    if params[:user_group].present?
      @user_groups = Group.find(:all, :conditions => ["id in (?)", params[:user_group]])
    end
    if @user.valid? && @user.number_unique?
      return render 'user_confirmation'
    else
      render 'user_form'
    end
  end

  def update_before_confirm
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    if params[:user_group].present?
      @user_groups = Group.find(:all, :conditions => ["id in (?)", params[:user_group]])
    end
    if @user.valid? && @user.number_unique?
      return render 'user_confirmation'
    else
      render 'user_form'
    end
  end

  def create
    @user = User.new(params[:user])
    if params[:user_group].present?
      params[:user_group].each do |group_id|
        @user.user_groups.build(:group_id => group_id,
                                :organization_id => @user.organization_id)
      end
    end
    return render 'user_form' if params[:cancel]
    ActiveRecord::Base.transaction do
      @user.save!
    end
    return redirect_to user_complete_org_useradmin_users_path(:id=>@user.id)
  end

  def user_complete
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    return render 'user_form' if params[:cancel]
    @user.update_user_group(params[:user_group])
    ActiveRecord::Base.transaction do
      @user.save!
    end
    render 'user_complete'
  end

  def user_complete
    @user = User.find(params[:id])
  end

  require 'fastercsv'
  def select_user
    if params[:adr_csv]
      out_ads_csv
    else
      if params[:group_id] != "0"
        scope_by_group_id
      else
        @user_scope = User.scoped(:conditions => ["organization_id = ?",
                                   current_account.organization.id])
      end
      scope_by_number if params[:number]
      scope_by_name if params[:name]
      if params[:csv]
        out_csv
      else
        @users = @user_scope.paginate(paginate_options.merge(:order => "id"))
        @user_num = @users.count
        flash[:notice] = "ユーザー検索結果：0人" if @users.blank?
        return render 'search'
      end
    end
  end

  def detail
    @user = User.find(params[:id])
  end

  def after_detail
    return redirect_to new_org_useradmin_recipient_path(:user_id => params[:user_id]) if params[:recipient_add]
    return redirect_to edit_org_useradmin_user_path(:id => params[:user_id]) if params[:user_edit]
  end

  def delete
    user = User.find(params[:user_id])
    user.recipients.blank? ? notice = "ユーザーを削除しました。" : notice = "ユーザー・受信者を削除しました。"
    user.destroy
    flash[:notice] = notice
    redirect_to search_org_useradmin_users_path
  end

  private

    def scope_by_group_id
      top_group = Group.find(params[:group_id])
      group_ids = [params[:group_id]]
      if top_group.child_groups
        top_group.child_groups.each do |child|
          group_ids << child.id
          if child.child_groups
            child.child_groups.each do |grand_child|
              group_ids << grand_child.id
            end
          end
        end
      end
      user_ids = UserGroup.find(:all, :conditions=>["organization_id = ? and group_id in (?)",
                                  current_account.organization.id, group_ids]).map(&:user_id)
      @user_scope = User.scoped(:conditions =>
                                ["organization_id = ? and id in (?)",
                                 current_account.organization.id, user_ids])
    end

    def scope_by_number
      @user_scope = @user_scope.scoped(:conditions => ["number like ?", "%#{params[:number]}%"])
    end

    def scope_by_name
      @user_scope = @user_scope.scoped(:conditions => ["name like ?", "%#{params[:name]}%"])
    end

    def out_csv
      users_csv = FasterCSV.generate do |csv|
        csv << %w[登録番号 名前 メモ グループ]
        @user_scope.all(:order => :number).each do |user|
          user_groups =""
          unless user.user_groups.blank?
            user.user_groups.each do |user_group|
              user_groups = user_groups + user_group.group.full_name
            end
          end
          csv << [ user.number, user.name, user.memo, "#{user_groups}" ]
        end
      end
      send_data(users_csv, :filename => "#{current_account.organization.name}連絡網ユーザー一覧.csv")
    end

    def out_files
      files = File.new
    rescue
      files.close
    end

#    def out_ads_csv
#      users_csv = FasterCSV.generate do |csv|
#        csv << %w[登録番号 名前 URL]
#        users = User.find(:all, :conditions => ["id in (?)", params[:user_ids]], :order => :number)
#        users.each do |user|
#          url = "#{CONFIG["number_check"]}?id=#{user.id}&organization_id=#{user.organization_id}"
#          csv << [ user.number, user.name, url]
#        end
#      end
#      send_data(users_csv, :filename => "#{current_account.organization.name}連絡網受信者登録用URL一覧.csv")
#    end

    def paginate_options
      {:page => params[:page], :per_page => 20}
    end
    
end
