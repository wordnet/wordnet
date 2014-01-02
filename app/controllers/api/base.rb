module API
  module Base
    extend ActiveSupport::Concern

    included do
      format :json

      rescue_from ActiveRecord::RecordNotFound do |e|
        error_response(message: e.message, status: 404)
      end

      rescue_from :all do |e|
        if Rails.env.development?
          raise e
        else
          Raven.capture_exception(e)
          error_response(message: "Internal server error", status: 500)
        end
      end

      use API::Logger
    end
  end
end
