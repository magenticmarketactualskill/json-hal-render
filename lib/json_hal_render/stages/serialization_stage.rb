# frozen_string_literal: true

module JsonHalRender
  module Stages
    # Serializes the task resource to HAL JSON format
    class SerializationStage < Stage
      private
      
      def perform_work(context)
        task_resource = context[:task_resource]
        links = context[:links] || {}
        embedded = context[:embedded] || {}
        options = context[:options] || {}
        
        hal_document = build_hal_document(task_resource, links, embedded, options)
        
        Success(hal_document: hal_document)
      end
      
      def build_hal_document(task_resource, links, embedded, options)
        doc = {
          _links: links
        }
        
        # Only include _embedded if there are embedded resources
        doc[:_embedded] = embedded if embedded.any?
        
        # Add task properties
        doc.merge!(build_properties(task_resource, options))
        
        doc
      end
      
      def build_properties(task_resource, options)
        props = {
          status: determine_status(task_resource),
          total_stages: task_resource.stages.length
        }
        
        # Add current stage if available
        current_stage = task_resource.stages.find { |s| !s.performed? }
        props[:current_stage] = current_stage.name if current_stage
        
        # Add completed stages
        completed = task_resource.stages.select(&:success?).map(&:name)
        props[:completed_stages] = completed if completed.any?
        
        # Add failed stages
        failed = task_resource.stages.select(&:failure?).map(&:name)
        props[:failed_stages] = failed if failed.any?
        
        # Add timestamps if available
        if options[:created_at]
          props[:created_at] = options[:created_at]
        end
        
        if options[:updated_at]
          props[:updated_at] = options[:updated_at]
        end
        
        props
      end
      
      def determine_status(task_resource)
        return "completed" if task_resource.all_successful?
        return "failed" if task_resource.any_failed?
        return "running" if task_resource.stages.any?(&:performed?)
        "pending"
      end
    end
  end
end
