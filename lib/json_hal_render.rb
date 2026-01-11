# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "dry/effects"

require_relative "json_hal_render/version"
require_relative "json_hal_render/stage"
require_relative "json_hal_render/task"
require_relative "json_hal_render/resources/base_resource"
require_relative "json_hal_render/resources/task_resource"
require_relative "json_hal_render/resources/stage_resource"
require_relative "json_hal_render/link_builder"
require_relative "json_hal_render/embedding_builder"
require_relative "json_hal_render/stages/validation_stage"
require_relative "json_hal_render/stages/link_resolution_stage"
require_relative "json_hal_render/stages/embedding_stage"
require_relative "json_hal_render/stages/serialization_stage"
require_relative "json_hal_render/stages/response_stage"
require_relative "json_hal_render/rendering_task"
require_relative "json_hal_render/renderer"

module JsonHalRender
  class Error < StandardError; end
  
  # Convenience method for rendering tasks
  def self.render(task, options = {})
    renderer = Renderer.new(task, options)
    renderer.render
  end
end
