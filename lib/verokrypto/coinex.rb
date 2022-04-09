# frozen_string_literal: true

module Verokrypto
  class Coinex < Source
    attr_reader :events

    def initialize(events)
      super()
      @events = events
    end

    def self.from_xlsx(path)
      fields, rows = Verokrypto::Xlsx.new(path).parse

      events = []
      rows.each do |row|
        values = {}
        fields.each do |field|
          values[field] = row.shift
        end

        events << to_event(values)
      end

      new events
    end

    def self.to_event(values)
      e = Verokrypto::Event.new :coinex
      e.original = values
      e.date = "#{values.fetch('Execution Time')} UTC"

      # from_amount:
      #   from_currency:
      #   to_amount:
      #   to_currency:

      # fee_amount: values.fetch("Fees")
      # fee_currency:

      # net_amount:
      # net_currency:

      # label:
      # description:
      # tx:

      e.fee = [
        values.fetch('Fees'),
        values.fetch('Fees Coin Type')
      ].join(' ')

      e
    end
  end
end
