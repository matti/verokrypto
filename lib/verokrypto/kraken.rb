# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Kraken < Source
    attr_reader :events

    def initialize(events)
      super()
      @events = events
    end

    def sort!; end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)

      trade_event_memo = nil
      spend_event_memo = nil

      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        amount = values.fetch('amount')
        asset =
          case values.fetch('asset')
          when 'ZEUR', 'XEUR'
            'EUR'
          when 'XXDG', 'ZXDG'
            'DOGE'
          when 'XETH', 'ZETH'
            'ETH'
          when 'XXBT', 'ZXBT'
            'BTC'
          else
            raise "unknoen asset ticker: #{values.fetch('asset')}"
          end

        date = values.fetch('time')
        id = values.fetch('txid')

        case values.fetch('type')
        when 'deposit'
          e = Verokrypto::Event.new(
            :kraken,
            date: date,
            id: id,
            credit: [
              amount,
              asset
            ]
          )
          e
        when 'withdrawal'
          e = Verokrypto::Event.new(
            :kraken,
            date: date,
            id: id,
            debit: [
              amount,
              asset
            ]
          )
          e
        when 'spend'
          spend_event_memo = {
            date: date,
            from: [
              amount,
              asset
            ],
            to: nil
          }
          nil
        when 'receive'
          e = Verokrypto::Event.new(
            :kraken,
            date: date,
            debit: spend_event_memo[:from],
            credit: [amount, asset]
          )
          e
        # trade is from ledger.csv -
        # 1. row is from_currency
        # 2. row is to_currency
        # fee is in either row (fiat currency row)
        when 'trade'
          fee = values.fetch('fee')

          if trade_event_memo.nil?
            trade_event_memo = {
              date: date,
              from: [
                amount,
                asset
              ],
              to: nil
            }

            if fee != 0
              trade_event_memo[:fee] = [
                fee,
                asset
              ]
            end
          elsif trade_event_memo[:to].nil?
            trade_event_memo[:to] = [
              amount,
              asset
            ]

            if fee != 0
              trade_event_memo[:fee] = [
                fee,
                asset
              ]
            end
          end

          e = nil

          if trade_event_memo[:date] && trade_event_memo[:fee] && trade_event_memo[:to] && trade_event_memo[:from]
            e = Verokrypto::Event.new(
              :kraken,
              date: trade_event_memo[:date],
              fee: trade_event_memo[:fee],
              credit: trade_event_memo[:to],
              debit: trade_event_memo[:from]
            )
            trade_event_memo = nil
          end

          e
        end
      end

      new events
    end
  end
end
