module Org::Useradmin::GroupsHelper
  def selectable_groups(organization_id, selected_value)
    value = selected_value.to_i if selected_value.present?

    groups = Group.by_organization_depth_one(organization_id)
    list = [['', '']]
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
end
