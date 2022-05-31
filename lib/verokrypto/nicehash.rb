# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Nicehash < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!; end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :nicehash

        # crap at the end
        next unless values['Date time']
        next if values['Date time'] == '∑'

        e.date = values.fetch 'Date time'
        e.description = values.fetch('Purpose')

        case values.fetch('Purpose')
        when 'Exchange trade'
          currency, manual_currency = if values['Amount (ETH)']
                                        %w[ETH BTC]
                                      elsif values['Amount (BTC)']
                                        %w[BTC ETH]
                                      else
                                        raise 'wat'
                                      end

          if values.fetch("Amount (#{currency})").start_with? '-'
            e.credit = [
              values.fetch('Manual'),
              manual_currency
            ]

            e.debit = [
              values.fetch("Amount (#{currency})").sub('-', ''),
              currency
            ]
          else
            # other side, the above side has fee deducted
            next
          end
        when 'Hashpower mining'
          e.credit = [
            values.fetch('Amount (BTC)'),
            'BTC'
          ]
          e.label = 'mining'
        when 'Withdrawal complete'
          e.debit = [
            values.fetch('Amount (BTC)').sub('-', ''),
            'BTC'
          ]
        when 'Exchange fee', 'Hashpower mining fee', 'Withdrawal fee'
          # TODO
          next
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
