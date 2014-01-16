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
        Sense.find(params[:sense_id]).as_json(
          :synonyms => true,
          :relations => true
        )
      end
    end

    resource :lexemes do

      get do
        paginate(Lexeme.all)
      end

      segment '/:lemma' do
        get do
          Lexeme.order("length(lemma)").
          where("lemma like ?", "#{params[:lemma]}%").
          limit(10).to_a
        end
      end
    end

    resource :hyponyms do
      get '/:sense_id' do
        query = """
          match (k:Singleton{ id: {sense_id} }),
                k-[:relation { id: 0 }]->(n:Synset),
                p = n-[r:relation*0..5 { id: 10 }]->(s:Synset),
                s-[:synset_sense]->(s2:Sense)

          return distinct({
            id: s2.id,
            lemma: s2.lemma,
            sense_index: s2.sense_index,
            comment: s2.comment
          })
        """.gsub(/\s+/, ' ').strip.freeze

        neo = Neography::Rest.new

        neo.execute_query(
          query, sense_id: params[:sense_id]
        )["data"]
      end
    end
  end
end
