class Stats

  def retrieve(username, name)
    StatResult.first(username: username, name: name).result rescue get(username, name)
  end

  def get(username, name)
    self.send(name, username)
  end

  def stopworded(corpus)
    Stopwords::Snowball::Filter.new("en").filter(corpus)
  end

  def word_counts(username)
    results = {"read" => [], "unread" => []}
    Article.where(username: username).fields(:time_read, :word_count).each do |article|
      read = article.time_read.nil? ? "unread" : "read"
      results[read] << article.word_count if article.word_count != 0
    end
    read_stats = results["read"].all_stats
    unread_stats = results["unread"].all_stats
    results["read"] = results["read"].reject{|x| x > read_stats[:mean]+read_stats[:standard_deviation]*2 || x < read_stats[:mean]-read_stats[:standard_deviation]*2}
    results["unread"] = results["unread"].reject{|x| x > unread_stats[:mean]+read_stats[:standard_deviation]*2 || x < unread_stats[:mean]-read_stats[:standard_deviation]*2}
    results.merge("read_min" => results["read"].sort.first, "read_max" => results["read"].sort.last, "unread_min" => results["unread"].sort.first, "unread_max" => results["unread"].sort.last)
  end
  
  def read_unread(username)
    results = {"read" => 0, "unread" => 0}
    Article.where(username: username).fields(:time_read).each do |article|
      read = article.time_read.nil? ? "unread" : "read"
      results[read] += 1
    end
    read_pct = ((results["read"]/results.values.sum)*100).round(1).to_s+"%"
    unread_pct = ((results["unread"]/results.values.sum)*100).round(1).to_s+"%"
    results.merge("read_pct" => read_pct, "unread_pct" => unread_pct)
  end
  
  def top_terms(username)
    result = {name: "all", children: []}
    item_ids = Article.where(username: username).fields(:item_id).collect(&:item_id)
    tags = ArticleContent.where(item_id: item_ids).fields(:keywords, :entities).collect{|ac| [ac.keywords.collect{|x| x.get(:name)}].flatten}
    tags.flatten.counts.sort_by{|k,v| v}.reverse.first(100).each do |k,v|
      result[:children] << {name: k, size: v}
    end
    result
  end
  
  def term_network(username)
    item_ids = Article.where(username: username).fields(:item_id).collect(&:item_id)
    tags = ArticleContent.where(item_id: item_ids).fields(:keywords, :entities).collect{|ac| [ac.keywords.collect{|x| x.get(:name)}, ac.entities.collect{|x| x.get(:name)}].flatten}
    tags = ArticleContent.where(item_id: item_ids).fields(:keywords, :entities).collect{|ac| [ac.keywords.collect{|x| x.get(:name)}].flatten}
    first_network = {nodes: [], edges: {}}
    term_counts = tags.flatten.counts
    top_terms = term_counts.sort_by{|k,v| v}.first(250).collect(&:first)
    first_network[:nodes] = top_terms
    tags.each do |tag_set|
      (tag_set-top_terms).permutation(2).each do |pair|
        first_network[:edges][pair.first] ||= {}
        first_network[:edges][pair.first][pair.last] ||= 0
        first_network[:edges][pair.first][pair.last] += 1
      end
    end
    edges = []
    nodes = []
    id = 0
    first_network[:edges].each do |first, others|
      others.each do |term, weight|
        if weight > 1
          id+=1
          edges << {label: "", source: first, target: term, id: id, attributes: { }, color: "rgb(82,65,211)", size: weight}
          nodes << first if !nodes.include?(first)
          nodes << term if !nodes.include?(term)
        end
      end
    end
    {nodes: nodes.collect{|n| {label: n, id: n, attributes: {}, color: "rgb(82,65,211)", size: term_counts[n], x: rand(20)-10, y: rand(20)-10}}, edges: edges}
  end
  
  def timeline_from_query(query)
    Article.where(query).sort(:time_added).fields(:time_added).collect(&:time_added).collect{|t| Time.parse(t.strftime("%Y-%m")+"-01").to_i*1000}.counts.to_a
  end

  def timeline(username)
    read_timeline = timeline_from_query(username: username, :time_read.ne => nil)
    unread_timeline = timeline_from_query(username: username, time_read: nil)
    any = timeline_from_query(username: username)
    {data: [{key: :Both, values: any}, {key: :Archived, values: read_timeline}, {key: :Unread, values: unread_timeline}], tick_values: read_timeline.collect(&:first)|unread_timeline.collect(&:first)}
  end
  
  def sources(username)
    Article.where(username: username).fields(:resolved_url).collect{|a| URI.parse(a.resolved_url).host rescue nil}.compact.counts.sort_by{|k,v| v}.reverse.first(20)
  end
  
  def weekdays
    ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  end

  def default_punchcard
    1.upto(24).collect{|x| 0}
  end

  def punchcard_added(username)
    result = {}
    counts = Article.where(username: username).fields(:time_added).collect{|a| a.time_added.strftime("%A %H").split(" ")}.counts
    weekdays.each do |day|
      result[day] = {label: day, values: default_punchcard}
      counts.select{|c| c.first == day}.each do |k,v|
        result[k.first][:values][k.last.to_i] = v
      end
    end
    result
  end
  
  def punchcard_read(username)
    result = {}
    counts = Article.where(username: username, :time_read.ne => nil).fields(:time_read).collect{|a| a.time_read.strftime("%A %H").split(" ")}.counts
    weekdays.each do |day|
      result[day] = {label: day, values: default_punchcard}
      counts.select{|c| c.first == day}.each do |k,v|
        result[k.first][:values][k.last.to_i] = v
      end
    end
    result
  end
  
  def punchcard(username)
    {added: punchcard_added(username), read: punchcard_read(username)}
  end

  def topics_i_dont_read(username)
    item_ids = Article.where(username: username, :time_read => nil).fields(:item_id).collect(&:item_id)
    Hash[ArticleContent.where(item_id: item_ids).fields(:keywords, :entities).collect{|ac| [ac.keywords.collect{|x| x.get(:name)}, ac.entities.collect{|x| x.get(:name)}]}.flatten.counts.sort_by{|k,v| v}.reverse.first(200)]
  end
  
  def topics_i_read(username)
    item_ids = Article.where(username: username, :time_read.ne => nil).fields(:item_id).collect(&:item_id)
    Hash[ArticleContent.where(item_id: item_ids).fields(:keywords, :entities).collect{|ac| [ac.keywords.collect{|x| x.get(:name)}, ac.entities.collect{|x| x.get(:name)}]}.flatten.counts.sort_by{|k,v| v}.reverse.first(200)]
  end
  
  def read_dont_read(username)
    dont_read = topics_i_dont_read(username)
    read = topics_i_read(username)
    {dont_read: dont_read.reject{|k,v| read.keys.include?(k)}.to_a.first(50), read: read.reject{|k,v| dont_read.keys.include?(k)}.to_a.first(50)}
  end
end