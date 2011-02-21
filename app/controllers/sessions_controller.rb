class SessionsController < ApplicationController
 
  layout :select_session_layout

  NOTLOGIN = ['top', 'new', 'recipient_login', 'create', 'select_org',
              'destroy', 'rcnum', 'user_num_check']

  LOGGEDIN = []

  def select_session_layout
    if NOTLOGIN.include?(params[:action])
      return 'neworg'
    elsif LOGGEDIN.include?(params[:action])
      return 'application'
    end
  end

  def top
  end

  def new
  end

  def recipient_login
    logout_keeping_session!
    @accounts = Account.authenticate(params[:login], params[:password])
    unless @accounts.blank?
      return render 'organization_list'
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      logout_keeping_session!
      flash[:notice] = "ログインできませんでした。"
      return redirect_to recipient_login_sessions_path
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      logout_keeping_session!
      flash[:notice] = "ログインできませんでした。"
      render :action => 'recipient_login'
    end
  end

  def create
    logout_keeping_session!
    @accounts = Account.authenticate(params[:login], params[:password])
    unless @accounts.blank?
      return render 'organization_list'
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      logout_keeping_session!
      flash[:notice] = "ログインできませんでした。"
      return redirect_to root_path
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      logout_keeping_session!
      flash[:notice] = "ログインできませんでした。"
      render :action => 'new'
    end
  end

  def select_org
    if params[:id]
      self.current_account = Organization.find(params[:id]).account
    elsif params[:account_id]
      self.current_account = Account.find(params[:account_id])
    end
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    case current_account.status
    when 0
      return redirect_to org_list_org_organizations_path
    when 1
      vali_day = current_account.organization.valid_date
      if vali_day > Date.today
       return redirect_to org_organization_path(current_account.organization)
      end
    when 2
      vali_day = current_account.administrator.organization.valid_date
      if vali_day > Date.today
        return redirect_to org_organization_path(current_account.administrator.organization)
      end
    when 3
      vali_day = current_account.recipient.organization.valid_date
      if vali_day > Date.today
        return redirect_to detail_org_recipients_path(:id => current_account.recipient.id)
      end
    when 4
      vali_day = current_account.recipient.organization.valid_date
      if vali_day > Date.today
        return redirect_to detail_org_recipients_path(:id => current_account.recipient.id)
      end
    end
    logout_keeping_session!
    if vali_day > Date.today
      flash[:notice] = "ご登録の連絡網は有効期限が過ぎているためログインできませんでした。"
    else
      flash[:notice] = "ログインできませんでした。"
    end
    render :action => 'new'
  rescue
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
  end


  def destroy
    logout_killing_session!
    redirect_back_or_default('/renrakumou/session/new')
  end

  def rcnum
  end

  def user_num_check
    if @user = User.find(:first, :conditions => ["organization_id = ? and number = ?", params[:og], params[:number]])
      self.current_account = Account.find(params[:ac])
      return redirect_to editor_org_recipients_path(:user_id => @user.id, :ac => params[:ac])
    else
      flash[:error] = "登録番号に誤りがあります。再入力してください。"
      redirect_to rcnum_sessions_path(:og => params[:og], :ac => params[:ac])
    end
  end

protected

  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
