# frozen_string_literal: true

# require 'time'
module Verokrypto
  class Coinex < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!
      # no milliseconds
      # @events.sort! { |a, b| a.date <=> b.date }
      @events.reverse!
    end

    def self.assets_from_xlsx(reader)
      fields, rows = Verokrypto::Helpers.parse_xlsx(reader)
      events = []
      rows.each do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)

        e = Verokrypto::Event.new :coinex_asset

        status = values.fetch('Status')
        next if status == 'cancel'
        raise "unknown '#{status}'" unless status == 'finish'

        e.id = values.fetch('TXID')

        if values['Withdrawal time']
          e.date = values.fetch('Withdrawal time')
          # dates are +3h, so -3h
          e.date_override = e.date - (3.0 / 24)
          e.debit = [
            values.fetch('Amount'),
            values.fetch('Coin')
          ]
        else
          e.date = values.fetch('Deposit time')
          # dates are +3h, so -3h
          e.date_override = e.date - (3.0 / 24)
          e.credit = [
            values.fetch('Amount'),
            values.fetch('Coin')
          ]
        end

        events << e
      end

      new events
    end

    def self.trades_from_xlsx(reader)
      fields, rows = Verokrypto::Helpers.parse_xlsx(reader)

      events = rows.map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :coinex_trade
        e.description = row.join(',')

        e.date = "#{values.fetch('Execution Time')} UTC"
        e.fee = [
          values.fetch('Fees'),
          values.fetch('Fees Coin Type')
        ]

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

        e
      end

      new events
    end
  end
end
