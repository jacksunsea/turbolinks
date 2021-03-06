module Turbolinks
  module XHRHeaders
    extend ActiveSupport::Concern

    included do
      alias_method_chain :_compute_redirect_to_location, :xhr_referer
    end

    private
      def _compute_redirect_to_location_with_xhr_referer(options)
        if options == :back && request.headers["X-XHR-Referer"]
          _compute_redirect_to_location_without_xhr_referer(request.headers["X-XHR-Referer"])
        else
          _compute_redirect_to_location_without_xhr_referer(options)
        end
      end

      def set_xhr_current_location
        response.headers['X-XHR-Current-Location'] = request.fullpath
      end
  end

  class Engine < ::Rails::Engine
    initializer :turbolinks_xhr_headers do |config|
      ActionController::Base.class_eval do
        include XHRHeaders
        after_filter :set_xhr_current_location
      end
    end
  end
end
