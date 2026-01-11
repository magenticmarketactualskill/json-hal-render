# frozen_string_literal: true

require "spec_helper"

RSpec.describe JsonHalRender::Renderer do
  let(:task) { JsonHalRender::Task.new }
  let(:stage1) { JsonHalRender::Stage.new("fetch_data") }
  let(:stage2) { JsonHalRender::Stage.new("process_data") }
  let(:options) do
    {
      base_url: "http://api.example.com",
      task_id: "123"
    }
  end
  let(:renderer) { described_class.new(task, options) }

  before do
    task.add_stage(stage1).add_stage(stage2)
  end

  describe "#initialize" do
    it "sets the task resource" do
      expect(renderer.task_resource).to eq(task)
    end

    it "sets the options" do
      expect(renderer.options).to eq(options)
    end
  end

  describe "#render" do
    it "returns a Success result" do
      result = renderer.render
      expect(result).to be_success
    end

    it "includes response metadata" do
      result = renderer.render
      response = result.value!
      expect(response[:body]).to be_a(Hash)
      expect(response[:content_type]).to eq("application/hal+json")
      expect(response[:status]).to be_a(Integer)
    end

    it "includes HAL structure in body" do
      result = renderer.render
      body = result.value![:body]
      expect(body).to have_key(:_links)
      expect(body).to have_key(:status)
    end

    it "includes task properties" do
      result = renderer.render
      body = result.value![:body]
      expect(body[:total_stages]).to eq(2)
      expect(body[:status]).to eq("pending")
    end

    context "when task has executed stages" do
      before do
        stage1.execute
      end

      it "reflects the execution state" do
        result = renderer.render
        body = result.value![:body]
        expect(body[:status]).to eq("running")
      end
    end

    context "when all stages are successful" do
      before do
        task.run
      end

      it "shows completed status" do
        result = renderer.render
        body = result.value![:body]
        expect(body[:status]).to eq("completed")
        expect(body[:completed_stages]).to eq(["fetch_data", "process_data"])
      end
    end
  end

  describe "#to_hal" do
    it "returns the HAL document" do
      hal = renderer.to_hal
      expect(hal).to be_a(Hash)
      expect(hal).to have_key(:_links)
    end

    it "returns nil on failure" do
      allow_any_instance_of(JsonHalRender::RenderingTask).to receive(:run)
        .and_return(Dry::Monads::Failure(error: "test error"))
      
      hal = renderer.to_hal
      expect(hal).to be_nil
    end
  end

  describe "#to_json" do
    it "returns a JSON string" do
      json = renderer.to_json
      expect(json).to be_a(String)
      parsed = JSON.parse(json)
      expect(parsed).to have_key("_links")
    end
  end

  describe "HAL links" do
    it "includes self link" do
      hal = renderer.to_hal
      expect(hal[:_links][:self]).to eq({ href: "http://api.example.com/tasks/123" })
    end

    it "includes stages link" do
      hal = renderer.to_hal
      expect(hal[:_links][:stages]).to eq({ href: "http://api.example.com/tasks/123/stages" })
    end

    it "includes start link for pending task" do
      hal = renderer.to_hal
      expect(hal[:_links][:start]).to eq({ href: "http://api.example.com/tasks/123/start" })
    end
  end

  describe "HAL embedded resources" do
    it "includes embedded stages" do
      hal = renderer.to_hal
      expect(hal[:_embedded][:stages]).to be_an(Array)
      expect(hal[:_embedded][:stages].length).to eq(2)
    end

    it "includes stage details" do
      hal = renderer.to_hal
      first_stage = hal[:_embedded][:stages].first
      expect(first_stage[:name]).to eq("fetch_data")
      expect(first_stage[:status]).to eq("pending")
      expect(first_stage[:performed]).to be false
    end
  end
end
