# frozen_string_literal: true

require_relative "lib/json_hal_render/version"

Gem::Specification.new do |spec|
  spec.name = "json_hal_render"
  spec.version = JsonHalRender::VERSION
  spec.authors = ["Manus AI"]
  spec.email = ["info@example.com"]

  spec.summary = "Render Functional Task Supervisor tasks as JSON HAL resources"
  spec.description = "A Ruby gem that integrates Functional Task Supervisor with JSON HAL to provide hypermedia-driven task execution and state representation"
  spec.homepage = "https://github.com/activedataflow/json-hal-render"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.6"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z 2>/dev/null`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "dry-monads", "~> 1.6"
  spec.add_dependency "dry-effects", "~> 0.4"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "rubocop", "~> 1.50"
end
