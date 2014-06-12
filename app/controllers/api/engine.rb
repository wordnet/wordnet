module API
  class Engine < Grape::API
    mount API::Routing
  end
end
