# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Raptoreum < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!; end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :raptoreum
        # pp values
        e.date = values.fetch('Date')

        case values.fetch('Type')
        when 'Received with'
          # mining
          e.credit = [
            values.fetch('Amount (RTM)'),
            'RTM'
          ]
          e.label = 'mining'
          e.description = values.fetch('Label')
        when 'Sent to'
          e.debit = [
            values.fetch('Amount (RTM)'),
            'RTM'
          ]

          e.description = values.fetch('Label')
          e.id = values.fetch('ID')
        when 'Payment to yourself'
          # TODO: mites inodez, mafianode btc
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
