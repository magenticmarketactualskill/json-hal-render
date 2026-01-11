# frozen_string_literal: true

Given("I have a task with {int} stages") do |count|
  @task = JsonHalRender::Task.new
  count.times do |i|
    @task.add_stage(JsonHalRender::Stage.new("stage#{i + 1}"))
  end
end

Given("the first stage has been executed") do
  @task.stages.first.execute
end

Given("all stages have been executed successfully") do
  @task.run
end

Given("I have a task with a failing stage") do
  @task = JsonHalRender::Task.new
  @task.add_stage(JsonHalRender::Stage.new("stage1"))
  
  failing_stage = Class.new(JsonHalRender::Stage) do
    private
    def perform_work(_context)
      Failure(error: "Intentional failure")
    end
  end.new("failing_stage")
  
  @task.add_stage(failing_stage)
end

Given("the task has been executed") do
  @task.run
end

When("I render the task as HAL") do
  @renderer = JsonHalRender::Renderer.new(@task)
  @result = @renderer.render
end

When("I render the task as HAL with base URL {string} and task ID {string}") do |base_url, task_id|
  @renderer = JsonHalRender::Renderer.new(@task, base_url: base_url, task_id: task_id)
  @result = @renderer.render
end

Then("the response should be successful") do
  expect(@result).to be_success
end

Then("the HAL document should have a self link") do
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:_links][:self]).not_to be_nil
end

Then("the status should be {string}") do |expected_status|
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:status]).to eq(expected_status)
end

Then("the total stages should be {int}") do |expected_count|
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:total_stages]).to eq(expected_count)
end

Then("the completed stages should include {string}") do |stage_name|
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:completed_stages]).to include(stage_name)
end

Then("the failed stages should include {string}") do |stage_name|
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:failed_stages]).to include(stage_name)
end

Then("the embedded resources should include errors") do
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:_embedded][:errors]).not_to be_nil
end

Then("the HAL document should have a self link to {string}") do |expected_url|
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:_links][:self][:href]).to eq(expected_url)
end

Then("the HAL document should have a stages link to {string}") do |expected_url|
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:_links][:stages][:href]).to eq(expected_url)
end

Then("the HAL document should have a start link to {string}") do |expected_url|
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:_links][:start][:href]).to eq(expected_url)
end

Then("the embedded resources should include stages") do
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:_embedded][:stages]).not_to be_nil
end

Then("there should be {int} embedded stages") do |expected_count|
  @hal_doc = @result.value![:body]
  expect(@hal_doc[:_embedded][:stages].length).to eq(expected_count)
end

Then("each embedded stage should have a name") do
  @hal_doc = @result.value![:body]
  @hal_doc[:_embedded][:stages].each do |stage|
    expect(stage[:name]).not_to be_nil
  end
end

Then("each embedded stage should have a status") do
  @hal_doc = @result.value![:body]
  @hal_doc[:_embedded][:stages].each do |stage|
    expect(stage[:status]).not_to be_nil
  end
end
