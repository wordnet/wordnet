module API
  class Routing < Grape::API
    include API::Base

    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    get '/relations' do
      RelationType.all
    end

    get '/domains' do
      Domain.all
    end

    get '/senses/*sense_id' do
      Sense.find(params[:sense_id]).as_json(extended: true)
    end

    get '/lexemes/:lemma' do
      Sense.select('id, lemma, language').
      where("LOWER(lemma) like LOWER(?) AND sense_index = 1", "#{params[:lemma]}%").
      order('length(lemma)').
      limit(20).to_a.map { |d|
        { sense_id: d.id, lemma: d.lemma, language: d.language }
      }.to_a.
      group_by { |s| s[:lemma].downcase }.
      map { |a, b| b.reduce(b.first){ |sum, b|
        sum[:languages] ||= Set.new
        sum[:languages] << b[:language]
        sum
      } }[0..10]
    end

    get '/hyponyms/*sense_id' do
      query = """
        match (k:Singleton{ id: {sense_id} }),
        k-[:relation { id: 0 }]->(n:Synset),
        p = n-[:hyponym*0..]->(s:Synset)
        where not((s)-[:hyponym]->())
        with nodes(p) as nodes
        return extract(nod in nodes |
          extract(e2 in extract(p2 in nod<-[:synset]-() |
            nodes(p2)[0]
          ) | {
            id: e2.id,
            lemma: e2.lemma,
            sense_index: e2.sense_index,
            comment: e2.comment
          })
        )
      """.gsub(/\s+/, ' ').strip.freeze

      neo = Neography::Rest.new(Figaro.env.neo4j_url)

      neo.execute_query(
        query, sense_id: params[:sense_id]
      )["data"].map(&:first).map { |e| e.map(&:first).compact.reverse }
    end

    get '/stats' do
      Statistic::VIEWS.map(&:call)
    end

    get '/graph' do
      neo = Neography::Rest.new(Figaro.env.neo4j_url)

      query = """
        match (s:Singleton),
              (s-[:relation*0..1 { weight: 0 }]->(h:Synset)),
              (h-[r:relation { weight: 1 }]-(i:Synset)),
              (i<-[r2:synset]-(target:Sense))
        where s.id in { id }
        return {
          nodes: collect({
            id: target.id,
            lemma: target.lemma,
            domain: target.domain_id,
            language: target.language,
            part_of_speech: target.part_of_speech,
            target_type: lower(labels(i)[-1]),
            sense_index: target.sense_index
          }),
          relations: collect({
            id: r.id,
            source: (CASE startnode(r) = h WHEN true THEN s.id ELSE target.id END),
            target: (CASE startnode(r) = h WHEN false THEN s.id ELSE target.id END)
          })
        }
      """.strip_heredoc

      neo.execute_query(
        query, id: params[:nodes]
      )["data"].first
    end
  end
end
