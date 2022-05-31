# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Koinly < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!; end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)

      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :koinly
        e.id = values.fetch('TxHash')
        e.date = values.fetch('Date')
        e.debit = [
          values.fetch('Sent Amount'),
          values.fetch('Sent Currency')
        ]
        e.credit = [
          values.fetch('Received Amount'),
          values.fetch('Received Currency')
        ]
        e.fee = [
          values.fetch('Fee Amount'),
          values.fetch('Fee Currency')
        ]
        e.net_worth = [
          values.fetch('Net Worth Amount'),
          values.fetch('Net Worth Currency')
        ]
        e.label = values.fetch('Label')
        e.description = values.fetch('Description')

        e
      end

      new events
    end

    def self.to_csv(events)
      CSV.generate do |csv|
        csv << [
          'Date', 'Sent Amount', 'Sent Currency', 'Received Amount', 'Received Currency',
          'Fee Amount', 'Fee Currency', 'Net Worth Amount', 'Net Worth Currency', 'Label', 'Description', 'TxHash'
        ]
        events.each do |event|
          csv << [
            event.date,
            event.debit,
            event.debit&.currency&.id,
            event.credit,
            event.credit&.currency&.id,

            event.fee,
            event.fee&.currency&.id,

            event.net_worth&.to_f,
            event.net_worth&.currency&.id,

            event.label,
            event.description,

            event.id
          ]
        end
      end
    end
  end
end
