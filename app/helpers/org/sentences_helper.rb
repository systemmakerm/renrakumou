module Org::SentencesHelper

  def form_params
    if @sentence.new_record?
      {:url => org_sentences_path, :method => :post}
    else
      {:url => org_sentence_path(:id => @sentence.id), :method => :put}
    end
  end

  def parent_id?(sentence_id, parent_sentence_id)
    return true if sentence_id == parent_sentence_id
    false
  end

end
