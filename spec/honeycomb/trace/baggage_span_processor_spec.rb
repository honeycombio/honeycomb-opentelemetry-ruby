require "opentelemetry"     # API for Baggage access, Span interface for spy
require "opentelemetry/sdk" # SDK in tests to assert Export::SUCCESS

RSpec.describe Honeycomb::OpenTelemetry::Trace::BaggageSpanProcessor do
  let(:processor) { described_class.new }

  describe "#on_start" do
    it "adds current baggage keys/values as attributes when a span starts" do
      context_with_baggage = OpenTelemetry::Baggage.set_value("a_key", "a_value")
      span = instance_spy(OpenTelemetry::Trace::Span)

      processor.on_start(span, context_with_baggage)

      expect(span).to have_received(:add_attributes).with({"a_key" => "a_value"})
    end
  end

  describe "satisfy the SpanProcessor duck type with no-op methods" do
    it "implements #on_finish" do
      expect { processor.on_finish(:literally_anything) }.not_to raise_error
    end

    it "implements #force_flush" do
      expect(processor.force_flush).to eq(::OpenTelemetry::SDK::Trace::Export::SUCCESS)
    end

    it "implements #shutdown" do
      expect(processor.shutdown).to eq(::OpenTelemetry::SDK::Trace::Export::SUCCESS)
    end
  end

end
