# frozen_string_literal: true

module JsonHalRender
  module Resources
    # HAL resource representation of a Task
    class TaskResource < BaseResource
      def task_id
        options[:task_id] || "default"
      end
      
      private
      
      def links
        link_builder = LinkBuilder.new(base_url, task_id, resource)
        link_builder.build_task_links
      end
      
      def embedded
        return {} unless include_embedded?
        
        embedding_builder = EmbeddingBuilder.new(base_url, task_id, resource, options)
        embedding_builder.build_task_embedded
      end
      
      def properties
        {
          status: determine_status,
          current_stage: current_stage_name,
          completed_stages: completed_stage_names,
          failed_stages: failed_stage_names,
          total_stages: resource.stages.length
        }
      end
      
      def determine_status
        return "completed" if resource.all_successful?
        return "failed" if resource.any_failed?
        return "running" if resource.stages.any?(&:performed?)
        "pending"
      end
      
      def current_stage_name
        current = resource.stages.find { |s| !s.performed? }
        current&.name
      end
      
      def completed_stage_names
        resource.stages.select(&:success?).map(&:name)
      end
      
      def failed_stage_names
        resource.stages.select(&:failure?).map(&:name)
      end
    end
  end
end
