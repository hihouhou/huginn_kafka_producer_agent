require "rdkafka"

module Agents
  class KafkaProducerAgent < Agent
    include FormConfigurable
#    can_dry_run!
    no_bulk_receive!
    default_schedule 'every_1m'

    description <<-MD
      The Kafka Producer Agent produces messages to a Kafka topic and creates events from them.
      
      It requires the `kafka` gem.
      
      Set the following options:
      
      The `topic` is the name of the topic to consume.
      
      The `message` is content of the payload.

      The `brokers` is a comma-separated list of Kafka brokers to connect to.

      The `debug` can add verbosity.

      Set `expected_update_period_in_days` to the maximum amount of time that you'd expect to pass between Events being created by this Agent.

    MD

    event_description <<-MD
      Events look like this:

          {
          }
    MD

    def default_options
      {
        'topic' => "test",
        'brokers' => "kafka:9092",
        'debug' => 'false',
        'message' => '',
        'expected_receive_period_in_days' => '2'
      }
    end

    form_configurable :topic, type: :string
    form_configurable :brokers, type: :string
    form_configurable :message, type: :string
    form_configurable :debug, type: :boolean
    form_configurable :expected_receive_period_in_days, type: :string
    def validate_options
      errors.add(:base, "topic is required") unless options["topic"].present?

      errors.add(:base, "brokers is required") unless options["brokers"].present?

      errors.add(:base, "message is required") unless options["message"].present?

      if options.has_key?('debug') && boolify(options['debug']).nil?
        errors.add(:base, "if provided, debug must be true or false")
      end
    end

    def working?
      !recent_error_logs?
    end

    def check
      config = {:"bootstrap.servers" => interpolated['brokers']}
      producer = Rdkafka::Config.new(config).producer
      delivery_handles = []
      
        if interpolated['debug'] == 'true'
          log "Producing message: #{interpolated['message']}"
        end
        delivery_handles << producer.produce(
            topic:   interpolated['topic'],
            payload: interpolated['message']
        )
      
      delivery_handles.each(&:wait)
    end
  end
end
