class IndicoResult
  include MongoMapper::Document
  key :item_id, Integer
  key :url, String
  timestamps!
  def self.from_raw(content, item_id, url)
  end
end