class UsersController < ApplicationController
  layout "user_signup", :only => [:rec_confirm, :create_before_confirm, :create,
                                  :delete, :render_user_complete, :recipient_edit,
                                  :rec_update_before_confirm, :recipient_create,
                                  :render_user_form, :render_user_complete,
                                  :user_complete, :recipient_complete, :add_recipient]

  def rec_confirm
    @account_id = params[:id]
    @user = User.new(:organization_id => params[:organization_id])
    @org_name = Organization.find(params[:organization_id]).name
    @group_ids = []
    render 'user_form'
  end

  def editor
    @user = User.find(params[:id])
  end

  def create_before_confirm
    @user = User.new(params[:user])
    @user_groups = Group.find(:all, :conditions => ["id in (?)", params[:user_group]])
    if @user.valid?
      render 'user_confirmation'
    else
      render_user_form
    end
  end

  def create
    @user = User.new(params[:user])
    @organization = Organization.find(@user.organization_id)
    @user_groups = Group.find(:all, :conditions => ["id in (?)", params[:user_group]])
    return render_user_form if params[:cancel]
    if @user.valid?
      ActiveRecord::Base.transaction do
        @user.save!
      end
      return redirect_to user_complete_org_users_path(:id => @user.id, :account_id => params[:account_id])
    else
      render_user_form
    end
  end

  def user_complete
    @user = User.find(params[:id])
    @account_id = params[:account_id]
  end

  def second_recipient?

  end

  def recipient_edit
    @account = Account.find(params[:account_id])
    user_id= params[:user_id] ||=params[:recipient][:user_id]
    @user = User.find(user_id)
    @account.recipient.attributes = {:user_id => user_id}
    @group_ids = []
    render 'recipient_form'
  end

  def rec_update_before_confirm
    @user = User.find(params[:account][:recipient_attributes][:user_id])
    @account = Account.find(params[:id])
    @account.attributes = params[:account]
    @account.recipient.attributes = params[:account][:recipient_attributes]
    if params[:recipient_group].present?
      @recipient_groups = Group.find(:all, :conditions => ["id in (?)", params[:recipient_group]])
    end
    if @account.valid? && @account.recipient_email_uniq_in_user?(params[:account][:login], @account.recipient.id)
      return render 'recipient_confirmation'
    else
      return render 'recipient_form'
    end
  end

  def recipient_create
    @user = User.find(params[:account][:recipient_attributes][:user_id])
    @account = Account.find(params[:id])
    @account.attributes = params[:account]
    @account.recipient.attributes = params[:account][:recipient_attributes]
    return render 'recipient_form' if params[:cancel]
    params[:recipient_group].each do |group_id|
      @account.recipient.recipient_groups.build(:organization_id => @account.recipient.id,
                                                :group_id => group_id)
    end
    if @account.valid? && @account.recipient_email_uniq_in_user?(params[:account][:login], @account.recipient.id)
      ActiveRecord::Base.transaction do
        @account.save!
      end
      @account.recipient.send_login_url
      flash[:notice] = "受信者登録が完了しました。ご登録のアドレスにログイン画面へのURLを送信しました。"
      return redirect_to recipient_complete_org_users_path(:id => @account.id, :user_id => @user.id)
    else
      render 'recipient_confirmation'
    end
  end

  def recipient_complete
    @user = User.find(params[:user_id])
    @account = Account.find(params[:id])
  end

  def add_recipient
    @user = User.find(params[:user_id])
    @account = Account.new(:status       => 3,
                           :state        => 'active',
                           :activated_at => Time.now)
    @account.build_recipient(:organization => params[:organization_id])
    render 'recipient_form'
  end

  private

  def render_user_form
    @account_id= params[:id] ||= params[:account_id]
    render 'user_form'
  end

  def render_user_complete
    render 'user_complete'
  end

  def render_recipient_complete
    render 'recipient_complete'
  end

end
