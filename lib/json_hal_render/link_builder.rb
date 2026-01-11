# frozen_string_literal: true

module JsonHalRender
  # Builds HAL links for tasks and stages
  class LinkBuilder
    attr_reader :base_url, :task_id, :resource
    
    def initialize(base_url, task_id, resource)
      @base_url = base_url
      @task_id = task_id
      @resource = resource
    end
    
    def build_task_links
      links = {
        self: { href: task_path }
      }
      
      # Add conditional links based on task state
      if resource.is_a?(Task)
        links[:stages] = { href: "#{task_path}/stages" }
        
        unless resource.all_successful?
          links[:start] = { href: "#{task_path}/start" }
        end
        
        if resource.any_failed?
          links[:retry] = { href: "#{task_path}/retry" }
        end
        
        # Add next stage link if available
        next_stage = resource.stages.find { |s| !s.performed? }
        if next_stage
          links[:next_stage] = { href: "#{task_path}/stages/#{next_stage.name}" }
        end
      end
      
      links
    end
    
    def build_stage_links
      links = {
        self: { href: stage_path },
        task: { href: task_path }
      }
      
      if resource.is_a?(Stage)
        # Add execute link if stage hasn't been performed
        unless resource.performed?
          links[:execute] = { href: "#{stage_path}/execute" }
        end
        
        # Add retry link if stage failed
        if resource.failure?
          links[:retry] = { href: "#{stage_path}/retry" }
        end
      end
      
      links
    end
    
    private
    
    def task_path
      "#{base_url}/tasks/#{task_id}"
    end
    
    def stage_path
      "#{task_path}/stages/#{resource.name}"
    end
  end
end
