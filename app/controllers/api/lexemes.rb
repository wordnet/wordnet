module API
  class Lexemes < Grape::API
    include API::Base

    include Grape::Kaminari

    resource :lexemes do
      get do
        paginate(Lexeme.all)
      end

      segment '/:lemma' do
        get do
          Lexeme.find_by(lemma: params[:lemma])
        end

        resource :senses do
          get do
            Lexeme.find_by(lemma: params[:lemma]).senses
          end

          segment ':sense_id' do
            get do
              Lexeme.find_by(lemma: params[:lemma]).senses.find(params[:sense_id])
            end

            resource :relations do
              params do
                optional :relation_id, type: Integer
              end

              get do
                {
                  child_relations: Sense.find(params[:sense_id]).
                    child_relations.map { |c| c.as_json(:only_child => true) },
                  parent_relations: Sense.find(params[:sense_id]).
                    parent_relations.map { |c| c.as_json(:only_parent => true) }
                }
              end
            end


            resource :synset do
              get do
                Lexeme.find_by(lemma: params[:lemma]).
                  senses.find(params[:sense_id]).synset
              end
            end
          end
        end

      end

    end

    resource :synsets do
      get do
        paginate(Synset.all)
      end

      segment '/:synset_id' do
        get do
          Synset.find(params[:synset_id])
        end

        resource :relations do
          params do
            optional :relation_id, type: Integer
          end

          get do
            {
              child_relations: Synset.find(params[:synset_id]).
                child_relations.map { |c| c.as_json(:only_child => true) },
              parent_relations: Synset.find(params[:synset_id]).
                parent_relations.map { |c| c.as_json(:only_parent => true) }
            }
          end
        end

        resource :senses do
          get do
            Synset.find(params[:synset_id]).senses
          end

          segment ':sense_id' do
            get do
              Synset.find(params[:synset_id]).senses.find(params[:sense_id])
            end

            resource :synset do
              get do
                Lexeme.find_by(lemma: params[:lemma]).
                  senses.find(params[:sense_id]).synset
              end
            end
          end
        end

      end

    end
  end
end
