# frozen_string_literal: true

require 'digest'
module Verokrypto
  class Event
    attr_reader :source, :date, :fee, :debit, :credit, :net_worth
    attr_accessor :id, :original, :label, :description

    def initialize(source)
      @source = source
    end

    def valid!
      return if @id && @date && @fee && @debit && @credit

      warn self
      raise 'not valid'
    end

    def date=(string_or_datetime)
      @date = case string_or_datetime.class.to_s
              when 'String'
                DateTime.parse string_or_datetime
              when 'DateTime'
                string_or_datetime
              else
                raise "unknown #{string_or_datetime.class}"
              end
    end

    def fee=(pair)
      @fee = money_parse(pair)
    end

    def debit=(pair)
      @debit = money_parse(pair)
    end

    def credit=(pair)
      @credit = money_parse(pair)
    end

    def net_worth=(pair)
      @net_worth = money_parse(pair)
    end

    private

    def money_parse(pair)
      amount_string, currency = pair
      Money.from_amount(amount_string.to_f, currency)
    rescue Money::Currency::UnknownCurrency
      ::Money::Currency.register({
                                   priority: 100,
                                   iso_code: currency.upcase,
                                   subunit_to_unit: 100_000_000
                                 })
      retry
    end
  end
end
