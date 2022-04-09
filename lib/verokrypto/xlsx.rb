# frozen_string_literal: true

require 'rubyXL'

module Verokrypto
  class Xlsx
    def initialize(path)
      @path = path
    end

    def parse
      workbook = RubyXL::Parser.parse(@path)
      fields, *rows = workbook[0].map do |row|
        row.cells.map(&:value)
      end

      [fields, rows]
    end
  end
end
