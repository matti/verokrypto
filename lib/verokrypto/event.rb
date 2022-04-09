# frozen_string_literal: true

module Verokrypto
  class Event
    attr_reader :source, :kind, :date, :fee
    attr_accessor :original

    def initialize(source)
      @source = source
    end

    def valid!
      return if @date && @fee

      pp self
      raise 'not valid'
    end

    def date=(utc)
      @date = DateTime.parse utc
    end

    def fee=(string)
      @fee = money_parse(string)
    end

    private

    def money_parse(string)
      amount_string, currency = string.split
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
