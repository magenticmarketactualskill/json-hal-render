# frozen_string_literal: true

require "spec_helper"

RSpec.describe JsonHalRender::LinkBuilder do
  let(:task) { JsonHalRender::Task.new }
  let(:stage) { JsonHalRender::Stage.new("test_stage") }
  let(:base_url) { "http://api.example.com" }
  let(:task_id) { "123" }

  describe "#build_task_links" do
    let(:link_builder) { described_class.new(base_url, task_id, task) }

    it "includes self link" do
      links = link_builder.build_task_links
      expect(links[:self]).to eq({ href: "http://api.example.com/tasks/123" })
    end

    it "includes stages link" do
      links = link_builder.build_task_links
      expect(links[:stages]).to eq({ href: "http://api.example.com/tasks/123/stages" })
    end

    it "includes start link for incomplete task" do
      links = link_builder.build_task_links
      expect(links[:start]).to eq({ href: "http://api.example.com/tasks/123/start" })
    end

    context "when task has failed stages" do
      before do
        failing_stage = Class.new(JsonHalRender::Stage) do
          private
          def perform_work(_context)
            Failure(error: "failed")
          end
        end.new("failing")
        task.add_stage(failing_stage)
        task.run
      end

      it "includes retry link" do
        links = link_builder.build_task_links
        expect(links[:retry]).to eq({ href: "http://api.example.com/tasks/123/retry" })
      end
    end

    context "when task has pending stages" do
      before do
        task.add_stage(JsonHalRender::Stage.new("stage1"))
        task.add_stage(JsonHalRender::Stage.new("stage2"))
      end

      it "includes next_stage link" do
        links = link_builder.build_task_links
        expect(links[:next_stage]).to eq({ href: "http://api.example.com/tasks/123/stages/stage1" })
      end
    end
  end

  describe "#build_stage_links" do
    let(:link_builder) { described_class.new(base_url, task_id, stage) }

    it "includes self link" do
      links = link_builder.build_stage_links
      expect(links[:self]).to eq({ href: "http://api.example.com/tasks/123/stages/test_stage" })
    end

    it "includes task link" do
      links = link_builder.build_stage_links
      expect(links[:task]).to eq({ href: "http://api.example.com/tasks/123" })
    end

    it "includes execute link for pending stage" do
      links = link_builder.build_stage_links
      expect(links[:execute]).to eq({ href: "http://api.example.com/tasks/123/stages/test_stage/execute" })
    end

    context "when stage has failed" do
      before do
        failing_stage = Class.new(JsonHalRender::Stage) do
          private
          def perform_work(_context)
            Failure(error: "failed")
          end
        end
        @failing = failing_stage.new("failing")
        @failing.execute
      end

      it "includes retry link" do
        link_builder = described_class.new(base_url, task_id, @failing)
        links = link_builder.build_stage_links
        expect(links[:retry]).to eq({ href: "http://api.example.com/tasks/123/stages/failing/retry" })
      end
    end
  end
end
