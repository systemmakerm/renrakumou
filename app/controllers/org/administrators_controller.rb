class Org::AdministratorsController < ApplicationController


  def index
    @administrators = Administrator.find(:all, :conditions => ["organization_id=?", current_account.organization.id])
    @administrators = @administrators.paginate(paginate_options.merge(:order => :name))
  end

  def new
    @account = Account.new
    @account.build_administrator(:organization_id => current_account.organization.id)
    render 'form'
  end

  def edit
    administrator = Administrator.find(params[:id])
    @account = administrator.account
    render 'form'
  end

  def show
    @administrator = Administrator.find(params[:id])
  end

  def create_before_confirm
    @account = Account.new(params[:account])
    @account.build_administrator(params[:account][:administrator_attributes])
    if @account.valid?
      return render 'confirmation'
    else
      render 'form'
    end
  end

  def update_before_confirm
    @account = Account.find(params[:id])
    @account.administrator.attributes = params[:account][:administrator_attributes]
    if params[:account][:password].present? || params[:account][:password_confirmation].present?
      @account.attributes = {:password => params[:account][:password],
                             :password_confirmation => params[:account][:password_confirmation]
      }
    end
    if @account.valid?
      return render 'confirmation'
    else
      render 'form'
    end
  end

  def create
    @account = Account.new(params[:account])
    @account.build_administrator(params[:account][:administrator_attributes])
    return render 'form' if params[:cancel]
    @account.attributes = {:status => 2,
                          :state => 'active',
                          :activated_at => Time.now
    }
    if @account.valid?
      ActiveRecord::Base.transaction do
        @account.save!
      end
      flash[:notice] = "管理者名：#{@account.administrator.name}を登録しました。"
      return redirect_to org_administrators_path
    else
      render 'form'
    end
  end

  def update
    @account = Account.find(params[:id])
    @account.administrator.attributes = params[:account][:administrator_attributes]
    if params[:account][:password].present? || params[:account][:password_confirmation].present?
      @account.attributes = {:password => params[:account][:password],
                             :password_confirmation => params[:account][:password_confirmation]
      }
    end
    return render 'form' if params[:cancel]
    @account.attributes = {:status => 2,
                          :state => 'active',
                          :activated_at => Time.now
    }
    if @account.valid?
      ActiveRecord::Base.transaction do
        @account.save!
      end
      flash[:notice] = "管理者名：#{@account.administrator.name}を登録しました。"
      return redirect_to org_administrators_path
    else
      render 'form'
    end
  end

  def delete_admin
    account = Administrator.find(params[:admin_id]).account
    admin_name = account.administrator.name
    account.administrator.destroy
    flash[:notice] = "管理者名：#{admin_name}を削除しました。"
    return redirect_to org_administrators_path
  end

  private
  
    def paginate_options
      {:page => params[:page], :per_page => 20}
    end
  
end
