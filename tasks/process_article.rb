class ProcessArticle
  include Sidekiq::Worker
  
  def perform(article, username, count)
    Article.from_raw(article, username)
    if Article.count(username: username)/count.to_f > 0.75
      ["word_counts", "read_unread", "top_terms", "term_network"].each do |stat|
        sr = StatResult.first_or_create(username: username, name: stat)
        sr.value = Stats.new.get(username, stat)
        sr.save!
      end
    end
  end
end