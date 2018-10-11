class IndicoResult
  include Mongoid::Document
  include Mongoid::Timestamps
  field :lookup, type: Hash
  field :classname, type: String
  field :field, type: String
  field :text_tags, type: Hash
  field :political, type: Hash
  field :sentiment, type: Float
  def self.from_raw(content, classname, lookup)
    obj = self.new
    obj.classname = classname
    obj.field = content.get(:field)
    obj.lookup = lookup
    obj.text_tags = content.get(:text_tags)
    obj.political = content.get(:political)
    obj.sentiment = content.get(:sentiment)
    obj.save!
    obj
  end
  
  def self.generate
    Article.distinct(:item_id).each do |item_id|
      IndicoApproach.perform_async("Article", {item_id: item_id})
    end
    ArticleContent.project(:url => 1, :item_id => 1).to_a.each do |ac|
      IndicoApproach.perform_async("ArticleContent", {url: ac.url, item_id: ac.item_id})
    end
  end
end