class Sentence < ActiveRecord::Base

  attr_accessible :subject, :body,  :group_name,  :depth, :organization_id

  def parent_name
    Sentence.find(self.parent_sentence_id).full_group_name if self.parent_sentence_id
  end

  def full_group_name
    if self.depth > 1
      sentece_groups = []
      sentece_groups << self.group_name
      thegroup = self
      (self.depth - 1).times do |i|
        thegroup = Sentence.find(thegroup.parent_sentence_id)
        sentece_groups << thegroup.group_name
      end
      name = ""
      self.depth.times do |i|
        name = name + sentece_groups.pop
      end
    else
      name = self.group_name
    end
    return name
  end

  def child_sentences
    unless Sentence.find(:first, :conditions => ["parent_sentence_id=?", self.id]).blank?
      return Sentence.find(:all, :conditions => ["parent_sentence_id=?", self.id], :order => 'subject')
    end
    false
  end

end
