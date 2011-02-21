module Org::AdministratorsHelper


  def form_params
		if @account.new_record?
      {:url => create_before_confirm_org_administrators_path, :method => :post}
    else
      {:url => update_before_confirm_org_administrators_path(:id => @account.id), :method => :post}
    end
  end

  def confirmation_params
    if @account.new_record?
      {:url => org_administrators_path, :method => :post}
    else
      {:url => org_administrator_path(@account), :method => :put}
    end
  end

end
