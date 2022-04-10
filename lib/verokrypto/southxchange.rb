# frozen_string_literal: true

# require 'time'
module Verokrypto
  class Southxchange < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!
      @events.sort! { |a, b| a.date <=> b.date }
    end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :southxchange
        e.date = values.fetch 'Date_UTC'
        case values.fetch('Type')
        when 'Withdrawal'
          e.debit = [
            values.fetch('Delta').gsub('-', ''),
            values.fetch('Currency')
          ]
          e.id = values.fetch('Withdraw_Hash')
        when 'Deposit'
          e.credit = [
            values.fetch('Delta'),
            values.fetch('Currency')
          ]
          e.id = values.fetch('Deposit_Hash')
        when 'Fee', 'Trade'
          # TODO..
          next
        else
          raise 'wat'
        end

        e
      end.compact

      new events
    end
  end
end
