class Article
  include MongoMapper::Document
  key :username, String
  key :item_id, Integer
  key :resolved_id, Integer
  key :given_url, String
  key :given_title, String
  key :favorite, Boolean
  key :status, Boolean
  key :time_added, Time
  key :time_updated, Time
  key :time_read, Time
  key :time_favorited, Time
  key :sort_id, Integer
  key :resolved_title, String
  key :resolved_url, String
  key :excerpt, String
  key :is_article, Boolean
  key :is_index, Boolean
  key :has_video, Boolean
  key :has_image, Boolean
  key :word_count, Integer
  
  def self.from_raw(article, username)
    obj_is_new = self.first(item_id: article.get(:item_id).to_i).nil?
    obj = self.first_or_create(item_id: article.get(:item_id).to_i, username: username)
    obj.resolved_id = article.get(:resolved_id).to_i
    obj.given_url = article.get(:given_url)
    obj.given_title = article.get(:given_title)
    obj.favorite = article.get(:favorite) == 1
    obj.status = article.get(:status) == 1
    obj.time_added = article.get(:time_added) == "0" ? nil : Time.at(article.get(:time_added).to_i)
    obj.time_updated = article.get(:time_updated) == "0" ? nil : Time.at(article.get(:time_updated).to_i)
    obj.time_read = article.get(:time_read) == "0" ? nil : Time.at(article.get(:time_read).to_i)
    obj.time_favorited = article.get(:time_favorited) == "0" ? nil : Time.at(article.get(:time_favorited).to_i)
    obj.sort_id = article.get(:sort_id).to_i
    obj.resolved_title = article.get(:resolved_title)
    obj.resolved_url = article.get(:resolved_url)
    obj.excerpt = article.get(:excerpt)
    obj.is_article = article.get(:is_article) == 1
    obj.is_index = article.get(:is_index) == 1
    obj.has_video = article.get(:has_video) == 1
    obj.has_image = article.get(:has_image) == 1
    obj.word_count = article.get(:word_count).to_i
    ClassifyTopics.perform_async(obj.item_id, obj.resolved_url) if obj_is_new
    obj.save!
  end
end