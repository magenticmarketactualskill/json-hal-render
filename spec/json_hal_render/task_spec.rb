# frozen_string_literal: true

require "spec_helper"

RSpec.describe JsonHalRender::Task do
  let(:task) { described_class.new }
  let(:stage1) { JsonHalRender::Stage.new("stage1") }
  let(:stage2) { JsonHalRender::Stage.new("stage2") }

  describe "#add_stage" do
    it "adds a stage to the task" do
      task.add_stage(stage1)
      expect(task.stages).to include(stage1)
    end

    it "returns self for chaining" do
      result = task.add_stage(stage1)
      expect(result).to eq(task)
    end

    it "allows chaining multiple stages" do
      task.add_stage(stage1).add_stage(stage2)
      expect(task.stages).to eq([stage1, stage2])
    end
  end

  describe "#run" do
    before do
      task.add_stage(stage1).add_stage(stage2)
    end

    it "executes all stages in order" do
      result = task.run
      expect(result).to be_success
      expect(stage1.performed?).to be true
      expect(stage2.performed?).to be true
    end

    it "returns a Success result with completed stages" do
      result = task.run
      expect(result.value![:completed]).to eq(["stage1", "stage2"])
    end

    it "merges stage results into context" do
      result = task.run
      expect(result.value![:context]).to be_a(Hash)
    end

    context "when a stage fails" do
      let(:failing_stage) do
        Class.new(JsonHalRender::Stage) do
          private

          def perform_work(_context)
            Failure(error: "Stage failed")
          end
        end.new("failing_stage")
      end

      before do
        task.add_stage(stage1)
        task.add_stage(failing_stage)
        task.add_stage(stage2)
      end

      it "stops execution at the failed stage" do
        result = task.run
        expect(result).to be_failure
        expect(stage1.performed?).to be true
        expect(failing_stage.performed?).to be true
        expect(stage2.performed?).to be false
      end

      it "returns failure details" do
        result = task.run
        failure = result.failure
        expect(failure[:error]).to include("failing_stage")
        expect(failure[:stage]).to eq("failing_stage")
      end
    end
  end

  describe "#all_successful?" do
    before do
      task.add_stage(stage1).add_stage(stage2)
    end

    it "returns false before execution" do
      expect(task.all_successful?).to be false
    end

    it "returns true when all stages succeed" do
      task.run
      expect(task.all_successful?).to be true
    end
  end

  describe "#any_failed?" do
    before do
      task.add_stage(stage1).add_stage(stage2)
    end

    it "returns false when all stages succeed" do
      task.run
      expect(task.any_failed?).to be false
    end
  end

  describe "#successful_results" do
    before do
      task.add_stage(stage1).add_stage(stage2)
      task.run
    end

    it "returns array of successful stage values" do
      results = task.successful_results
      expect(results).to be_an(Array)
      expect(results.length).to eq(2)
    end
  end

  describe "#failed_results" do
    before do
      task.add_stage(stage1).add_stage(stage2)
      task.run
    end

    it "returns empty array when no failures" do
      results = task.failed_results
      expect(results).to be_empty
    end
  end
end
