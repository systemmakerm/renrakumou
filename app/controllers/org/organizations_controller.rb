class Org::OrganizationsController < ApplicationController
  
  layout :select_org_layout

  NEWACTIONS = ['new', 'create_before_confirm', 'create', 'complete_after_create',
                'activate', 'decide_complete', 'decide_create_complete', 'complete']

  NORMALACTIONS = ['org_list', 'show', 'edit', 'update_before_confirm', 'update',
                   'dissolve', 'org_stop', 'super_admin_dissolve', 'sadmin_stop_or_restart',
                   'account_change', 'change_before_confirm', 'create_and_change_account',
                   'sadmin_org_show']

  SIMPLEACTIONS = ['user_url', 'rec_url']

  def select_org_layout
    if NEWACTIONS.include?(params[:action])
      return 'neworg'
    elsif NORMALACTIONS.include?(params[:action])
      return 'application'
    elsif SIMPLEACTIONS.include?(params[:action])
      return 'simple'
    end
  end

  def org_list
    organization_scope = Organization.scoped(:conditions => ["accounts.status > ?", 0], :include => :account)
    @organizations = organization_scope.all
  end

  def show
    if (current_account.status == 1 && params[:id].to_i == current_account.organization.id) ||
        (current_account.status == 2 && params[:id].to_i == current_account.administrator.organization.id)
      @organization = Organization.find(params[:id])
    else
      logout_killing_session!
      redirect_back_or_default('/')
    end
  end

  def new
    @account = Account.new(:status => 1)
    render_form
  end

  def create_before_confirm
    @account = Account.new(params[:account])
    @account.build_organization(params[:account][:organizations_attributes])
    if @account.valid?
      render 'confirmation'
    else
      render_form
    end
  end

  def create
    @account = Account.new(params[:account])
    @account.status = 1
    @account.build_organization(params[:account][:organizations_attributes])
    return render 'form' if params[:cancel]
    @account.register! if @account && @account.valid?
    success = @account && @account.valid?
    if success && @account.errors.empty?
      redirect_to complete_after_create_org_organizations_path
    else
      flash[:error]  = "団体登録できませんでした。 再試行するか、または管理者に連絡してください。"
      render_form
    end
  end

  def complete_after_create
    render 'pre_complete'
  end

  def activate
    logout_keeping_session!
    account = Account.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && account && !account.active?
      account.activate!
      redirect_to decide_complete_org_organizations_path(:id=>account.id)
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default(root_path)
    else
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_path)
    end
  end

  def decide_complete
    @account = Account.find(params[:id])
  end

  def decide_create_complete
    @organization = Account.find(params[:id]).organization
    @organization.valid_date = Date.today + 31
		ActiveRecord::Base.transaction do
      @organization.save!
    end
    @organization.domain_create
    @organization.rec_addr_qr_create
    return redirect_to complete_org_organizations_path(:id=> @organization.account.id)
  end

  def complete
    @account = Account.find(params[:id])
  end

  def edit
    @organization = Organization.find(params[:id])
    @prefecture = @organization.prefecture
    @purpose = @organization.purpose
    render 'editor_org'
  end

  def update_before_confirm
    @organization = Organization.find(params[:id])
    @organization.attributes = params[:organization]
    if @organization.valid? && @organization.password_check?(params[:account])
      return render 'editor_confirmation'
    else
      @organization.errors.full_messages
      @organization.password_error_messages(params[:account])
      render_editor_org
    end
  end

  def update
    @organization = Organization.find(params[:id])
    @organization.attributes = params[:organization]
    return render_editor_org if params[:cancel]
    if @organization.valid? && @organization.password_check?(params[:account])
      ActiveRecord::Base.transaction do
        @organization.save!
        if @organization.password_update?(params[:account])
          account = @organization.account
          account.attributes = params[:account]
          account.save!
        end
      end
      flash[:notice] = "団体編集が完了しました。\n"
      redirect_to org_organization_path(@organization)
    else
      @organization.errors.full_messages
      @organization.password_error_messages(params[:account])
      render_editor_org
    end
  end

  def dissolve
    @organization = Organization.find(params[:id])
  end

  def org_stop
    @organization = current_account.organization
    @organization.valid_date = Date.today
    @organization.save!
    OrganizationMailer.deliver_dissolve(params[:comment], @organization.name)
    logout_killing_session!
    render 'dissolve_complete'
  end

  def sadmin_org_show
    @organization = Organization.find(params[:id])
    render 'show'
  end

  def super_admin_dissolve
    @organization = Organization.find(params[:id])
  end

  def sadmin_stop_or_restart
    date = params[:date]
    organization = Organization.find(params[:id])
    if params[:restart]
      organization.valid_date = Date.new(date["va_date(1i)"].to_i, date["va_date(2i)"].to_i, date["va_date(3i)"].to_i)
      flash[:notice] = "団体コード：#{organization.id}、団体名：#{organization.name}の" + "運用を再開しました。"
    else
      organization.valid_date = Date.today
      flash[:notice] = "団体コード：#{organization.id}、団体名：#{organization.name}の" + "運用を停止しました。"
    end
    ActiveRecord::Base.transaction do
      organization.save!
    end
    redirect_to org_list_org_organizations_path
  end

  def account_change
    @organization = Organization.find(params[:id])
    @account = Account.new
    @login = @login_confirmation = @organization.account.login
  end

  def change_before_confirm
    @organization = Organization.find(params[:id])
    @account = Account.new(params[:account])
    if @account.valid?
      return render 'account_change_confirmation'
    else
      @login = params[:account][:login]
      @login_confirmation = params[:account][:login_confirmation]
      render 'account_change'
    end
  end

  def create_and_change_account
    @account = Account.new(params[:account])
    @organization = Organization.find(params[:id])
    if params[:cancel]
      @login = params[:account][:login]
      @login_confirmation = params[:account][:login_confirmation]
      return render 'account_change'
    end
    @account.attributes = {:status => 0,
                          :state => 'active',
                          :activated_at => Time.now
    }
    ActiveRecord::Base.transaction do
      @account.save!
    end
    organization = Organization.find(params[:id])
    organization.account_id = @account.id
    organization.save!
    @account.status = 1
    ActiveRecord::Base.transaction do
      @account.save!
    end
    flash[:notice] = "団体コード：#{organization.id}、団体名：#{organization.name}の" + "メールアドレス・パスワードの変更が完了しました。"
    return redirect_to org_list_org_organizations_path
  end

  def user_url
    @organization = current_account.organization
  end

  def rec_url
    @organization = current_account.organization
  end

  private

  def render_form
    if params[:organization].present?
      @prefecture= params[:organization][:prefecture] ||= "島根県"
      @purpose = params[:organization][:purpose]
    else
      @prefecture= "島根県"
      @purpose = "会社関係"
    end
    render 'form'
  end

  def render_editor_org
    @prefecture = params[:organization][:prefecture]
    @purpose = params[:organization][:purpose]
    render 'editor_org'
  end

end
