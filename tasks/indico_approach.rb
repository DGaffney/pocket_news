class IndicoApproach
  include Sidekiq::Worker
  def perform(classname, lookup)
    return if !IndicoResult.first(classname: classname, lookup: lookup).nil?
    object = classname.constantize.first(lookup)
    indico_results(classname, object).collect{|ir| IndicoResult.from_raw(ir, lookup)}    
  end
  
  def indico_results(classname, object)
    objects = []
    results = {
      text_tags: Indico.text_tags(fields[classname].collect{|f| object.send(f)}),
      political: Indico.political(fields[classname].collect{|f| object.send(f)}),
      sentiment: Indico.sentiment(fields[classname].collect{|f| object.send(f)})
    }
    fields[classname].length.times do |x|
      objects << Hash[results.keys.zip(results.values.collect{|v| v[x-1]})]
    end
    objects
  end
  
  def fields
    {
      "Article" => ["resolved_title", "excerpt"],
      "ArticleContent" => ["content"]
    }
  end
end
# a = Article.first
# IndicoApproach.new.perform("Article", {item_id: a.item_id})
# ac = ArticleContent.first(item_id: a.item_id)
# IndicoApproach.new.perform("ArticleContent", {item_id: ac.item_id, url: ac.url})