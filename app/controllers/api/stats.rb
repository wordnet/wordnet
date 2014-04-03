module API
  class Stats < Grape::API
    include API::Base

    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    get :stats do
      Statistic::VIEWS.map(&:call)
    end
  end
end
