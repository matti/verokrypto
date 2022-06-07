# frozen_string_literal: true

require 'digest'
module Verokrypto
  class Event
    attr_reader :source, :date, :fee, :debit, :credit, :net_worth, :label
    attr_accessor :id, :original, :description

    def initialize(source)
      @source = source
    end

    def valid!
      return if @id && @date && @fee && @debit && @credit

      warn self
      raise 'not valid'
    end

    def ==(other)
      credit == other.credit &&
        date == other.date &&
        debit == other.debit
    end

    def date=(string_or_datetime)
      raise 'date already set' if @date

      self.date_override = string_or_datetime
    end

    def date_override=(string_or_datetime)
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
      raise 'fee already set' if @fee

      @fee = money_parse(pair)
    end

    def fee_remove!
      @fee = nil
    end

    def debit=(pair)
      raise 'debit already set' if @debit

      @debit = money_parse(pair)
    end

    def credit=(pair)
      raise 'credit already set' if @credit

      @credit = money_parse(pair)
    end

    def credit_money=(money)
      @credit = money
    end

    def net_worth=(pair)
      raise 'net_worth already set' if @net_worth

      @net_worth = money_parse(pair)
    end

    def label=(string)
      raise 'label already set' if @label

      @label = case string
               when nil
                 nil
               when 'mining', 'cost', 'reward', 'gift', 'stake', 'unstake'
                 string
               else
                 raise "unknown label: #{string}"
               end
    end

    private

    def money_parse(pair)
      amount_string, currency = pair
      return if amount_string.nil?
      raise 'currency nil' if currency.nil?

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
