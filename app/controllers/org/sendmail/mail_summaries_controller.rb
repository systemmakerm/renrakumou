class Org::Sendmail::MailSummariesController < ApplicationController

  layout "simple", :only => [:get_answer, :detail_error]
  layout "application", :only => [:index, :new, :show, :edit, :create_body_before_confirm,
                                  :create_before_confirm, :update_body_before_confirm,
                                  :update_before_confirm, :create, :update, :delete, 
                                  :search, :detail, :editor]
  
  def index
    @mail_summaries = MailSummary.find(:all, :conditions => ["organization_id=?", current_account.organization.id], :order => "updated_at DESC")
    @mail_summaries = @mail_summaries.paginate(paginate_options)
  rescue
    redirect_to root_path
  end

  def new
    @mail_summary = MailSummary.new(:organization_id => current_account.organization.id,
                                    :all_send => 0,
                                    :relation => 0)
    @mail_summary.build_delivery_reserve_time(:delivery_reserve_time => Time.now + 3600,
                                              :organization_id => current_account.organization.id)
    @groups = Group.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
    @select_delivery = "0"
    @selection_bodies = Array.new(10)
    @selection_bodies.fill { "" }
    render_form
  end

  def detail
    @mail_summary = MailSummary.find(params[:id])
  end

  def show
    @mail_summary = MailSummary.find(params[:id])
  end

  def editor
    @mail_summary = MailSummary.find(params[:id])
    @check_groups = []
    if @mail_summary.mail_groups.present?
      @check_groups = @mail_summary.mail_groups.map{|mail_group| mail_group.group}
    end
    @check_users = []
    if @mail_summary.mail_users.present?
      @check_users = @mail_summary.mail_users.map{|mail_user| mail_user.user}
    end
    @check_recipients = []
    if @mail_summary.mail_recipients.present?
      @check_recipients = @mail_summary.mail_recipients.map{|mail_recipient| mail_recipient.recipient}
    end
    @mail_summary.delivery_reserve_time.nil? ? @select_delivery = "0" : @select_delivery = "1"
    @selection_bodies = []
    selections = @mail_summary.sorted_selections unless @mail_summary.selections.blank?
    1.upto(10) do |i|
      selections.blank? ? @selection_bodies << "" : @selection_bodies << selections.shift.body
    end
    render_form
  end

  def create_body_before_confirm
    @mail_summary = MailSummary.new(params[:mail_summary])
    params_attributes
    if @mail_summary.valid?
      return render_select_send_schedule
    else
      render_form
    end
  end

  def create_before_confirm
    @mail_summary = MailSummary.new(params[:mail_summary])
    params_attributes
    return render 'form' if params[:cancel]
    if @mail_summary.valid?
      return render 'confirmation'
    else
      render_select_send_schedule
    end
  end


  def update_body_before_confirm
    @mail_summary = MailSummary.find(params[:id])
    @mail_summary.attributes = params[:mail_summary]
    params_attributes
    if @mail_summary.valid?
      return render_select_send_schedule
    else
      render 'form'
    end
  end

  def update_before_confirm
    @mail_summary = MailSummary.find(params[:id])
    @mail_summary.attributes = params[:mail_summary]
    params_attributes
    return render 'form' if params[:cancel]
    if @mail_summary.valid?
      return render 'confirmation'
    else
      render_select_send_schedule
    end
  end

  def create
    @mail_summary = MailSummary.new(params[:mail_summary])
    @mail_summary.organization_id = current_account.organization.id
    params_attributes
    return render_select_send_schedule if params[:cancel]
    if @mail_summary.all_send != 1
      @check_groups.each do |group|
        @mail_summary.group_build(group.id)
      end
      @check_users.each do |user|
        @mail_summary.user_build(user.id)
      end
      @check_recipients.each do |recipient|
        @mail_summary.recipient_build(recipient.id)
      end
      @mail_summary.all_send = 0
    end
    @mail_summary.builds_selections(@selection_bodies)
    if @mail_summary.valid?
      ActiveRecord::Base.transaction do
        @mail_summary.save!
      end
      if params[:just_delivery]
        @mail_summary.just_delivery
        flash[:notice] = "メールを保存し、送信しました。"
      else
        flash[:notice] = "メールを保存しました。"
      end
      return redirect_to org_sendmail_mail_summaries_path
    else
      render_select_send_schedule
    end
  end

  def update
    @mail_summary = MailSummary.find(params[:id])
    @mail_summary.attributes = params[:mail_summary]
    params_attributes
    return render_select_send_schedule if params[:cancel]
    if @mail_summary.all_send != 1
      param_group_ids = []
      param_group_ids = @check_groups.map{|group| group.id} if @check_groups.present?
      @mail_summary.update_mail_groups(param_group_ids)
      param_user_ids = []
      @check_users.each{|user| param_user_ids << user.id} if @check_users.present?
      @mail_summary.update_mail_users(param_user_ids)
      param_recipient_ids = []
      @check_recpients.each{|recipient| param_recipient_ids << recipient.id} if @check_recpients.present?
      @mail_summary.update_mail_recipients(param_recipient_ids)
      @mail_summary.all_send = 0
    else
      @mail_summary.delete_groups_users_recs
    end
    @mail_summary.update_selections(@selection_bodies)
    @mail_summary.delivery_reserve_time.destroy if @mail_summary.delivery_reserve_time && params[:select_delivery] == "0"
    if @mail_summary.valid?
      ActiveRecord::Base.transaction do
        @mail_summary.save!
      end
      if params[:just_delivery]
        @mail_summary.just_delivery
        flash[:notice] = "メールを保存し、送信しました。"
      else
        flash[:notice] = "メールを保存しました。"
      end
      return redirect_to org_sendmail_mail_summaries_path
    else
      render_select_send_schedule
    end
  end

  def delete
    mail_summary = MailSummary.find(params[:id])
    mail_summary.destroy
    flash[:notice] = "メールを削除しました。"
    redirect_to org_sendmail_mail_summaries_path
  end

  def get_answer
    @recipient = Recipient.find(params[:recipient_id])
    @selection = Selection.find(params[:id])
    @mail_summary = @selection.mail_summary
    if answer = Answer.find(:first, :conditions => ["mail_summary_id=? and recipient_id=?", @mail_summary.id, @recipient.id])
      answer.number = @selection.number
      answer.save!
    else
      @mail_summary.answers.build(:organization_id => @mail_summary.organization_id,
                                :recipient_id => @recipient.id,
                                :number => @selection.number)
      @mail_summary.save!
    end
  end

  def search
    @mail_summary = MailSummary.find(params[:id])
    if params[:mail_retry]
      @mail_summary.select_delivery(params[:recipient])
      flash[:notice] = "メールを再送信しました。"
      return redirect_to org_sendmail_mail_summaries_path
    end    
    @recipient_scope = Recipient.scoped(:conditions => ["organization_id=?", current_account.organization.id])
    if @mail_summary.all_send != 1
      scope_by_group_id
      scope_by_name if params[:name]
      scope_by_ans_situation if params[:ans_situation] != "0"
    end
    scope_by_relation if @mail_summary.relation != 0
    @recipients = @recipient_scope.all(:order => "user_id")
    @recipients = @recipients.paginate(paginate_options)
    @recipients.blank? ? flash[:notice] = "検索結果：0人" : "検索結果：#{@recipients.count}人"
    return render 'detail'
  end

  def detail_error
    @error_mail = ErrorMail.find(params[:id])
    @mail_summary = MailSummary.find(params[:mail_summary_id])
  end

  private

    def render_form
      render 'form'
    end

    def render_select_send_schedule
      @groups = Group.find(:all,
        :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
      render 'select_send_schedule'
    end

    def params_attributes
      @selection_bodies = []
      if params[:selection].present?
        params[:selection].each do |body|
          @selection_bodies << body
        end
      end
      if params[:select_delivery] == "1" && @mail_summary.delivery_reserve_time
        @mail_summary.delivery_reserve_time.attributes = params[:mail_summary][:delivery_reserve_time_attributes]
      elsif params[:select_delivery] == "1"
        @mail_summary.build_delivery_reserve_time(params[:mail_summary][:delivery_reserve_time_attributes])
        @mail_summary.delivery_reserve_time.organization_id = current_account.organization.id
      end
      if params[:mail_summary][:all_send]
        @mail_summary.all_send = params[:mail_summary][:all_send]
      end
      if params[:mail_summary][:relation]
        @mail_summary.relation = params[:mail_summary][:relation]
      end
      @check_groups = []
      if params[:mail_group].present?
        params[:mail_group].each do |group_id|
          @check_groups << Group.find(group_id)
        end
      end
      @check_users = []
      if params[:mail_user].present?
        params[:mail_user].uniq!
        params[:mail_user].each do |user_id|
          @check_users << User.find(user_id)
        end
      end
      @check_recipients = []
      if params[:mail_recipient].present?
        params[:mail_recipient].uniq!
        params[:mail_recipient].each do |recipient_id|
          @check_recipients << Recipient.find(recipient_id)
        end
      end
      @select_delivery = params[:select_delivery]
    end

    def scope_by_group_id
      if params[:group_id] != "0"
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
      else
        group_ids = @mail_summary.mail_groups.map(&:group_id) if @mail_summary.mail_groups.present?
      end
      mail_user_ids = MailUser.find(:all, :conditions => ["mail_summary_id = ?", @mail_summary.id]).map(&:user_id)
      group_user_ids = UserGroup.find(:all, :conditions=>["organization_id = ? and group_id in (?)",
                                  current_account.organization.id, group_ids]).map(&:user_id)
      user_ids = mail_user_ids | group_user_ids
      users = User.find(:all, :conditions => ["id in (?)", user_ids])
      user_recipis = []
      users.each do |user|
        user_recipis << user.recipients unless user.recipients.blank?
      end
      user_recipis.flatten!
      recipi_ids = RecipientGroup.find(:all, :conditions=>["group_id in (?)", group_ids]).map(&:recipient_id)
      recipients = Recipient.find(:all, :conditions => ["id in (?)", recipi_ids])
      result_recipi_ids = (user_recipis | recipients).map(&:id)
      if @mail_summary.mail_recipients.present?
        mail_recipient_ids = @mail_summary.mail_recipients.map(&:recipient_id) 
        result_recipi_ids = result_recipi_ids | mail_recipient_ids
      end
      @recipient_scope = @recipient_scope.scoped(:conditions => ["id in (?)", result_recipi_ids])
    end

    def scope_by_name
      user_ids = User.find(:all, :conditions => ["name like ?", "%#{params[:name]}%"]).map(&:id)
      @recipient_scope = @recipient_scope.scoped(:conditions => ["user_id in (?)", user_ids])
    end

    def scope_by_ans_situation
      ans_rec_ids = Answer.find(:all, :conditions => ["mail_summary_id=?", @mail_summary.id]).map(&:recipient_id)
      if params[:ans_situation] == "1"
        @recipient_scope = @recipient_scope.scoped(:conditions => ["id in (?)", ans_rec_ids])
      elsif params[:ans_situation] == "2"
        all_recipient_ids = @mail_summary.all_recipient_ids
        @recipient_scope = @recipient_scope.scoped(:conditions => ["id in (?)", all_recipient_ids - ans_rec_ids])
      end
    end

    def scope_by_relation
      if @mail_summary.relation == 1
        @recipient_scope = @recipient_scope.scoped(:conditions => ["relation = ?", "本人"])
      elsif @mail_summary.relation == 2
        @recipient_scope = @recipient_scope.scoped(:conditions => ["relation <> ?", "本人"])
      end
    end

    def paginate_options
      {:page => params[:page], :per_page => 20}
    end

end
