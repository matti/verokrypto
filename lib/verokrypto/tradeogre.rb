# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Tradeogre < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!
      case self.name
      when 'tradeogre:trades'
        nil
      when 'tradeogre:deposits'
        @events.reverse!
      when 'tradeogre:withdrawals'
        @events.reverse!
      end
    end

    # Tradeogre timestamps are -4 hours from UTC
    # Add 4 hours to a DateTime timestamp get UTC
    def self.timezone_offset_hours
      4.0/24
    end

    def self.deposits_from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :tradeogre

        e.date = values.fetch('Date')
        e.date_override = e.date + timezone_offset_hours

        e.id = values.fetch('TXID')

        e.credit = [
          values.fetch('Amount'),
          values.fetch('Coin')
        ]
        e
      end

      new events
    end

    def self.withdrawals_from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :tradeogre

        e.date = values.fetch('Date')
        e.date_override = e.date + timezone_offset_hours
        e.id = values.fetch('TXID')

        # TODO: money
        e.debit = [
          (values.fetch('Amount').to_f - values.fetch('Fee').to_f),
          values.fetch('Coin')
        ]
        e.fee = [
          values.fetch('Fee'),
          values.fetch('Coin')
        ]

        e
      end

      new events
    end

    def self.trades_from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :tradeogre

        e.date = values.fetch('Date')
        e.date_override = e.date + timezone_offset_hours

        case values.fetch('Type')
        # BUY,BTC-RTM
        when 'BUY'
          from_currency, to_currency = values.fetch('Exchange').split('-')
          # TODO: Money + wat
          e.debit = [
            values.fetch('Amount').to_f * values.fetch('Price').to_f,
            from_currency
          ]
          e.credit = [
            values.fetch('Amount'),
            to_currency
          ]
          # TODO: also wat
          e.fee = [
            values.fetch('Fee'),
            to_currency
          ]
        # SELL,BTC-RTM
        when 'SELL'
          to_currency, from_currency = values.fetch('Exchange').split('-')
          # TODO: Money + wat
          e.debit = [
            values.fetch('Amount'),
            from_currency
          ]
          e.credit = [
            values.fetch('Amount').to_f * values.fetch('Price').to_f,
            to_currency
          ]
          # TODO: also wat
          e.fee = [
            values.fetch('Fee'),
            from_currency
          ]
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
