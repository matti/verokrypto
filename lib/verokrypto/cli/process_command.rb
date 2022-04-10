# frozen_string_literal: true

module Verokrypto
  module Cli
    class ProcessCommand < Clamp::Command
      parameter 'SOURCE_NAME', 'source'
      parameter 'PATH', 'path'

      def execute
        reader = wrap(path)

        source = case source_name
                 when 'coinex'
                   Verokrypto::Coinex.from_xlsx(reader)
                 else
                   raise "Unknown '#{source_name}'"
                 end
        source.sort!

        warn ''
        warn 'fees'
        Verokrypto::Helpers.print_pairs(source.fees)
        warn 'debits'
        Verokrypto::Helpers.print_pairs(source.balance[:debits])
        warn 'credits'
        Verokrypto::Helpers.print_pairs(source.balance[:credits])

        k = Verokrypto::Koinly.new source
        puts k.to_csv
      end

      private

      def wrap(path)
        if path == '-'
          StringIO.new $stdin.read
        else
          File.open path
        end
      end
    end
  end
end
