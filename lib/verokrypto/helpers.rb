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

    def self.csv_header(path)
      f = File.open(path)
      f.gets
    ensure
      f.close
    end

    def self.validate_csv_headers(paths)
      headers = paths.map do |path|
        csv_header(path)
      end

      if headers.uniq.size > 1
        warn headers
        raise 'not all headers same'
      end

      headers.first
    end

    def self.lookup_csv(csv_path, column, content)
      fields, *rows = Verokrypto::Helpers.parse_csv(File.open(csv_path))
      rows.map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        values if values.fetch(column) == content
      end.compact
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
