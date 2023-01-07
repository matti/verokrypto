# frozen_string_literal: true

# require 'time'
module Verokrypto
  class Coinbase < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!
      @events.sort! { |a, b| a.date <=> b.date }
    end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :coinbase

        e.date = values.fetch 'Timestamp'
        e.description = values.fetch 'Notes'

        case values.fetch('Transaction Type')
        when 'Buy'
          e.debit = [
            values.fetch('Subtotal'),
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
        when 'Sell'
          e.debit = [
            values.fetch('Quantity Transacted'),
            values.fetch('Asset')
          ]
          e.credit = [
            values.fetch('Total (inclusive of fees)'),
            values.fetch('Spot Price Currency')
          ]
          e.fee = [
            values.fetch('Fees'),
            values.fetch('Spot Price Currency')
          ]
        when 'Send'
          e.debit = [
            values.fetch('Quantity Transacted'),
            values.fetch('Asset')
          ]
        when 'Receive'
          e.credit = [
            values.fetch('Quantity Transacted'),
            values.fetch('Asset')
          ]

          # TODO: lol
          if e.date > DateTime.new(2021, 1, 1) && (e.description.include? 'ETH from an external account')
            e.label = 'mining'
          end
        when 'Convert'
          # Converted 0.0116669 BTC to 0.37286592 ETH
          credit_amount, credit_currency = values.fetch('Notes').split.last(2)
          e.debit = [
            values.fetch('Quantity Transacted'),
            values.fetch('Asset')
          ]
          e.credit = [
            credit_amount,
            credit_currency
          ]
          e.fee = [
            values.fetch('Fees'),
            values.fetch('Spot Price Currency')
          ]
        when 'Coinbase Earn'
          e.credit = [
            values.fetch('Quantity Transacted'),
            values.fetch('Asset')
          ]
        when 'Learning Reward'
          e.credit = [
            values.fetch('Quantity Transacted'),
            values.fetch('Asset')
          ]
        else
          pp e
          raise 'wat'
        end

        e
      end
      new events
    end
  end
end
