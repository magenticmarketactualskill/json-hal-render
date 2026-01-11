# frozen_string_literal: true

module JsonHalRender
  # Main renderer class that provides a simple interface for rendering tasks
  class Renderer
    include Dry::Monads[:result]
    
    attr_reader :task_resource, :options
    
    def initialize(task_resource, options = {})
      @task_resource = task_resource
      @options = options
    end
    
    def render
      rendering_task = RenderingTask.new(task_resource, options)
      result = rendering_task.run
      
      case result
      when Dry::Monads::Success
        response = result.value![:response]
        Success(response)
      when Dry::Monads::Failure
        Failure(result.failure)
      end
    end
    
    # Convenience method to get just the HAL document
    def to_hal
      result = render
      
      if result.success?
        result.value![:body]
      else
        nil
      end
    end
    
    # Convenience method to get HAL document as JSON string
    def to_json(*_args)
      require "json"
      hal = to_hal
      hal ? hal.to_json : nil
    end
  end
end
