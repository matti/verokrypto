# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Inodez < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!; end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :inodez

        e.date = values.fetch('Date')

        case values.fetch('Description')
        when 'inodez-onboard'
          e.credit = [
            values.fetch('Sent Amount'),
            values.fetch('Sent Currency')
          ]
        when 'inodez-back'
          e.debit = [
            values.fetch('Received Amount'),
            values.fetch('Received Currency')
          ]
        else
          next
        end
        e
      end

      new events
    end
  end
end
