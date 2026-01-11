# frozen_string_literal: true

module JsonHalRender
  # Main rendering task that orchestrates all stages
  class RenderingTask < Task
    def initialize(task_resource, options = {})
      super()
      @task_resource = task_resource
      @options = options
      setup_stages
      setup_context
    end
    
    private
    
    def setup_stages
      add_stage(Stages::ValidationStage.new("validation"))
        .add_stage(Stages::LinkResolutionStage.new("link_resolution"))
        .add_stage(Stages::EmbeddingStage.new("embedding"))
        .add_stage(Stages::SerializationStage.new("serialization"))
        .add_stage(Stages::ResponseStage.new("response"))
    end
    
    def setup_context
      @context = {
        task_resource: @task_resource,
        options: @options
      }
    end
  end
end
