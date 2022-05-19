# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Raptoreum < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!; end

    def self.from_csv(reader, extras)
      received_labels = YAML.safe_load(File.read(extras.first))
      sent_labels = YAML.safe_load(File.read(extras.last))

      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :raptoreum

        e.date = values.fetch('Date')
        e.id = values.fetch('ID')
        e.description = values.fetch('Label')

        case values.fetch('Type')
        when 'Received with'
          label = values.fetch('Label')
          e.label = received_labels.fetch(label)

          e.credit = [
            values.fetch('Amount (RTM)'),
            'RTM'
          ]
        when 'Sent to'
          label = values.fetch('Label')
          e.label = sent_labels.fetch(label)

          e.debit = [
            values.fetch('Amount (RTM)').gsub('-', ''),
            'RTM'
          ]
        when 'Payment to yourself'
          # fee tx
          e.debit = [
            values.fetch('Amount (RTM)').gsub('-', ''),
            'RTM'
          ]
          e.label = 'cost'
          e.id = values.fetch('ID')
        when 'Mined'
          # smartnode reward
          e.credit = [
            values.fetch('Amount (RTM)').gsub('-', ''),
            'RTM'
          ]
          e.label = 'reward'
          e.id = values.fetch('ID')
        else
          pp values
          raise 'wat'
        end
        e
      end

      new events
    end
  end
end
