# frozen_string_literal: true

module JsonHalRender
  # Base Stage class for functional task execution
  class Stage
    include Dry::Monads[:result]
    
    attr_reader :name, :result
    
    def initialize(name)
      @name = name
      @result = nil
    end
    
    def execute(context = {})
      return result if performed?
      
      @result = if preconditions_met?(context)
                  perform_work(context)
                else
                  Failure(error: "Preconditions not met for stage: #{name}")
                end
    rescue StandardError => e
      @result = Failure(
        error: e.message,
        stage: name,
        backtrace: e.backtrace.first(5)
      )
    end
    
    def performed?
      !result.nil?
    end
    
    def success?
      performed? && result.success?
    end
    
    def failure?
      performed? && result.failure?
    end
    
    def value
      result&.value!
    end
    
    def error
      result&.failure
    end
    
    private
    
    def preconditions_met?(_context)
      true
    end
    
    def perform_work(_context)
      Success(data: "Stage #{name} completed")
    end
  end
end
