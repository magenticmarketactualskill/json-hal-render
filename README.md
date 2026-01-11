# JsonHalRender

A Ruby gem that renders Functional Task Supervisor tasks as JSON HAL (Hypertext Application Language) resources, enabling hypermedia-driven task execution and state representation.

## Features

- **Functional Task Execution** - Multi-stage task lifecycle with explicit states (pending/running/completed/failed)
- **Type-Safe Error Handling** - Uses dry-monads Result types (Success/Failure)
- **HAL Resource Representation** - Exposes tasks and stages as navigable hypermedia resources
- **Hypermedia Controls** - Automatic link generation for task navigation and state transitions
- **Embedded Resources** - Includes stage details and execution history
- **Comprehensive Testing** - Full RSpec and Cucumber test coverage

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_hal_render'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install json_hal_render
```

## Quick Start

### Basic Usage

```ruby
require 'json_hal_render'

# Create a task with stages
task = JsonHalRender::Task.new
task.add_stage(JsonHalRender::Stage.new('fetch_data'))
    .add_stage(JsonHalRender::Stage.new('process_data'))
    .add_stage(JsonHalRender::Stage.new('save_data'))

# Render as HAL
renderer = JsonHalRender::Renderer.new(task, base_url: 'http://api.example.com', task_id: '123')
result = renderer.render

if result.success?
  response = result.value!
  puts JSON.pretty_generate(response[:body])
  puts "Content-Type: #{response[:content_type]}"
  puts "Status: #{response[:status]}"
end
```

### Custom Stages

Create custom stages by subclassing `JsonHalRender::Stage`:

```ruby
class FetchDataStage < JsonHalRender::Stage
  private

  def perform_work(context)
    # Your logic here
    data = fetch_from_api
    Success(data: data, records: data.length)
  rescue StandardError => e
    Failure(error: e.message)
  end

  def fetch_from_api
    # API call logic
    [{ id: 1, name: 'Item 1' }, { id: 2, name: 'Item 2' }]
  end
end

class ProcessDataStage < JsonHalRender::Stage
  private

  def perform_work(context)
    # Access data from previous stage
    data = context[:data]
    processed = data.map { |item| item.merge(processed: true) }
    Success(data: processed)
  end
end

# Use custom stages
task = JsonHalRender::Task.new
task.add_stage(FetchDataStage.new('fetch'))
    .add_stage(ProcessDataStage.new('process'))

# Execute the task
result = task.run

if result.success?
  puts "Task completed successfully!"
  puts "Completed stages: #{result.value![:completed]}"
else
  puts "Task failed: #{result.failure[:error]}"
end
```

### Rendering with Options

```ruby
renderer = JsonHalRender::Renderer.new(
  task,
  base_url: 'http://api.example.com',
  task_id: '123',
  created_at: Time.now.iso8601,
  updated_at: Time.now.iso8601
)

# Get HAL document directly
hal_doc = renderer.to_hal

