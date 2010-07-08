# Redis instrumentation contributed by Ashley Martens of ngmoco
#                       updated by Jesse Newland of Rails Machine

if (defined?(::Redis::Client) && !NewRelic::Control.instance['disable_redis'])

  class Redis
    class Client

      include NewRelic::Agent::MethodTracer

      def logging_with_newrelic_trace(commands, &block)
        metrics = []
        if NewRelic::Agent::Instrumentation::MetricFrame.recording_web_transaction?
          metrics << 'Database/Redis/allWeb'
        else
          metrics << 'Database/Redis/allOther'
        end
        commands.each do |name, *args|
          method_name = name.to_s
          metrics << "Database/Redis/#{method_name}"
          # NewRelic::Control.instance.log.debug("Instrumenting Redis Call[#{method_name}], #{metrics.join(',')}")
        end
        self.class.trace_execution_scoped(metrics) do
          logging_without_newrelic_trace(commands, &block)
        end
      end

      # alias_method_chain :raw_call_command, :newrelic_trace
      alias logging_without_newrelic_trace logging
      alias logging logging_with_newrelic_trace

    end
  end
end
