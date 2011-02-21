class Org::GroupsController < ApplicationController
  
  def index
    @groups = Group.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
  end

  def new
    @group = Group.new
    @groups = Group.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
    @parent_id = 0
    render 'form'
  end

  def create
    @group = Group.new(params[:group])
    @group.organization_id = current_account.organization.id
    if params[:group][:parent_id].to_i == 0
      @group.depth = 1
    else
      @group.parent_id = params[:group][:parent_id].to_i
      @group.depth = Group.find(params[:group][:parent_id]).depth + 1
    end
    if @group.valid?
      @group.save!
      flash[:notice] = "グループ登録しました。\n"
      return redirect_to org_groups_path
    else
      @groups = Group.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
      @parent_id = params[:group][:parent_id].to_i
      render 'form'
    end
  end

  def edit
    @group = Group.find(params[:id])
    @groups = Group.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
    @parent_id = @group.parent_id
    render 'form'
  end

  def show
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    @group.attributes = params[:group]
    @group.organization_id = current_account.organization.id
    if params[:group][:parent_id].to_i == 0
      @group.depth = 1
    else
      @group.parent_id = params[:group][:parent_id].to_i
      @group.depth = Group.find(params[:group][:parent_id]).depth + 1
    end
    if @group.valid?
      @group.save!
      flash[:notice] = "グループ登録しました。\n"
      return redirect_to org_groups_path
    else
      @groups = Group.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
      @parent_id = params[:group][:parent_id].to_i
      render 'form'
    end
  end

  def delete
    group = Group.find(params[:id])
    unless group.child_groups.blank?
      group.child_groups.each do |child|
        unless child.child_groups.blank?
          child.child_groups.each do |grand_child|
            grand_child.destroy
          end
        end
        child.destroy
      end
    end
    group.destroy
    flash[:notice] = "グループを削除しました。"
    redirect_to org_groups_path
  end
  
end
