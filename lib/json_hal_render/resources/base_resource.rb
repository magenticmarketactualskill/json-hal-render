# frozen_string_literal: true

module JsonHalRender
  module Resources
    # Base class for HAL resources
    class BaseResource
      attr_reader :resource, :options
      
      def initialize(resource, options = {})
        @resource = resource
        @options = options
      end
      
      def to_hal
        {
          _links: links,
          _embedded: embedded
        }.merge(properties)
      end
      
      def to_json(*_args)
        require "json"
        to_hal.to_json
      end
      
      private
      
      def links
        {}
      end
      
      def embedded
        {}
      end
      
      def properties
        {}
      end
      
      def base_url
        options[:base_url] || ""
      end
      
      def include_embedded?
        options.fetch(:include_embedded, true)
      end
    end
  end
end
