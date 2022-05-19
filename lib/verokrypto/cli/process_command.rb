# frozen_string_literal: true

module Verokrypto
  module Cli
    class ProcessCommand < Clamp::Command
      parameter 'SOURCE_NAME', 'source'
      parameter 'PATH', 'path'
      parameter '[EXTRA] ...', 'extras'

      def execute
        reader = wrap(path)
        # do not self process (e2e southxchange)
        extra_list.reject! do |extra|
          extra == path
        end

        source = case source_name
                 when 'coinex:trades'
                   Verokrypto::Coinex.trades_from_xlsx(reader)
                 when 'coinex:assets'
                   Verokrypto::Coinex.assets_from_xlsx(reader)
                 when 'coinbase'
                   Verokrypto::Coinbase.from_csv(reader)
                 when 'southxchange'
                   Verokrypto::Southxchange.from_csv(reader, extra_list)
                 when 'nicehash'
                   Verokrypto::Nicehash.from_csv(reader)
                 when 'raptoreum'
                   Verokrypto::Raptoreum.from_csv(reader, extra_list)
                 else
                   raise "Unknown '#{source_name}'"
                 end

        source.sort!

        last = nil
        source.events.each do |e|
          if last
            delta = e.date.to_time - last.date.to_time
            e.date_override = (last.date.to_time + 1).to_datetime if delta <= 1
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
