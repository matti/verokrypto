# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Koinly
    def initialize(source)
      @source = source
    end

    def to_csv
      CSV.generate do |csv|
        csv << [
          'Date', 'Sent Amount', 'Sent Currency', 'Received Amount', 'Received Currency',
          'Fee Amount', 'Fee Currency', 'Net Worth Amount', 'Net Worth Currency', 'Label', 'Description', 'TxHash'
        ]

        @source.events.each do |event|
          csv << [
            event.date,
            event.debit,
            event.debit.currency.id,
            event.credit,
            event.credit.currency.id,

            event.fee,
            event.fee.currency.id,

            '',
            '',

            'realized gain',
            'desc',

            event.id
          ]
        end
      end
    end
  end
end
