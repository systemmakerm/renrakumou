class Org::Useradmin::CsvImportsController < ApplicationController
  require 'csv'
  with_options :redirect_to => :root_url do |con|
    con.verify :method => :post, :only => %w[upload_and_confirm create]
  end

  def index
  end

  def upload_and_confirm
    if params[:file].blank?
      flash[:notice] = "ファイルが選択されていません。"
      return redirect_to org_useradmin_csv_imports_url
    end
    @users = User.parse_user_csv(params)
    if @users.any?{|user| user.valid? }
      render 'confirm'
    else
      render 'index'
    end
  end

  def create
    return redirect_to org_useradmin_csv_imports_url if params[:cancel]
    @users = User.create_users(params[:user], current_account)
    ActiveRecord::Base.transaction do
      @users.each {|user| user.save! }
    end
    redirect_to complete_org_useradmin_csv_imports_url
  rescue => e
    flash[:notice] = "保存に失敗しました。"
    logger.debug{ "#{e.class}.#{e.message}" }
    return redirect_to org_useradmin_csv_imports_url
  end

  def complete
  end

  def template_downloadable
    template = ''
    CSV::Writer.generate(template, ',') {|csv| csv << ["登録番号",  "名前", "メモ" ]}
    send_data(template, :filename => 'user_template.csv')
  end
end
