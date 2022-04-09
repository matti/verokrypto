# frozen_string_literal: true

module Verokrypto
  module Helpers
    def self.print_fees(fees)
      fees.each_pair do |currency, amount|
        pp [currency.id, amount]
      end
    end
  end
end
