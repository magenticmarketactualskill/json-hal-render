# frozen_string_literal: true

module JsonHalRender
  module Resources
    # HAL resource representation of a Stage
    class StageResource < BaseResource
      def task_id
        options[:task_id] || "default"
      end
      
      private
      
      def links
        link_builder = LinkBuilder.new(base_url, task_id, resource)
        link_builder.build_stage_links
      end
      
      def embedded
        {} # Stages typically don't have embedded resources
      end
      
      def properties
        props = {
          name: resource.name,
          status: determine_stage_status,
          performed: resource.performed?
        }
        
        if resource.success?
          props[:value] = resource.value
        elsif resource.failure?
          props[:error] = resource.error
        end
        
        props
      end
      
      def determine_stage_status
        return "success" if resource.success?
        return "failure" if resource.failure?
        "pending"
      end
    end
  end
end
