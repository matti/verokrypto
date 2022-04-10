# frozen_string_literal: true

module Verokrypto
  class Source
    def fees
      currencies = {}
      events.each do |e|
        currencies[e.fee.currency] ||= Money.from_amount(0, e.fee.currency)
        currencies[e.fee.currency] += e.fee
      end

      currencies
    end

    def balance
      debits = {}
      credits = {}
      events.each do |e|
        debits[e.debit.currency] ||= Money.from_amount(0, e.debit.currency)
        debits[e.debit.currency] += e.debit

        credits[e.credit.currency] ||= Money.from_amount(0, e.credit.currency)
        credits[e.credit.currency] += e.credit
      end
      {
        debits: debits,
        credits: credits
      }
    end
  end
end
