# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  PREFECTURE = %w(北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県
                  茨城県 栃木県 群馬県 埼玉県 千葉県 東京都 神奈川県
                  新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県 静岡県
                  愛知県 三重県 滋賀県 京都府 大阪府 兵庫県 奈良県 和歌山県
                  鳥取県 島根県 岡山県 広島県 山口県 徳島県 香川県 愛媛県 高知県
                  福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県)



  # チェックボックスがチェックされていたかを判定する。
  #
  # ===== 引数 =====
  #
  # * value - チェックボックスのvalueの値
  # * params - パラメータ
  def checkbox_is_selected?(params, value)
    return params.include?(value.to_s) if params
    false
  end

  def select_prefectures
    PREFECTURE.collect{|pref| [pref, pref]}
  end


  def options_for_group(organization_id, selected_value=nil)
    unless selected_value.nil?
      value = selected_value.to_i
    end
    groups = Group.find(:all, :conditions=>["organization_id=? and depth=?", organization_id, 1])
    list = [["全て", 0]]
    groups.each do |group|
      list << [group.full_name, group.id]
      if group.child_groups
        group.child_groups.each do |child|
          list << [child.full_name, child.id]
          if child.child_groups
            child.child_groups.each do |grand_child|
              list << [grand_child.full_name, grand_child.id]
            end
          end
        end
      end
    end
    options_for_select(list, value)
  end
  
  def mobile_tree_groups
    if @groups.present?
      group_ids     = params[:mail_group].blank? ? @check_groups : params[:mail_group]
      user_ids      = params[:mail_user].blank? ? @check_users : params[:mail_user]
      recipient_ids = params[:mail_recipient].blank? ? @check_recipients : params[:mail_recipient]
      html = []
      html << content_tag(:ul, :style => "list-style:none;") do
        ul = []
        @groups.each do |group|
          ul << content_tag(:li) do
            list = []
            list << check_box_tag("mail_group[]", group.id,
                                  checkbox_is_selected?(group_ids, group.id), :id =>"group_#{group.id}")
            list << label_tag("group_#{group.id}", h(group.name))

            if group.child_groups.present? || group.user_group_users.present? || group.group_recipients.present?
              if group.child_groups.present?
                ul_child = []
                list << content_tag(:ul, :style => "list-style: none;") do
                  group.child_groups.each_with_index do |child, i|
                    ul_child << content_tag(:li) do
                      list_child = []
                      list_child << check_box_tag("mail_group[]", child.id,
                                                  checkbox_is_selected?(group_ids, child.id), :id =>"group_#{child.id}")
                      list_child << label_tag("group_#{child.id}", h(child.name))

                      if child.child_groups.present? || child.user_group_users.present? || child.group_recipients.present?
                        if child.child_groups.present?
                          list_child << content_tag(:ul, :style => "list-style: none;") do
                            ul_grand_child = []
                            child.child_groups.each_with_index do |grand_child, j|
                              ul_grand_child << content_tag(:li) do
                                list_grand_child = []
                                list_grand_child << check_box_tag("mail_group[]", grand_child.id,
                                                                  checkbox_is_selected?(group_ids, grand_child.id), :id =>"group_#{grand_child.id}")
                                list_grand_child << label_tag("group_#{grand_child.id}", h(grand_child.name) )

                                if grand_child.user_group_users.present? || grand_child.group_recipients.present?
                                  list_grand_child << content_tag(:ul, :style => "list-style: none;") do
                                    ul_grand_child_sub = []

                                    if grand_child.user_group_users.present?
                                      grand_child.user_group_users.each_with_index do |thr_user, k|
                                        ul_grand_child_sub << content_tag(:li) do
                                          list_grand_child_sub = []
                                          list_grand_child_sub << check_box_tag("mail_user[]", thr_user.id,
                                                                                checkbox_is_selected?(user_ids, thr_user.id), :id =>"user_#{thr_user.id}")
                                          list_grand_child_sub << label_tag("user_#{thr_user.id}", h(thr_user.name))
                                        end
                                      end
                                    end

                                    if grand_child.group_recipients.present?
                                      grand_child.user_group_users.each_with_index do |thr_rec, n|
                                        ul_grand_child_sub << content_tag(:li) do
                                          list_grand_child_sub = []
                                          list_grand_child_sub << check_box_tag("mail_recipient[]", thr_rec.id,
                                                                                checkbox_is_selected?(recipient_ids, thr_rec.id), :id =>"recipient_#{thr_rec.id}")
                                          list_grand_child_sub << label_tag("recipient_#{thr_rec.id}", h(thr_rec.name))
                                        end
                                      end
                                    end
                                    ul_grand_child_sub
                                  end
                                end
                                list_grand_child
                              end
                            end
                            ul_grand_child
                          end
                        end

                        if child.user_group_users.present? || child.group_recipients.present?
                          list_child << content_tag(:ul, :style => "list-style: none;") do
                            ul_grand_child = []
                            if child.user_group_users.present?
                              child.user_group_users.each_with_index do |sec_user, l|
                                ul_grand_child << content_tag(:li) do
                                  li = []
                                  li << check_box_tag("mail_user[]", sec_user.id,
                                                      checkbox_is_selected?(user_ids, sec_user.id), :id =>"user_#{sec_user.id}")
                                  li << label_tag("user_#{sec_user.id}", h(sec_user.name))
                                end
                              end
                            end

                            if child.group_recipients.present?
                              child.group_recipients.each_with_index do |sec_rec, o|
                                ul_grand_child << content_tag(:li) do
                                  li = []
                                  li << check_box_tag("mail_recipient[]", sec_rec.id,
                                                      checkbox_is_selected?(recipient_ids, sec_rec.id), :id =>"recipient_#{sec_rec.id}")
                                  li << label_tag("recipient_#{sec_rec.id}", h(sec_rec.name))
                                end
                              end
                            end
                            ul_grand_child
                          end
                        end

                      end
                    end
                  end
                  ul_child
                end

                # NOTE:トップレベルにぶら下がっているもの
                if group.user_group_users.present? || group.group_recipients.present?
                  list << content_tag(:ul, :style => "list-style: none;") do
                    user_or_recipient_list = []
                    if group.user_group_users.present?
                      group.user_group_users.each_with_index do |top_user, m|
                        user_or_recipient_list << content_tag(:li) do
                          li = []
                          li << check_box_tag("mail_user[]", top_user.id,
                                              checkbox_is_selected?(user_ids, top_user.id), :id =>"user_#{top_user.id}")
                          li << label_tag("user_#{top_user.id}", h(top_user.name))
                        end
                      end
                    end

                    if group.group_recipients.present?
                      group.group_recipients.each_with_index do |top_rec, p|
                        user_or_recipient_list << content_tag(:li) do
                          li = []
                          li << check_box_tag("mail_recipient[]", top_rec.id,
                                              checkbox_is_selected?(recipient_ids, top_rec.id), :id =>"recipient_#{top_rec.id}")
                          li << label_tag("recipient_#{top_rec.id}", h(top_rec.name))
                        end
                      end
                    end
                    user_or_recipient_list
                  end
                end

              end
            end
            list
          end
        end
        ul
      end
      return html
    end
  end

end
