# frozen_string_literal: true

# require 'time'
module Verokrypto
  class Southxchange < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!
      # southxchange has same timestamps, so ruby sorting fucks up
      # same timestamp increasing requires reverse order
      @events.reverse!
    end

    def self.from_csv(reader, csv_paths)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :southxchange
        e.date = values.fetch 'Date_UTC'

        case values.fetch('Type')
        when 'Withdrawal'
          e.debit = [
            values.fetch('Delta').sub('-', ''),
            values.fetch('Currency')
          ]
          e.id = values.fetch('Withdraw_Hash')

          # koinly has no raptoreum price data before this
          if e.date.year == 2021 && e.date.month == 8 && e.date.day == 26 && e.credit.nil? && e.debit.currency.id == :rtm
            e.net_worth = [
              e.debit.to_f * 0.0011052843497268692,
              'EUR'
            ]
          end
        when 'Deposit'
          e.credit = [
            values.fetch('Delta'),
            values.fetch('Currency')
          ]
          e.id = values.fetch('Deposit_Hash')
        when 'Trade'
          trade_id = values.fetch('Trade_Id')
          # other side, this file has no fees
          next if values.fetch('Delta').start_with? '-'

          e.credit = [
            values.fetch('Delta'),
            values.fetch('Currency')
          ]

          matches = csv_paths.map do |csv_path|
            Verokrypto::Helpers.lookup_csv(csv_path, 'Trade_Id', trade_id)
          end.flatten

          matches.each do |match|
            case match.fetch('Type')
            when 'Trade'
              e.debit = [
                match.fetch('Delta').sub('-', ''), # do not gsub, -0.000000107 gives -1.07e-7 but without - 1million
                match.fetch('Currency')
              ]
            else
              pp match
              raise 'wat'
            end
          end

          raise 'credit not set' unless e.credit
          raise 'debit not set' unless e.debit

          e.id = values.fetch('Trade_Id')
        when 'Fee'
          # TODO..
          next
        else
          pp values
          raise 'wat'
        end

        e
      end.compact
      new events
    end
  end
end
