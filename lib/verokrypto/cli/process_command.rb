# frozen_string_literal: true

module Verokrypto
  module Cli
    class ProcessCommand < Clamp::Command
      parameter 'SOURCE_NAME', 'source'
      parameter 'PATH', 'path'

      def execute
        source = case source_name
                 when 'coinex'
                   Verokrypto::Coinex.from_xlsx(path)
                 else
                   raise "Unknown '#{source_name}'"
                 end

        Verokrypto::Helpers.print_fees(source.fees)
      end
    end
  end
end
