# frozen_string_literal: true

require 'debug'
require 'rubyXL'
module Verokrypto
  module Helpers
    def self.parse_xlsx(reader)
      workbook = RubyXL::Parser.parse_buffer(reader)
      fields, *rows = workbook[0].map do |row|
        row.cells.map(&:value)
      end

      [fields, rows]
    end

    def self.print_pairs(pairs)
      pairs.each_pair do |currency, amount|
        warn [currency.id, amount.format]
      end
    end
  end
end
