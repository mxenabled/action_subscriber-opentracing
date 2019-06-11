# frozen_string_literal: true

require "opentracing"

module ActionSubscriber
  module OpenTracing
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        operation = "Subscriber #{env.subscriber}##{env.action}"
        parent = ::OpenTracing.extract(::OpenTracing::FORMAT_TEXT_MAP, env.headers)
        published_at = env.headers["published_at"]

        options = {}
        options[:references] = [::OpenTracing::Reference.follows_from(parent)] if parent
        options[:tags] = {
          "span.kind" => "consumer",
          "component" => "ActionSubscriber",
          "message_bus.destination" => env.routing_key,
          "message_bus.processed_at" => Time.now.strftime("%F %T.%3N %Z")
        }

        options[:tags]["message_bus.published_at"] = published_at if published_at

        result = nil
        ::OpenTracing.start_active_span(operation, options) do
          result = @app.call(env)
        end
        result
      end
    end
  end
end
