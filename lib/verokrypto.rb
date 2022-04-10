# frozen_string_literal: true

require 'debug'

require 'money'
Money.rounding_mode = BigDecimal::ROUND_HALF_UP
Money.default_currency = 'USD'

Money.default_infinite_precision = true

Money.locale_backend = nil

Money::Currency.register({
                           priority: 100,
                           iso_code: 'USDT',
                           subunit_to_unit: 100_000_000
                         })

require_relative 'verokrypto/helpers'
require_relative 'verokrypto/source'
require_relative 'verokrypto/event'
require_relative 'verokrypto/coinex'
require_relative 'verokrypto/koinly'
require_relative 'verokrypto/coinbase'
require_relative 'verokrypto/southxchange'

module Verokrypto
  class Error < StandardError; end
  # Your code goes here...
end
