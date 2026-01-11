# frozen_string_literal: true

module JsonHalRender
  module Stages
    # Prepares the final response with proper HTTP metadata
    class ResponseStage < Stage
      private
      
      def perform_work(context)
        hal_document = context[:hal_document]
        task_resource = context[:task_resource]
        
        response = {
          body: hal_document,
          content_type: "application/hal+json",
          status: determine_http_status(task_resource)
        }
        
        Success(response: response)
      end
      
      def determine_http_status(task_resource)
        return 200 if task_resource.all_successful?
        return 202 if task_resource.stages.any?(&:performed?) && !task_resource.all_successful?
        return 500 if task_resource.any_failed?
        200
      end
    end
  end
end
