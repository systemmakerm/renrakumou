class Org::SentencesController < ApplicationController

  layout "simple", :only => :insert_list
  layout "application", :only => [:index, :new, :create, :edit, :show, :update, :delete]

  def index
    @sentences = Sentence.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
  end

  def new
    @sentence = Sentence.new
    @sentences = Sentence.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
    @parent_sentence_id = 0
    render 'form'
  end

  def create
    @sentence = Sentence.new(params[:sentence])
    @sentence.organization_id = current_account.organization.id
    if params[:sentence][:parent_sentence_id].to_i == 0
      @sentence.depth = 1
    else
      @sentence.parent_sentence_id = params[:sentence][:parent_sentence_id].to_i
      @sentence.depth = Sentence.find(params[:sentence][:parent_sentence_id]).depth + 1
    end
    if @sentence.valid?
      @sentence.save!
      flash[:notice] = "メールひな形登録しました。\n"
      return redirect_to org_sentences_path
    else
      @sentences = Sentence.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
      @parent_sentence_id = params[:sentence][:parent_sentence_id].to_i
      render 'form'
    end
  end

  def edit
    @sentence = Sentence.find(params[:id])
    @sentences = Sentence.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
    @parent_sentence_id = @sentence.parent_sentence_id
    render 'form'
  end

  def show
    @sentence = Sentence.find(params[:id])
  end

  def update
    @sentence = Sentence.find(params[:id])
    @sentence.attributes = params[:sentence]
    @sentence.organization_id = current_account.organization.id
    if params[:sentence][:parent_sentence_id].to_i == 0
      @sentence.depth = 1
    else
      @sentence.parent_sentence_id = params[:sentence][:parent_sentence_id].to_i
      @sentence.depth = Sentence.find(params[:sentence][:parent_sentence_id]).depth + 1
    end
    if @sentence.valid?
      @sentence.save!
      flash[:notice] = "メールひな形登録しました。\n"
      return redirect_to org_sentences_path
    else
      @sentences = Sentence.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
      @parent_sentence_id = params[:sentence][:parent_sentence_id].to_i
      render 'form'
    end
  end

  def delete 
    sentence = Sentence.find(params[:id])
    sentences = []
    sentences << sentence
    unless sentence.child_sentences
      sentence.child_sentences.each do |child|
        sentences << child
        unless child.child_sentences
          child.child_sentences.each do |grand_child|
            sentences << grand_child
          end
        end
      end  
    end
    sentences.each do |the_sentence|
      the_sentence.destroy
    end
    flash[:notice] = "メールひな形削除しました。\n"
    redirect_to org_sentences_path
  end

  def insert_list
    @sentences = Sentence.find(:all, :conditions => ["organization_id=? and depth=?", current_account.organization.id, 1])
  end

  def detail
    @sentence = Sentence.find(params[:id])
  end

end
