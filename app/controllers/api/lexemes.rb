module API
  class Lexemes < Grape::API
    include API::Base

    include Grape::Kaminari

    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    resource :relations do
      get do
        RelationType.all
      end
    end

    resource :domains do
      get do
        Domain.all
      end
    end

    resource :senses do
      get '/:sense_id' do
        Sense.find(params[:sense_id]).as_json(extended: true)
      end
    end

    resource :lexemes do

      segment '/:lemma' do
        get do
          Sense.
            select('id, lemma, language, part_of_speech').
            where("LOWER(lemma) like LOWER(?)", "#{params[:lemma]}%").
            where(core: true).
            order('length(lemma)').
            limit(20).to_a.map { |d|
              {
                sense_id: d.id,
                lemma: d.lemma,
                language: d.language,
                part_of_speech:  d.part_of_speech
              }
            }.to_a.
            group_by { |s| [s[:lemma].downcase, s[:part_of_speech]] }.
            map { |a, b| b.reduce(b.first) { |sum, b|
              sum[:languages] ||= Set.new
              sum[:languages] << b[:language]
              sum
            } }[0..10]
        end
      end
    end

    resource :hyponyms do
      get '/:sense_id' do
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
    end
  end
end
