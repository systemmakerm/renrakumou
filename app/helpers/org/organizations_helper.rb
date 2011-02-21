module Org::OrganizationsHelper

  PREFECTURE = %w(北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県
                  茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
                  新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県 静岡県
                  愛知県 三重県 滋賀県 京都府 大阪府 兵庫県 奈良県 和歌山県
                  鳥取県 島根県 岡山県 広島県 山口県 徳島県 香川県 愛媛県 高知県
                  福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県)

	PURPOSE = %w(会社関係 学校関係 自治体 サークル その他の組織 友達・仲間 家族・親族 その他)

  def select_purpose
    PURPOSE.collect{|value| [value, value]}
  end

  def form_params
    if @account.new_record?
      {:url => create_before_confirm_org_organizations_path,
        :model_instance => @account, :method => :post}
    else
      {:url => update_before_confirm_org_organizations_path(:id => @account.id),
        :model_instance => @account, :method => :post}
    end
  end

  def confirmation_params
    if @account.new_record?
      {:url => org_organizations_path,
        :model_instance => @account, :method => :post}
    else
      {:url => org_organization_path(@account),
        :model_instance => @account, :method => :put}
    end
  end

  
  def stop_or_restart(organization)
     if organization.valid_date > Date.today
       link_to "停止する", super_admin_dissolve_org_organizations_path(:id => organization.id)
     else
       link_to "再開する", super_admin_dissolve_org_organizations_path(:id => organization.id)
     end
  end

  def superadmin_change?(organization)
    if organization.account.status == 0
      link_to("変更", account_change_org_organizations_path(:id => organization.id))
    end
  end

end
