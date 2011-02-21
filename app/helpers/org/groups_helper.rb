module Org::GroupsHelper

  def form_params
    if @group.new_record?
      {:url => org_groups_path, :method => :post}
    else
      {:url => org_group_path(:id => @group.id), :method => :put}
    end
  end

  def select_group(org_id)
    top_groups = Group.find(:all, :conditions => ["organization_id=? and parent_id=?", org_id, nil])
    top_groups.each do |group|
      if groups = Group.find(:all, :conditions => ["parent_id=?", group.parent_id])
      end
    end
  end

  def parent_id?(group_id, parent_id)
    return true if group_id == parent_id
    false
  end

end
