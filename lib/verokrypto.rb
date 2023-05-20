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
require_relative 'verokrypto/nicehash'
require_relative 'verokrypto/raptoreum'
require_relative 'verokrypto/inodez'
require_relative 'verokrypto/cryptocom'
require_relative 'verokrypto/tradeogre'
require_relative 'verokrypto/kucoin'
require_relative 'verokrypto/atomic'

module Verokrypto
  class Error < StandardError; end
  # Your code goes here...
end
