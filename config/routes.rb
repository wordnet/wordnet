Application.routes.draw do

  root to: 'home#index'

  mount API::Engine => '/api'

  match '(errors)/:status', to: 'errors#show',
    constraints: { status: /\d{3}/ },
    defaults: { status: '500' },
    via: :all

end
