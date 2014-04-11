Application.routes.draw do

  root to: 'home#index'
  get '/about' => 'home#about'
  get '/stats' => 'home#stats'
  get '/team' => 'home#team'
  get '/contact' => 'home#contact'

  get '/templates/index' => 'home#index'
  get '/templates/about' => 'home#about'
  get '/templates/stats' => 'home#stats'
  get '/templates/team' => 'home#team'
  get '/templates/contact' => 'home#contact'

  get '/:sense_id' => 'home#index'

  mount API::Engine => '/api'

  match '(errors)/:status', to: 'errors#show',
    constraints: { status: /\d{3}/ },
    defaults: { status: '500' },
    via: :all

end
