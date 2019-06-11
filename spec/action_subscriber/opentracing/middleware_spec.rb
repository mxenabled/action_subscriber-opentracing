RSpec.describe ActionSubscriber::OpenTracing::Middleware do
  let(:app) { lambda { |env| env } }
  let(:middleware) { described_class.new(app) }
  let(:env) { ::ActionSubscriber::Middleware::Env.new(FakeSubscriber, nil, properties) }

  let(:properties) {
    {
      :action => "fake_action",
      :delivery_tag => nil,
      :exchange => nil,
      :message_id => nil,
      :queue => nil,
      :content_type => "application/protocol-buffers",
      :routing_key => "test.testing",
      :headers => {
        "published_at" => Time.now.strftime("%F %T.%3N %Z")
      }
    }
  }

  before { ::OpenTracing.global_tracer = ::OpenTracingTestTracer.build }
  after { ::OpenTracing.global_tracer = ::OpenTracing::Tracer.new }

  describe "#call" do
    it "starts a span" do
      middleware.call(env)
      expect(::OpenTracing.global_tracer.spans.size).to be 1
    end

    it "uses the subscriber and action in the operation name" do
      middleware.call(env)
      expect(::OpenTracing.global_tracer.spans.first.operation_name).to eq "Subscriber FakeSubscriber#fake_action"
    end

    it "tags the active span with routing key and applicable headers/information" do
      middleware.call(env)
      tags = ::OpenTracing.global_tracer.spans.first.tags
      expect(tags["span.kind"]).to eq "consumer"
      expect(tags["message_bus.destination"]).to eq properties[:routing_key]
      expect(tags["message_bus.published_at"]).to eq properties[:headers]["published_at"]
      expect(tags["message_bus.processed_at"]).to_not be_nil
    end

    it "references parent span as follows_from when tracing context is found in the headers" do
      # Create a span only toinject the context into the headers in the test
      # properties.
      ::OpenTracing.start_active_span("parent") do
        ::OpenTracing.inject(::OpenTracing.active_span.context,
                             ::OpenTracing::FORMAT_TEXT_MAP,
                             properties[:headers])
      end

      middleware.call(env)

      parent_span = OpenTracing.global_tracer.spans.first
      child_span = OpenTracing.global_tracer.spans.last

      expect(child_span.references.first.context.trace_id).to eq parent_span.context.trace_id
      expect(child_span.references.first.type).to eq "follows_from"
    end
  end
end
