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

        three_hours_later = DateTime.parse(values.fetch('DATE')) + (3 * 1 / 24r)
        e.date = three_hours_later

        case values.fetch('TYPE')
        when '-'
          e.credit = case values.fetch('OUTAMOUNT')
                     when '-'
                       [
                         values.fetch('INAMOUNT'),
                         sanitize_currency(values.fetch('INCURRENCY'))
                       ]
                     else
                       [
                         values.fetch('OUTAMOUNT'),
                         sanitize_currency(values.fetch('OUTCURRENCY'))
                       ]
                     end
        when 'regular'
          case values.fetch('OUTAMOUNT')
          when '-'
            e.credit = [
              values.fetch('INAMOUNT'),
              sanitize_currency(values.fetch('INCURRENCY'))
            ]
          else
            e.debit = [
              values.fetch('OUTAMOUNT'),
              sanitize_currency(values.fetch('OUTCURRENCY'))
            ]
          end
        when 'Transfer'
          case values.fetch('OUTAMOUNT')
          when '-'
            e.credit = [
              values.fetch('INAMOUNT'),
              sanitize_currency(values.fetch('INCURRENCY'))
            ]
          else
            e.debit = [
              values.fetch('OUTAMOUNT'),
              sanitize_currency(values.fetch('OUTCURRENCY'))
            ]
          end
        else
          raise 'WAT'
        end

        e
      end

      new events
    end
  end
end
