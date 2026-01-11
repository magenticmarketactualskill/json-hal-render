# frozen_string_literal: true

require "spec_helper"

RSpec.describe JsonHalRender::Stage do
  let(:stage) { described_class.new("test_stage") }

  describe "#initialize" do
    it "sets the stage name" do
      expect(stage.name).to eq("test_stage")
    end

    it "initializes result as nil" do
      expect(stage.result).to be_nil
    end
  end

  describe "#execute" do
    context "when stage has not been performed" do
      it "executes the stage" do
        result = stage.execute
        expect(result).to be_success
      end

      it "sets the result" do
        stage.execute
        expect(stage.result).not_to be_nil
      end
    end

    context "when stage has already been performed" do
      before { stage.execute }

      it "returns the cached result" do
        first_result = stage.result
        second_result = stage.execute
        expect(second_result).to eq(first_result)
      end
    end

    context "when an exception occurs" do
      let(:failing_stage) do
        Class.new(described_class) do
          private

          def perform_work(_context)
            raise StandardError, "Test error"
          end
        end.new("failing_stage")
      end

      it "returns a Failure result" do
        result = failing_stage.execute
        expect(result).to be_failure
      end

      it "includes error details" do
        failing_stage.execute
        error = failing_stage.error
        expect(error[:error]).to eq("Test error")
        expect(error[:stage]).to eq("failing_stage")
        expect(error[:backtrace]).to be_an(Array)
      end
    end
  end

  describe "#performed?" do
    it "returns false before execution" do
      expect(stage.performed?).to be false
    end

    it "returns true after execution" do
      stage.execute
      expect(stage.performed?).to be true
    end
  end

  describe "#success?" do
    it "returns false before execution" do
      expect(stage.success?).to be false
    end

    it "returns true after successful execution" do
      stage.execute
      expect(stage.success?).to be true
    end
  end

  describe "#failure?" do
    it "returns false for successful stage" do
      stage.execute
      expect(stage.failure?).to be false
    end
  end

  describe "#value" do
    it "returns the success value" do
      stage.execute
      expect(stage.value).to include(data: "Stage test_stage completed")
    end
  end

  describe "custom stage with preconditions" do
    let(:conditional_stage) do
      Class.new(described_class) do
        private

        def preconditions_met?(context)
          context[:ready] == true
        end

        def perform_work(_context)
          Success(data: "executed")
        end
      end.new("conditional_stage")
    end

    context "when preconditions are not met" do
      it "returns a Failure result" do
        result = conditional_stage.execute(ready: false)
        expect(result).to be_failure
      end
    end

    context "when preconditions are met" do
      it "executes successfully" do
        result = conditional_stage.execute(ready: true)
        expect(result).to be_success
      end
    end
  end
end
