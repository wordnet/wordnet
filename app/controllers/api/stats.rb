module API
  class Stats < Grape::API
    include API::Base

    before do
      header['Access-Control-Allow-Origin'] = '*'
      header['Access-Control-Request-Method'] = '*'
    end

    get :stats do
      {
        statistics: Statistic.definitions,
        data: Statistic.fetch_all.map do |s|
          {
            name: s.name,
            x: s.x,
            y: s.y,
            value: s.value
          }
        end
      }
      
    end
  end
end
