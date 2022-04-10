# frozen_string_literal: true

module Verokrypto
  class Coinex < Source
    attr_reader :events

    def initialize(events)
      super()
      @events = events
    end

    def sort!
      # no milliseconds
      # @events.sort! { |a, b| a.date <=> b.date }
      @events.reverse!
    end

    def self.from_xlsx(reader)
      fields, rows = Verokrypto::Helpers.parse_xlsx(reader)

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
      e.id = values

      warn values
      case values.fetch('Side')
      when 'sell'
        # "RTMUSDT".gsub('USDT', '')
        e.debit = [
          values.fetch('Executed Amount'),
          values.fetch('Trading pair/Contract name').gsub(values.fetch('Fees Coin Type'), '')
        ]
        e.credit = [
          values.fetch('Executed Value'),
          values.fetch('Fees Coin Type')
        ]
      when 'buy'
        e.debit = [
          values.fetch('Executed Value'),
          values.fetch('Trading pair/Contract name').gsub(values.fetch('Fees Coin Type'), '')
        ]
        e.credit = [
          values.fetch('Executed Amount'),
          values.fetch('Fees Coin Type')
        ]
      else
        raise values.to_s
      end

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
      ]

      warn e
      e.original = values

      e
    end
  end
end
