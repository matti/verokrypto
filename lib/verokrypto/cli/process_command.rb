# frozen_string_literal: true

module Verokrypto
  module Cli
    class ProcessCommand < Clamp::Command
      parameter 'SOURCE_NAME', 'source'
      parameter 'PATH', 'path'

      def execute
        reader = wrap(path)

        source = case source_name
                 when 'coinex:trades'
                   Verokrypto::Coinex.trades_from_xlsx(reader)
                 when 'coinex:assets'
                   Verokrypto::Coinex.assets_from_xlsx(reader)
                 when 'coinbase'
                   Verokrypto::Coinbase.from_csv(reader)
                 when 'southxchange'
                   Verokrypto::Southxchange.from_csv(reader)
                 when 'nicehash'
                   Verokrypto::Nicehash.from_csv(reader)
                 else
                   raise "Unknown '#{source_name}'"
                 end

        source.sort!

        last = nil
        source.events.each do |e|
          if last
            delta = e.date.to_time - last.date.to_time
            e.date = (last.date.to_time + 1).to_datetime if delta <= 1
          end

          last = e
        end

        case source_name
        when 'coinex:trades'
          warn ''
          warn 'fees'
          Verokrypto::Helpers.print_pairs(source.fees)
          warn ''
          warn 'debits'
          Verokrypto::Helpers.print_pairs(source.balance[:debits])
          warn ''
          warn 'credits'
          Verokrypto::Helpers.print_pairs(source.balance[:credits])
        when 'coinex:assets'
          warn ''
          warn 'deposits'
          Verokrypto::Helpers.print_pairs(source.credits)
          warn ''
          warn 'withdraws'
          Verokrypto::Helpers.print_pairs(source.debits)
        end

        puts Verokrypto::Koinly.events_to_csv(source.events)
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
