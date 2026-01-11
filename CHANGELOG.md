# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-10

### Added
- Initial release of json-hal-render gem
- Core Stage and Task classes for functional task execution
- HAL resource representation with BaseResource, TaskResource, and StageResource
- LinkBuilder for automatic HAL link generation
- EmbeddingBuilder for embedded resource construction
- Five-stage rendering pipeline:
  - ValidationStage
  - LinkResolutionStage
  - EmbeddingStage
  - SerializationStage
  - ResponseStage
- Renderer class with simple API for task rendering
- Comprehensive RSpec unit tests
- Cucumber integration tests with feature scenarios
- Full documentation and examples
- Support for task states: pending, running, completed, failed
- Automatic link generation based on task state
- Embedded stage resources with execution details
- Error tracking and reporting for failed stages
- Type-safe error handling with dry-monads
- Context passing between stages

### Dependencies
- dry-monads ~> 1.6
- dry-effects ~> 0.4

[0.1.0]: https://github.com/activedataflow/json-hal-render/releases/tag/v0.1.0
