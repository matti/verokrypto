# frozen_string_literal: true

module Verokrypto
  class Source
    attr_reader :events
    attr_accessor :name

    def fees
      currencies = {}
      events.each do |e|
        currencies[e.fee.currency] ||= Money.from_amount(0, e.fee.currency)
        currencies[e.fee.currency] += e.fee
      end

      currencies
    end

    def debits
      currencies = {}
      events.each do |e|
        next unless e.debit

        currencies[e.debit.currency] ||= Money.from_amount(0, e.debit.currency)
        currencies[e.debit.currency] += e.debit
      end
      currencies
    end

    def credits
      currencies = {}
      events.each do |e|
        next unless e.credit

        currencies[e.credit.currency] ||= Money.from_amount(0, e.credit.currency)
        currencies[e.credit.currency] += e.credit
      end
      currencies
    end

    def balance
      {
        debits: debits,
        credits: credits
      }
    end
  end
end
