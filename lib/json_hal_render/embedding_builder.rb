# frozen_string_literal: true

module JsonHalRender
  # Builds embedded resources for HAL documents
  class EmbeddingBuilder
    attr_reader :base_url, :task_id, :resource, :options
    
    def initialize(base_url, task_id, resource, options = {})
      @base_url = base_url
      @task_id = task_id
      @resource = resource
      @options = options
    end
    
    def build_task_embedded
      embedded = {}
      
      if resource.is_a?(Task) && resource.stages.any?
        embedded[:stages] = resource.stages.map do |stage|
          stage_resource = Resources::StageResource.new(
            stage,
            base_url: base_url,
            task_id: task_id,
            include_embedded: false
          )
          stage_resource.to_hal
        end
      end
      
      # Add errors if any stages failed
      if resource.any_failed?
        embedded[:errors] = resource.failed_results
      end
      
      embedded
    end
  end
end
