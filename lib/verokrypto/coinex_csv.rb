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
      @events.reverse!
    end

    # CSV has a single trade in three rows
    # 1. row is FEE -0.18910
    # 2. row is TO_CURRENCY USDT,+67.89123
    # 3. row is FROM_CURRENCY RTM,-321.01234
    def self.parse_transactions(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)

      trade_event_memo = nil

      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)

        case values.fetch('Operation')
        when 'trade'
          if trade_event_memo.nil?
            trade_event_memo = {
              date: values.fetch('Time'),
              fee: [
                values.fetch('Asset change'),
                values.fetch('Coin')
              ],
              to: nil,
              from: nil
            }
          elsif trade_event_memo[:to].nil?
            trade_event_memo[:to] = [
              values.fetch('Asset change'),
              values.fetch('Coin')
            ]
          elsif trade_event_memo[:from].nil?
            trade_event_memo[:from] = [
              values.fetch('Asset change'),
              values.fetch('Coin')
            ]
          end

          e = nil

          if trade_event_memo[:date] && trade_event_memo[:fee] && trade_event_memo[:to] && trade_event_memo[:from]
            e = Verokrypto::Event.new(
              :coinex_trade,
              date: trade_event_memo[:date],
              fee: trade_event_memo[:fee],
              credit: trade_event_memo[:to],
              debit: trade_event_memo[:from]
            )
            trade_event_memo = nil
          end

          e
        when 'withdraw'
          e = Verokrypto::Event.new(
            :coinex_withdrawal,
            date: values.fetch('Time'),
            debit: [
              values.fetch('Asset change'),
              values.fetch('Coin')
            ]
          )

          e
        when 'deposit'
          e = Verokrypto::Event.new(
            :coinex_deposit,
            date: values.fetch('Time'),
            credit: [
              values.fetch('Asset change'),
              values.fetch('Coin')
            ]
          )

          if e.date < DateTime.new(2022, 7, 25) && values.fetch('Coin') == 'ETH'
            e.label = 'mining'
          end

          e
        else
          raise 'Coinex: unknown operation'
        end
      end

      new events
    end
  end
end
