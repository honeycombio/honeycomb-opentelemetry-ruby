# frozen_string_literal: true

require "opentelemetry"     # API for Baggage access, Span interface for spy
require "opentelemetry/sdk" # SDK in tests to assert Export::SUCCESS

RSpec.describe Honeycomb::OpenTelemetry::Trace::BaggageSpanProcessor do
  let(:processor) { described_class.new }

  describe "#on_start" do
    let(:span) { instance_spy(OpenTelemetry::Trace::Span) }
    let(:context_with_baggage) { OpenTelemetry::Baggage.set_value("a_key", "a_value") }

    it "adds current baggage keys/values as attributes when a span starts" do
      processor.on_start(span, context_with_baggage)
      expect(span).to have_received(:add_attributes).with({ "a_key" => "a_value" })
    end

    it "does not blow up when given nil context" do
      expect { processor.on_start(span, nil) }.not_to raise_error
    end
    it "does not blow up when given nil span" do
      expect { processor.on_start(nil, context_with_baggage) }.not_to raise_error
    end
    it "does not blow up when given nil span and context" do
      expect { processor.on_start(nil, nil) }.not_to raise_error
    end
    it "does not blow up when given a context that is not a Context" do
      expect { processor.on_start(span, :not_a_context) }.not_to raise_error
    end
    it "does not blow up when given a span that is not a Span" do
      expect { processor.on_start(:not_a_span, context_with_baggage) }.not_to raise_error
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
