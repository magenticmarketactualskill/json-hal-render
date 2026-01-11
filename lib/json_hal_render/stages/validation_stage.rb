# frozen_string_literal: true

module JsonHalRender
  module Stages
    # Validates that the task resource is valid for HAL rendering
    class ValidationStage < Stage
      private
      
      def perform_work(context)
        task_resource = context[:task_resource]
        
        unless task_resource
          return Failure(error: "No task resource provided")
        end
        
        unless task_resource.respond_to?(:stages)
          return Failure(error: "Task resource must respond to :stages")
        end
        
        Success(validated: true)
      end
    end
  end
end
