class ArticleContent
  include Mongoid::Document
  field :item_id
  field :url
  field :provider_url
  field :description
  field :embeds
  field :safe
  field :provider_display
  field :related
  field :favicon_url
  field :authors
  field :images
  field :cache_age
  field :language
  field :app_links
  field :content_url
  field :original_url
  field :url
  field :media
  field :title
  field :offset
  field :lead
  field :content
  field :content_stripped
  field :entities
  field :favicon_colors
  field :keywords
  field :published
  field :provider_name
  field :type
  
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