# Get as JSON string
json_string = renderer.to_json
```

## HAL Document Structure

### Pending Task

```json
{
  "_links": {
    "self": { "href": "http://api.example.com/tasks/123" },
    "stages": { "href": "http://api.example.com/tasks/123/stages" },
    "start": { "href": "http://api.example.com/tasks/123/start" },
    "next_stage": { "href": "http://api.example.com/tasks/123/stages/fetch_data" }
  },
  "_embedded": {
    "stages": [
      {
        "_links": {
          "self": { "href": "http://api.example.com/tasks/123/stages/fetch_data" },
          "task": { "href": "http://api.example.com/tasks/123" },
          "execute": { "href": "http://api.example.com/tasks/123/stages/fetch_data/execute" }
        },
        "name": "fetch_data",
        "status": "pending",
        "performed": false
      },
      {
        "_links": {
          "self": { "href": "http://api.example.com/tasks/123/stages/process_data" },
          "task": { "href": "http://api.example.com/tasks/123" },
          "execute": { "href": "http://api.example.com/tasks/123/stages/process_data/execute" }
        },
        "name": "process_data",
        "status": "pending",
        "performed": false
      }
    ]
  },
  "status": "pending",
  "total_stages": 2
}
```

### Completed Task

```json
{
  "_links": {
    "self": { "href": "http://api.example.com/tasks/123" },
    "stages": { "href": "http://api.example.com/tasks/123/stages" }
  },
  "_embedded": {
    "stages": [
      {
        "_links": {
          "self": { "href": "http://api.example.com/tasks/123/stages/fetch_data" },
          "task": { "href": "http://api.example.com/tasks/123" }
        },
        "name": "fetch_data",
        "status": "success",
        "performed": true,
        "value": {
          "data": [...],
          "records": 2
        }
      },
      {
        "_links": {
          "self": { "href": "http://api.example.com/tasks/123/stages/process_data" },
          "task": { "href": "http://api.example.com/tasks/123" }
        },
        "name": "process_data",
        "status": "success",
        "performed": true,
        "value": {
          "data": [...]
        }
      }
    ]
  },
  "status": "completed",
  "total_stages": 2,
  "completed_stages": ["fetch_data", "process_data"]
}
```

### Failed Task

```json
{
  "_links": {
    "self": { "href": "http://api.example.com/tasks/123" },
    "stages": { "href": "http://api.example.com/tasks/123/stages" },
    "retry": { "href": "http://api.example.com/tasks/123/retry" }
  },
  "_embedded": {
    "stages": [...],
    "errors": [
      {
        "error": "Connection timeout",
        "stage": "fetch_data",
        "backtrace": [...]
      }
    ]
  },
  "status": "failed",
  "total_stages": 2,
  "failed_stages": ["fetch_data"]
}
```

## Core Concepts

### Stage

A **Stage** represents a single unit of work with a Result (Success/Failure).

**Stage States:**
- `nil` - Stage has not been run yet
- `Success(data)` - Stage ran successfully
- `Failure(error)` - Stage failed

**Key Methods:**
- `execute(context)` - Execute the stage with given context
- `performed?` - Check if stage has been executed
- `success?` - Check if stage succeeded
- `failure?` - Check if stage failed
- `value` - Get the result value
- `error` - Get the error details

### Task

A **Task** orchestrates the execution of multiple stages.

**Key Methods:**
- `add_stage(stage)` - Add a stage to the task (chainable)
- `run` - Execute all stages in sequence
- `all_successful?` - Check if all stages succeeded
- `any_failed?` - Check if any stage failed
- `successful_results` - Get array of successful stage values
- `failed_results` - Get array of failed stage errors

### Renderer

The **Renderer** converts a Task into a HAL resource.

**Options:**
- `base_url` - Base URL for generating links (default: "")
- `task_id` - Unique identifier for the task (default: "default")
- `include_embedded` - Whether to include embedded resources (default: true)
- `created_at` - Task creation timestamp
- `updated_at` - Task update timestamp

## Rails Integration

### Controller Example

```ruby
class TasksController < ApplicationController
  def show
    task = build_task(params[:id])
    renderer = JsonHalRender::Renderer.new(
      task,
      base_url: request.base_url,
      task_id: params[:id]
    )
    
    result = renderer.render
    
    if result.success?
      response = result.value!
      render json: response[:body],
             content_type: response[:content_type],
             status: response[:status]
    else
      render json: { error: result.failure[:error] },
             status: :internal_server_error
    end
  end
  
  private
  
  def build_task(task_id)
    # Build your task based on task_id
    task = JsonHalRender::Task.new
    task.add_stage(FetchDataStage.new('fetch'))
        .add_stage(ProcessDataStage.new('process'))
    task
  end
end
```

## Testing

### Running Tests

```bash
# Run all tests
bundle exec rake

# Run RSpec tests only
bundle exec rake spec

# Run Cucumber tests only
bundle exec rake features
```

### RSpec Example

```ruby
RSpec.describe MyCustomStage do
  let(:stage) { described_class.new('my_stage') }

  it 'executes successfully' do
    result = stage.execute
    expect(result).to be_success
  end

  it 'returns expected data' do
    stage.execute
    expect(stage.value).to include(data: 'expected')
  end
end
```

### Cucumber Example

```gherkin
Feature: Task Rendering
  Scenario: Render a completed task
    Given I have a task with 2 stages
    And all stages have been executed successfully
    When I render the task as HAL
    Then the response should be successful
    And the status should be "completed"
```

## Architecture

The gem implements a functional task execution pipeline for HAL rendering:

1. **ValidationStage** - Validates task resource structure
2. **LinkResolutionStage** - Builds HAL links based on task state
3. **EmbeddingStage** - Constructs embedded resources (stages, errors)
4. **SerializationStage** - Serializes to HAL JSON format
5. **ResponseStage** - Prepares HTTP response metadata

## API Reference

### JsonHalRender::Stage

```ruby
stage = JsonHalRender::Stage.new('stage_name')
result = stage.execute(context)

# Check state
stage.performed?  # => true/false
stage.success?    # => true/false
stage.failure?    # => true/false

# Access results
stage.value       # => { data: ... }
stage.error       # => { error: ..., stage: ..., backtrace: [...] }
```

### JsonHalRender::Task

```ruby
task = JsonHalRender::Task.new
task.add_stage(stage1)
    .add_stage(stage2)

result = task.run

# Check results
task.all_successful?      # => true/false
task.any_failed?          # => true/false
task.successful_results   # => [...]
task.failed_results       # => [...]
```

### JsonHalRender::Renderer

```ruby
renderer = JsonHalRender::Renderer.new(task, options)
result = renderer.render

# Convenience methods
hal_doc = renderer.to_hal
json_string = renderer.to_json
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/activedataflow/json-hal-render.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Built with:
- [dry-monads](https://dry-rb.org/gems/dry-monads/) - Type-safe error handling
- [dry-effects](https://dry-rb.org/gems/dry-effects/) - Composable effects

Inspired by:
- [Functional Task Supervisor](https://github.com/activedataflow/functional_task_supervisor)
- [JSON HAL Specification](https://datatracker.ietf.org/doc/html/draft-kelly-json-hal)
