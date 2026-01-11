#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/json_hal_render'
require 'json'

# Example 1: Basic Task with Default Stages
puts "=" * 80
puts "Example 1: Basic Task with Default Stages"
puts "=" * 80

task = JsonHalRender::Task.new
task.add_stage(JsonHalRender::Stage.new('fetch_data'))
    .add_stage(JsonHalRender::Stage.new('process_data'))
    .add_stage(JsonHalRender::Stage.new('save_data'))

renderer = JsonHalRender::Renderer.new(
  task,
  base_url: 'http://api.example.com',
  task_id: '123'
)

result = renderer.render

if result.success?
  response = result.value!
  puts "\nContent-Type: #{response[:content_type]}"
  puts "Status: #{response[:status]}"
  puts "\nHAL Document:"
  puts JSON.pretty_generate(response[:body])
end

# Example 2: Custom Stages with Business Logic
puts "\n\n"
puts "=" * 80
puts "Example 2: Custom Stages with Business Logic"
puts "=" * 80

class FetchDataStage < JsonHalRender::Stage
  private

  def perform_work(context)
    puts "  [#{name}] Fetching data from API..."
    data = [
      { id: 1, name: 'Product A', price: 29.99 },
      { id: 2, name: 'Product B', price: 49.99 },
      { id: 3, name: 'Product C', price: 19.99 }
    ]
    Success(data: data, records: data.length)
  end
end

class ProcessDataStage < JsonHalRender::Stage
  private

  def perform_work(context)
    puts "  [#{name}] Processing data..."
    data = context[:data]
    processed = data.map do |item|
      item.merge(
        processed: true,
        discounted_price: (item[:price] * 0.9).round(2)
      )
    end
    Success(data: processed, processed_count: processed.length)
  end
end

class SaveDataStage < JsonHalRender::Stage
  private

  def perform_work(context)
    puts "  [#{name}] Saving data to database..."
    data = context[:data]
    Success(saved: true, saved_count: data.length)
  end
end

task2 = JsonHalRender::Task.new
task2.add_stage(FetchDataStage.new('fetch'))
     .add_stage(ProcessDataStage.new('process'))
     .add_stage(SaveDataStage.new('save'))

puts "\nExecuting task..."
task_result = task2.run

if task_result.success?
  puts "\n✓ Task completed successfully!"
  puts "Completed stages: #{task_result.value![:completed].join(', ')}"
  
  puts "\nRendering as HAL..."
  renderer2 = JsonHalRender::Renderer.new(
    task2,
    base_url: 'http://api.example.com',
    task_id: '456'
  )
  
  hal_result = renderer2.render
  if hal_result.success?
    puts "\nHAL Document:"
    puts JSON.pretty_generate(hal_result.value![:body])
  end
end

# Example 3: Task with Failing Stage
puts "\n\n"
puts "=" * 80
puts "Example 3: Task with Failing Stage"
puts "=" * 80

class FailingStage < JsonHalRender::Stage
  private

  def perform_work(context)
    puts "  [#{name}] Attempting risky operation..."
    raise StandardError, "Connection timeout after 30 seconds"
  end
end

task3 = JsonHalRender::Task.new
task3.add_stage(FetchDataStage.new('fetch'))
     .add_stage(FailingStage.new('risky_operation'))
     .add_stage(SaveDataStage.new('save'))

puts "\nExecuting task with failing stage..."
task3_result = task3.run

if task3_result.failure?
  puts "\n✗ Task failed!"
  puts "Error: #{task3_result.failure[:error]}"
  puts "Failed at stage: #{task3_result.failure[:stage]}"
  
  puts "\nRendering failed task as HAL..."
  renderer3 = JsonHalRender::Renderer.new(
    task3,
    base_url: 'http://api.example.com',
    task_id: '789'
  )
  
  hal_result = renderer3.render
  if hal_result.success?
    puts "\nHAL Document (with errors):"
    puts JSON.pretty_generate(hal_result.value![:body])
  end
end

# Example 4: Partially Executed Task
puts "\n\n"
puts "=" * 80
puts "Example 4: Partially Executed Task (Running State)"
puts "=" * 80

task4 = JsonHalRender::Task.new
stage1 = FetchDataStage.new('fetch')
stage2 = ProcessDataStage.new('process')
stage3 = SaveDataStage.new('save')

task4.add_stage(stage1)
     .add_stage(stage2)
     .add_stage(stage3)

# Execute only the first stage
puts "\nExecuting first stage only..."
stage1.execute(task4.context)
task4.context.merge!(stage1.value)

puts "\nRendering partially executed task..."
renderer4 = JsonHalRender::Renderer.new(
  task4,
  base_url: 'http://api.example.com',
  task_id: '999'
)

hal_result = renderer4.render
if hal_result.success?
  response = hal_result.value!
  puts "\nStatus: #{response[:status]}"
  puts "\nHAL Document:"
  puts JSON.pretty_generate(response[:body])
end

puts "\n\n"
puts "=" * 80
puts "Examples completed!"
puts "=" * 80
