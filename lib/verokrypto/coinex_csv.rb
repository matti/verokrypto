# frozen_string_literal: true

require 'csv'

module Verokrypto
  class CoinexCsv < Source
    attr_reader :events

    def initialize(events)
      super()
      @events = events
    end

    def sort!
      return
    end

    def self.deposits(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)

      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)

        e = Verokrypto::Event.new :coinex_deposit

        e.date = values.fetch('Time')

        e.credit = [
          values.fetch('Asset change'),
          values.fetch('Coin')
        ]

        e
      end

      new events
    end

    def self.withdrawals(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)

      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)

        e = Verokrypto::Event.new :coinex_withdrawal

        e.date = values.fetch('Time')

        e.debit = [
          values.fetch('Asset change'),
          values.fetch('Coin')
        ]

        e
      end

      new events
    end

    # CSV has a single trade in three rows
    # 1. row is FEE -0.18910
    # 2. row is TO_CURRENCY USDT,+67.89123
    # 3. row is FROM_CURRENCY RTM,-321.01234
    def self.trades(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)

      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)

        e = Verokrypto::Event.new :coinex_trade

        e.date = values.fetch('Time')

        e.debit = [
          values.fetch('Asset change'),
          values.fetch('Coin')
        ]

        e
      end

      new events
    end
  end
end
