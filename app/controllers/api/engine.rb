module API
  class Engine < Grape::API
    mount API::Lexemes
  end
end
