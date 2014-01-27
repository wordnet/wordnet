module API
  module Base
    extend ActiveSupport::Concern

    included do
      format :json

      rescue_from ActiveRecord::RecordNotFound do |e|
        error_response(message: e.message, status: 404)
      end

      use API::Logger
    end
  end
end
