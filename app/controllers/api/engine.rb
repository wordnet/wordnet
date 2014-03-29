module API
  class Engine < Grape::API
    mount API::Lexemes
    mount API::Stats
  end
end
