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
              values.fetch("Amount (#{currency})").gsub('-', ''),
              currency
            ]
          else
            # other side, the above side has fee deducted
            next
          end
        when 'Hashpower mining'
          # TODO
          e.credit = [
            values.fetch('Amount (BTC)'),
            'BTC'
          ]
          e.label = 'mining'
        when 'Exchange fee', 'Hashpower mining fee', 'Withdrawal complete', 'Withdrawal fee'
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

    # def self.events_to_csv(events)
    #   CSV.generate do |csv|
    #     csv << [
    #       'Date', 'Sent Amount', 'Sent Currency', 'Received Amount', 'Received Currency',
    #       'Fee Amount', 'Fee Currency', 'Net Worth Amount', 'Net Worth Currency', 'Label', 'Description', 'TxHash'
    #     ]

    #     events.each do |event|
    #       csv << [
    #         event.date,
    #         event.debit,
    #         event.debit&.currency&.id,
    #         event.credit,
    #         event.credit&.currency&.id,

    #         event.fee,
    #         event.fee&.currency&.id,

    #         nil, # net worth amount
    #         nil, # net worth currency

    #         nil, # label
    #         nil, # description

    #         event.id
    #       ]
    #     end
    #   end
    # end
  end
end
