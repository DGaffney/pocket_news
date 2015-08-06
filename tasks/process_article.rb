class ProcessArticle
  include Sidekiq::Worker
  sidekiq_options :queue => :pocket_harvester
  
  def perform(article, username, count)
    Article.from_raw(article, username)
    if Article.count(username: username)/count.to_f > 0.95
      ["word_counts", "read_unread", "top_terms", "term_network"].each do |stat|
        StoreResults.perform_async(username, stat)
      end
    end
  end
end