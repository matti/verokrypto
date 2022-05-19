# frozen_string_literal: true

require 'csv'

module Verokrypto
  module Koinly
    def self.events_from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)

      events = []
      rows.each do |row|
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

        events << e
      end

      events
    end

    def self.events_to_csv(events)
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

            nil, # net worth amount
            nil, # net worth currency

            event.label, # label
            event.description,

            event.id
          ]
        end
      end
    end
  end
end
