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
  end
end
