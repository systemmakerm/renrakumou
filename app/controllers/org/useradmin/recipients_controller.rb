class Org::Useradmin::RecipientsController < ApplicationController

  
  def new
    user_id= params[:user_id] ||=params[:recipient][:user_id]
    @account = Account.new(:status => 3)
    @account.build_recipient(:organization_id => current_account.organization.id,
                             :user_id => user_id)
    @user = User.find(user_id)
    @group_ids = []
    render 'recipient_form'
  end

  def edit
    recipient = Recipient.find(params[:id])
    @account = recipient.account
    @user = recipient.user
    @group_ids = recipient.recipient_group_check
    render 'recipient_form'
  end

  def show
    @recipient = Recipient.find(params[:id])
    @user = @recipient.user
  end

  def detail
    @recipient = Recipient.find(params[:id])
    @user = @recipient.user
  end

  def create_before_confirm
    @user = User.find(params[:account][:recipient_attributes][:user_id])
    @account = Account.new(params[:account])
    @account.build_recipient(params[:account][:recipient_attributes])
    if params[:recipient_group].present?
      @recipient_groups = Group.find(:all, :conditions => ["id in (?)", params[:recipient_group]])
    end
    if @account.valid? && @account.recipient_email_uniq_in_user?(params[:account][:login])
      return render 'recipient_confirmation'
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
      return render 'recipient_confirmation'
    else
      return render 'recipient_form'
    end
  end

  def create
    @account = Account.new(params[:account])
    @account.build_recipient(params[:account][:recipient_attributes])
    @user = User.find(params[:account][:recipient_attributes][:user_id])
    return render 'recipient_form' if params[:cancel]
    @account.recipient.build_recipient_groups(params[:recipient_group])
    @account.attributes = {:status => 4,
                           :state => 'active',
                           :activated_at => Time.now}
    if @account.valid? && @account.recipient_email_uniq_in_user?(params[:account][:login])
      ActiveRecord::Base.transaction do
        @account.save!
      end
      return redirect_to recipient_complete_org_useradmin_recipients_path(:account_id => @account.id)
    else
      @account.errors.full_messages
      render 'recipient_form'
    end
  end

  def recipient_complete
    @account = Account.find(params[:account_id])
    @user = @account.recipient.user
  end

  def update
    @account = Account.find(params[:id])
    @account.attributes = {:login => params[:account][:login],
                           :login_confirmation => params[:account][:login_confirmation]}
    if params[:account][:password].present? || params[:account][:password_confirmation].present?
      @account.attributes = {:password => params[:account][:password],
                             :password_confirmation => params[:account][:password_confirmation]}
    end
    @account.recipient.attributes = params[:account][:recipient_attributes]
    @user = @account.recipient.user
    return render 'recipient_form' if params[:cancel]
    @account.recipient.update_recipient_group(params[:recipient_group])
    if @account.valid? && @account.recipient_email_uniq_in_user?(params[:account][:login], @account.recipient.id)
      ActiveRecord::Base.transaction do
        @account.save!
      end
      return redirect_to recipient_complete_org_useradmin_recipients_path(:account_id=>@account.id)
    else
      @account.errors.full_messages
      render 'recipient_form'
    end
  end

  def delete
    recipient = Recipient.find(params[:id])
    user = recipient.user
    account = recipient.account
    account.destroy
    flash[:notice] = "受信者を削除しました。"
    redirect_to detail_org_useradmin_users_path(:id => user.id)
  end

  def editor
    recipient = Recipient.find(params[:id])
    @account = recipient.account
    render 'recipient_form'
  end
  
end
