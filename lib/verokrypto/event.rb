# frozen_string_literal: true

require 'digest'
module Verokrypto
  class Event
    attr_reader :id, :source, :date, :fee, :debit, :credit
    attr_accessor :original

    def initialize(source)
      @source = source
    end

    def valid!
      return if @id && @date && @fee && @debit && @credit

      warn self
      raise 'not valid'
    end

    def id=(obj)
      @id = Digest::MD5.hexdigest obj.to_s
    end

    def date=(utc)
      @date = DateTime.parse utc
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
