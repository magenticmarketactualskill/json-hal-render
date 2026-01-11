Feature: Task Rendering
  As a developer
  I want to render tasks as HAL resources
  So that I can expose task workflows through hypermedia APIs

  Scenario: Render a pending task
    Given I have a task with 2 stages
    When I render the task as HAL
    Then the response should be successful
    And the HAL document should have a self link
    And the status should be "pending"
    And the total stages should be 2

  Scenario: Render a running task
    Given I have a task with 2 stages
    And the first stage has been executed
    When I render the task as HAL
    Then the response should be successful
    And the status should be "running"
    And the completed stages should include "stage1"

  Scenario: Render a completed task
    Given I have a task with 2 stages
    And all stages have been executed successfully
    When I render the task as HAL
    Then the response should be successful
    And the status should be "completed"
    And the completed stages should include "stage1"
    And the completed stages should include "stage2"

  Scenario: Render a failed task
    Given I have a task with a failing stage
    And the task has been executed
    When I render the task as HAL
    Then the response should be successful
    And the status should be "failed"
    And the failed stages should include "failing_stage"
    And the embedded resources should include errors

  Scenario: HAL document includes proper links
    Given I have a task with 2 stages
    When I render the task as HAL with base URL "http://api.example.com" and task ID "123"
    Then the HAL document should have a self link to "http://api.example.com/tasks/123"
    And the HAL document should have a stages link to "http://api.example.com/tasks/123/stages"
    And the HAL document should have a start link to "http://api.example.com/tasks/123/start"

  Scenario: HAL document includes embedded stages
    Given I have a task with 2 stages
    When I render the task as HAL
    Then the embedded resources should include stages
    And there should be 2 embedded stages
    And each embedded stage should have a name
    And each embedded stage should have a status
