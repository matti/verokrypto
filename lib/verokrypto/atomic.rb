# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Atomic < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!
      @events.reverse!
    end

    def self.sanitize_currency(insane_currency)
      case insane_currency
      when 'TRX-USDT'
        'USDT'
      else
        insane_currency
      end
    end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :atomic

        e.id = values.fetch('ORDERID')

        adjusted_date = DateTime.parse(values.fetch('DATE')).to_time.utc.to_datetime
        e.date = adjusted_date

        if values.fetch('INAMOUNT').to_f > 0
          e.credit = [
            values.fetch('INAMOUNT'),
            sanitize_currency(values.fetch('INCURRENCY'))
          ]
        elsif values.fetch('OUTAMOUNT').to_f > 0
          e.debit = [
            values.fetch('OUTAMOUNT'),
            sanitize_currency(values.fetch('OUTCURRENCY'))
          ]
        else
          # fee or some shit like that
          next
        end

        e
      end

      new events
    end
  end
end
