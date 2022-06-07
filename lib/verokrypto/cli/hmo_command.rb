# frozen_string_literal: true

module Verokrypto
  module Cli
    class HmoCommand < Clamp::Command
      parameter 'MERGED_PATH', 'merged'
      parameter 'HMO_PATH', 'hmo'

      def execute
        koinly_events = Verokrypto::Koinly.from_csv(File.new(merged_path))
        koinly_hmo = Verokrypto::Koinly.from_csv(File.new(hmo_path))

        adjusted_events = koinly_events.events.filter_map do |event|
          adjusted_net_worth = nil
          koinly_hmo.events.each do |hmo_event|
            next unless event == hmo_event

            worth, cost_basis = hmo_event.description.split
            adjusted_net_worth = worth.to_f - (worth.to_f * 0.20) + cost_basis.to_f
            break
          end

          if adjusted_net_worth
            event.net_worth = [
              adjusted_net_worth,
              'eur'
            ]
            event.fee_remove!
          end

          event
        end

        puts Verokrypto::Koinly.to_csv(adjusted_events)
      end
    end
  end
end
