# frozen_string_literal: true

# require 'time'
module Verokrypto
  class Coinbase < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!; end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :coinbase

        e.date = values.fetch 'Timestamp'
        case values.fetch('Transaction Type')
        when 'Buy'
          e.debit = [
            values.fetch('Total (inclusive of fees)'),
            values.fetch('Spot Price Currency')
          ]
          e.credit = [
            values.fetch('Quantity Transacted'),
            values.fetch('Asset')
          ]
          e.fee = [
            values.fetch('Fees'),
            values.fetch('Spot Price Currency')
          ]
        when 'Send'
          # Sent 0.06249984 BTC to WALLETID
          # address = values.fetch('Notes').split.last
          e.debit = [
            values.fetch('Quantity Transacted'),
            values.fetch('Asset')
          ]
        when 'Sell', 'Receive', 'Convert'
          # TODO
          next
        else
          raise 'wat'
        end

        e
      end

      new events
    end
  end
end
