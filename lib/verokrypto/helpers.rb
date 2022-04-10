# frozen_string_literal: true

require 'debug'
require 'rubyXL'
require 'csv'
module Verokrypto
  module Helpers
    def self.parse_xlsx(reader)
      workbook = RubyXL::Parser.parse_buffer(reader)
      fields, *rows = workbook[0].map do |row|
        row.cells.map(&:value)
      end

      [fields, rows]
    end

    def self.parse_csv(reader)
      CSV.read(reader)
    end

    def self.print_pairs(pairs)
      pairs.each_pair do |currency, amount|
        warn "#{currency.id}\t#{amount}"
      end
    end

    def self.valuefy(fields, row)
      hash = {}
      fields.each do |field|
        hash[field] = row.shift
      end
      hash
    end
  end
end
