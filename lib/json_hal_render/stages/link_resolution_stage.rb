# frozen_string_literal: true

module JsonHalRender
  module Stages
    # Resolves and builds HAL links for the task resource
    class LinkResolutionStage < Stage
      private
      
      def perform_work(context)
        task_resource = context[:task_resource]
        options = context[:options] || {}
        
        base_url = options[:base_url] || ""
        task_id = options[:task_id] || "default"
        
        link_builder = LinkBuilder.new(base_url, task_id, task_resource)
        links = link_builder.build_task_links
        
        Success(links: links)
      end
    end
  end
end
