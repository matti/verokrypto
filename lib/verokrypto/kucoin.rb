# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Kucoin < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!
      # TODO
    end

    def self.deposits_from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :kucoin

        raise 'NOT DEPOSIT' if values.fetch('Remarks') != 'Deposit'
        raise 'NOT SUCCESS' if values.fetch('Status') != 'SUCCESS'

        e.date = DateTime.parse(values.fetch('Time(UTC+03:00)')) - (3 * 1 / 24r)

        # before this something was sent from coinbase, after this direct from ethermine
        e.label = 'mining' if values.fetch('Coin') == 'ETH' && e.date.year == 2022 && e.date.month >= 2

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
        e = Verokrypto::Event.new :kucoin

        raise 'NOT SUCCESS' if values.fetch('Status') != 'SUCCESS'

        e.date = DateTime.parse(values.fetch('Time(UTC+03:00)')) - (3 * 1 / 24r)
        e.description = values.fetch('Remarks').to_s + ' ' + values.fetch('Withdrawal Address/Account')

        e.debit = [
          values.fetch('Amount'),
          values.fetch('Coin')
        ]

        e
      end

      new events
    end

    def self.spot_from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :kucoin

        case values.fetch('Status')
        when 'deal', 'part_deal'
        else
          raise 'WAT status'
        end

        e.id = values.fetch 'Order ID'
        e.date = DateTime.parse(values.fetch('Order Time(UTC+03:00)')) - (3 * 1 / 24r)
        first_currency, second_currency = values.fetch('Symbol').split('-')

        case values.fetch('Side')
        when 'SELL'
          e.debit = [
            values.fetch('Order Amount'),
            first_currency
          ]
          e.credit = [
            values.fetch('Filled Volume'),
            second_currency
          ]
        when 'BUY'
          e.credit = [
            values.fetch('Filled Amount'),
            first_currency
          ]
          e.debit = [
            values.fetch('Filled Volume'),
            second_currency
          ]
        else
          raise 'wat'
        end

        e
      end

      new events
    end

    def self.tradingbot_from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :kucoin

        e.id = values.fetch 'Order ID'
        e.date = DateTime.parse(values.fetch('Time Filled(UTC+03:00)')) - (3 * 1 / 24r)

        first_currency, second_currency = values.fetch('Symbol').split('-')

        case values.fetch('Side')
        when 'BUY'
          e.credit = [
            values.fetch('Filled Amount'),
            first_currency
          ]
          e.debit = [
            values.fetch('Filled Volume'),
            second_currency
          ]
        when 'SELL'
          e.debit = [
            values.fetch('Filled Amount'),
            first_currency
          ]
          e.credit = [
            values.fetch('Filled Volume'),
            second_currency
          ]

        else
          raise 'wat'
        end
        e
      end

      new events
    end
  end
end
