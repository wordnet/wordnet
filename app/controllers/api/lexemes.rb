module API
  class Lexemes < Grape::API
    include API::Base

    include Grape::Kaminari
    
    resource :relations do
      get do
        RelationType.all
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
