class GraphQuery < ActiveRecord::Base
  NEO = Neography::Rest.new(Figaro.env.neo4j_url)

  QUERY_NODES = """
    MATCH
      (s<-[:synset]-(source:Sense)),
      (s:Singleton),
      (s-[:relation*0..1 { weight: 0 }]->(h:Synset)),
      (h-[r:relation { weight: 1 }]-(i:Synset)),
      (i<-[r2:synset]-(target:Sense))
    WHERE s.id in { id }
    RETURN
    {
      nodes: COLLECT({
        id: target.id,
        lemma: target.lemma,
        domain: target.domain_id,
        language: target.language,
        part_of_speech: target.part_of_speech,
        target_type: lower(labels(i)[-1]),
        sense_index: target.sense_index
      }) + COLLECT(DISTINCT({
        id: source.id,
        lemma: source.lemma,
        domain: source.domain_id,
        language: source.language,
        part_of_speech: source.part_of_speech,
        target_type: lower(labels(s)[-1]),
        sense_index: source.sense_index
      })),
      links: COLLECT({
        relation_id: r.id,
        source_id: (CASE startnode(r) = h WHEN true THEN s.id ELSE target.id END),
        target_id: (CASE startnode(r) = h WHEN false THEN s.id ELSE target.id END)
      })
    }
  """.strip_heredoc

  QUERY_LINKS = """
    MATCH
      (s:Singleton),
      (s-[:relation*0..1 { weight: 0 }]->(h:Synset)),
      (h-[r:relation { weight: 1 }]-(i:Synset)),
      (i<-[:synset]-(target:Sense))
    WHERE s.id in { id } AND target.id in { id }
    RETURN COLLECT({
      relation_id: r.id,
      source_id: (CASE startnode(r) = h WHEN true THEN s.id ELSE target.id END),
      target_id: (CASE startnode(r) = h WHEN false THEN s.id ELSE target.id END)
    })
  """.strip_heredoc

  serialize :params, JSON

  def query_id
    self.params["query_id"]
  end

  def nodes
    Array(self.params["nodes"])
  end


  def links_hash(source_links, target_links)
    source_link_hashes = source_links.map do |link|
      link[:relation_id].to_s + link[:target_id]
    end

    target_link_hashes = target_links.map do |link|
      link[:relation_id].to_s + link[:source_id]
    end

    Digest::MD5.hexdigest([source_link_hashes + target_link_hashes].sort.join)
  end

  def reduce_graph(data)

    data.links.each do |link|
      link[:id] = "#{link[:relation_id]}#{link[:source_id]}#{link[:target_id]}"
    end

    grouped_sources = data.links.group_by(&:source_id)
    grouped_targets = data.links.group_by(&:target_id)

    data.nodes.each do |node|
      source_links = grouped_sources.fetch(node.id, [])
      target_links = grouped_targets.fetch(node.id, [])

      node[:group_id] = links_hash(source_links, target_links)
    end

    removed_nodes = []

    new_nodes = data.nodes.group_by(&:group_id).flat_map do |group_id, nodes|
      nodes.sort_by!(&:lemma)

      if nodes.size < 3
        nodes
      else
        Array(nodes[2..-1]).each do |removed_node|
          removed_nodes << removed_node.id
        end

        nodes[0..1]
      end
    end

    links_left = data.links.reject do |l|
      removed_nodes.include?(l.source_id) || removed_nodes.include?(l.target_id)
    end

    Hashie::Mash[{
      nodes: new_nodes,
      links: links_left
    }]
  end

  def query_nodes(node_ids)
    Hashie::Mash[NEO.execute_query(
      QUERY_NODES, id: node_ids
    )["data"].first.first]
  end

  def query_links(node_ids)
    NEO.execute_query(
      QUERY_LINKS, id: node_ids
    )["data"].first.first.map { |h| Hashie::Mash[h] }
  end

  def as_json(options = {})
    # cleaned_params = params.slice(:query_id, :nodes)

    # graph_query = GraphQuery.find_or_create_by(id: params[:query_id]) do |q|
    #   q.params = cleaned_params
    # end

    fetched_nodes = reduce_graph(query_nodes(nodes)).nodes
    fetched_relations = query_links(fetched_nodes.map(&:id))

    fetched_relations.each do |link|
      link[:id] = "#{link[:relation_id]}#{link[:source_id]}#{link[:target_id]}"
    end

    Hashie::Mash[{
      nodes: fetched_nodes,
      links: fetched_relations,
    }]
  end
end
