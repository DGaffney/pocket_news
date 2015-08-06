class ClassifyTopics
  include Sidekiq::Worker
  def perform(item_id, url)
    get_tags(get_content(item_id, url), item_id, url)
  end
  
  def get_content(item_id, url)
    if (article = ArticleContent.first(item_id: item_id, url: url)).nil?
      JSON.parse(ArticleContent.from_raw(JSON.parse(RestClient.get("http://api.embed.ly/1/extract?url=#{CGI.escape(url)}&maxwidth=500&key=#{SETTINGS["embedly_api_key"].split(",").shuffle.first}")), item_id, url).to_json)
    else
      JSON.parse(article.to_json)
    end
  end
  
  def get_tags(article, item_id, url)
    if (tag = ArticleTag.first(item_id: item_id, url: url)).nil?
      JSON.parse(ArticleTag.from_raw(JSON.parse(RestClient.post("https://api.meaningcloud.com/topics-1.2", {key: SETTINGS["meaningcloud"], lang: "en", txt: article.get(:content_stripped) || article.get(:description), txtf: "plain", tt: "a"})), item_id, url).to_json)
    else
      JSON.parse(tag.to_json)
    end
  end
end