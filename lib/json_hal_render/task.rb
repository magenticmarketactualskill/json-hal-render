# frozen_string_literal: true

module JsonHalRender
  # Base Task class for orchestrating multiple stages
  class Task
    include Dry::Monads[:result]
    
    attr_reader :stages, :context
    
    def initialize
      @stages = []
      @context = {}
    end
    
    def add_stage(stage)
      @stages << stage
      self
    end
    
    def run
      @stages.each do |stage|
        result = stage.execute(@context)
        
        if result.success?
          @context.merge!(result.value!)
        else
          return Failure(
            error: "Task failed at stage: #{stage.name}",
            stage: stage.name,
            details: result.failure
          )
        end
      end
      
      Success(
        completed: @stages.map(&:name),
        context: @context
      )
    end
    
    def run_conditional
      current_index = 0
      
      while current_index < @stages.length
        stage = @stages[current_index]
        result = stage.execute(@context)
        
        if result.success?
          @context.merge!(result.value!)
          current_index = determine_next_stage(result, current_index)
        else
          return Failure(
            error: "Task failed at stage: #{stage.name}",
            stage: stage.name,
            details: result.failure
          )
        end
      end
      
      Success(
        completed: @stages.select(&:performed?).map(&:name),
        context: @context
      )
    end
    
    def all_successful?
      @stages.all?(&:success?)
    end
    
    def any_failed?
      @stages.any?(&:failure?)
    end
    
    def successful_results
      @stages.select(&:success?).map(&:value)
    end
    
    def failed_results
      @stages.select(&:failure?).map(&:error)
    end
    
    private
    
    def determine_next_stage(_result, current_index)
      current_index + 1
    end
  end
end
