class IndicoResult
  include MongoMapper::Document
  key :lookup, Hash
  key :text_tags, Hash
  key :political, Hash
  key :sentiment, Float
  timestamps!
  def self.from_raw(content, lookup)
    obj = self.new
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
    ArticleContent.fields(:url, :item_id).to_a.each do |ac|
      IndicoApproach.perform_async("Article", {url: ac.url, item_id: ac.item_id})
    end
  end
end