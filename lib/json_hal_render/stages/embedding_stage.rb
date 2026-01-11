# frozen_string_literal: true

module JsonHalRender
  module Stages
    # Builds embedded resources for the HAL document
    class EmbeddingStage < Stage
      private
      
      def perform_work(context)
        task_resource = context[:task_resource]
        options = context[:options] || {}
        
        base_url = options[:base_url] || ""
        task_id = options[:task_id] || "default"
        
        embedding_builder = EmbeddingBuilder.new(base_url, task_id, task_resource, options)
        embedded = embedding_builder.build_task_embedded
        
        Success(embedded: embedded)
      end
    end
  end
end
