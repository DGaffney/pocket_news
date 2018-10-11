class ArticleContent
  include MongoMapper::Document
  key :item_id
  key :url
  key :content_url
  key :provider_url
  key :description
  key :embeds
  key :safe
  key :provider_display
  key :related
  key :favicon_url
  key :authors
  key :images
  key :cache_age
  key :language
  key :app_links
  key :original_url
  key :url
  key :media
  key :title
  key :offset
  key :lead
  key :content
  key :content_stripped
  key :entities
  key :favicon_colors
  key :keywords
  key :published
  key :provider_name
  key :type
  
  def self.from_raw(content, item_id, url)
    obj = self.new
    obj.url = url
    obj.item_id = item_id
    obj.provider_url = content.get(:provider_url)
    obj.description = content.get(:description)
    obj.embeds = content.get(:embeds)
    obj.safe = content.get(:safe)
    obj.provider_display = content.get(:provider_display)
    obj.related = content.get(:related)
    obj.favicon_url = content.get(:favicon_url)
    obj.authors = content.get(:authors)
    obj.images = content.get(:images)
    obj.cache_age = content.get(:cache_age)
    obj.language = content.get(:language)
    obj.app_links = content.get(:app_links)
    obj.original_url = content.get(:original_url)
    obj.content_url = content.get(:url)
    obj.media = content.get(:media)
    obj.title = content.get(:title)
    obj.offset = content.get(:offset)
    obj.lead = content.get(:lead)
    obj.content = content.get(:content)
    obj.content_stripped = Nokogiri.parse(content.get(:content)).text if content.get(:content)
    obj.entities = content.get(:entities)
    obj.favicon_colors = content.get(:favicon_colors)
    obj.keywords = content.get(:keywords)
    obj.published = content.get(:published)
    obj.provider_name = content.get(:provider_name)
    obj.type = content.get(:type)
    obj.save!
    obj
  end
end
