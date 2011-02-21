class RecipientsController < ApplicationController

  layout "user_signup",      :only => :dissolve_complete
  layout "application", :only => [:show, :detail, :edit, :editor, :dissolve,
                                  :decide_dissolve, :update_before_confirm,
                                  :update, :recipient_complete, :number_check,
                                  :number_confirm, :new, :create_before_confirm,
                                  :create, :editor_user, :user_up_before_confirm,
                                  :user_up]

  def new
    user_id= params[:user_id] ||=params[:recipient][:user_id]
    @user = User.find(user_id)
    @account = Account.find(params[:account_id])
    @account.recipient.attributes = {:user_id => user_id}
    @group_ids = []
    render 'recipient_form'
  end

  def show
    @recipient = Recipient.find(params[:id])
  end

  def detail
    @recipient = Recipient.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    
    render 'recipient_form'
  end

  def editor
    @account = current_account
    @user = @account.recipient.user
    @group_ids = @account.recipient.recipient_group_check
    render 'recipient_form'
  end

  def dissolve
    @account = Account.find(params[:id])
  end

  def decide_dissolve
    account = Account.find(params[:id])
    recipient = account.recipient
    ActiveRecord::Base.transaction do
      recipient.destroy
      account.destroy
    end
    logout_keeping_session!
    return redirect_to dissolve_complete_org_recipients_path
  end

  def dissolve_complete
    render 'dissolve_complete'
  end

  def create_before_confirm
    @user = User.find(params[:account][:recipient_attributes][:user_id])
    @account = Account.new(params[:account])
    @account.build_recipient(params[:account][:recipient_attributes])
    if params[:recipient_group].present?
      @recipient_groups = Group.find(:all, :conditions => ["id in (?)", params[:recipient_group]])
    end
    if @account.valid? && @account.recipient_email_uniq_in_user?(params[:account][:login])
      return render 'confirmation'
    else
      @account.errors.full_messages
      render 'recipient_form'
    end
  end

  def update_before_confirm
    @user = User.find(params[:account][:recipient_attributes][:user_id])
    @account = Account.find(params[:id])
    @account.attr_update(params[:account])
    @account.recipient.attributes = params[:account][:recipient_attributes]
    if params[:recipient_group].present?
      @recipient_groups = Group.find(:all, :conditions => ["id in (?)", params[:recipient_group]])
    end
    if @account.valid? && @account.recipient_email_uniq_in_user?(params[:account][:login], @account.recipient.id)
      return render 'confirmation'
    else
      return render 'recipient_form'
    end
  end

  def create
    @account = Account.new(params[:account])
    @account.build_recipient(params[:account][:recipient_attributes])
    @user = @account.recipient.user
    return render 'recipient_form' if params[:cancel]
    params[:recipient_group].each do |group_id|
      @account.recipient.recipient_groups.build(:organization_id => @account.recipient.id,
                                                :group_id => group_id)
    end
    if @account.valid? && @account.recipient_email_uniq_in_user?(params[:account][:login])
      ActiveRecord::Base.transaction do
        @account.save!
      end
      @account.recipient.send_login_url
      flash[:notice] = "受信者登録が完了しました。ご登録のアドレスにログイン画面へのURLを送信しました。"
      return render 'recipient_complete'
    else
      render 'recipient_confirmation'
    end
  end

  def update
    @account = Account.find(params[:id])
    @account.attr_update(params[:account])
    @account.recipient.attributes = params[:account][:recipient_attributes]
    @user = @account.recipient.user
    return render 'recipient_form' if params[:cancel]
    @account.recipient.update_recipient_group(params[:recipient_group])
    if @account.valid? && @account.recipient_email_uniq_in_user?(params[:account][:login], @account.recipient.id)
      ActiveRecord::Base.transaction do
        @account.save!
      end
      flash[:notice] = "受信者情報を更新しました。"
      return redirect_to recipient_complete_org_recipients_path(:id => @account.id)
    else
      @account.errors.full_messages
      render 'recipient_form'
    end
  end

  def recipient_complete
    @account = Account.find(params[:id])
  end

  def number_check
  end

  def number_confirm
    @user = User.find(params[:id])
    if @user.number == params[:number]
      @account = Account.new(:status => 3)
      @account.build_recipient(:organization_id => params[:organization_id],
                               :user_id => params[:id])
      @group_ids = []
      render 'recipient_form'
    else
      flash[:error] = "受信者登録画面に行けません。登録番号を再入力して下さい。"
      render 'number_check'
    end
  end

  def editor_user
    @user = User.find(params[:id])
    render 'user_form'
  end

  def user_up_before_confirm
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

  def user_up
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    return render 'user_form' if params[:cancel]
    @user.update_user_group(params[:user_group])
    ActiveRecord::Base.transaction do
      @user.save!
    end
    flash[:notice] = "ユーザー情報を更新しました。"
    render 'user_complete'
  end

end
