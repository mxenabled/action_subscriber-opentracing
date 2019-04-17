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
      expect(::OpenTracing.global_tracer.spans.first.operation_name).to eq "FakeSubscriber#fake_action"
    end

    it "tags the active span with routing key and applicable headers" do
      middleware.call(env)
      tags = ::OpenTracing.global_tracer.spans.first.tags
      expect(tags["routing_key"]).to eq properties[:routing_key]
      expect(tags["published_at"]).to eq properties[:headers]["published_at"]
    end
  end
end
