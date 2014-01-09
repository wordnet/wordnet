module API
  class Lexemes < Grape::API
    include API::Base

    include Grape::Kaminari

    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    resource :graph do
      get '/:query' do
        # neo.execute_query('match (s:Sense)-[:belongs_to]->(t:Synset)<-[:belongs_to]-(s2:Sense) where s.id = "abca8066-774b-11e3-8eaa-e7fb1d35049d" return s2.lemma, s2.comment, s2.sense_index, s2.language')
        neo = Neography::Rest.new
      end
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
  end
end
