Application.routes.draw do

  mount API::Engine => '/api'

  root to: 'home#index'

  %w(about stats team contact sense graph).each do |name|
    get "/#{name}" => "home##{name}"
    get "/templates/#{name}" => "home##{name}"
  end

  get '/unknown/:lemma' => 'home#unknown'
  get '/templates/unknown' => 'home#unknown'

  match '(errors)/:status', to: 'errors#show',
    constraints: { status: /\d{3}/ },
    defaults: { status: '500' },
    via: :all

  get '/*sense_id' => 'home#sense'
end
