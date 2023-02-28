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
          event_hmo = nil
          koinly_hmo.events.each do |hmo_event|
            next unless event == hmo_event

            event_hmo = hmo_event
            break
          end

          if event_hmo
            worth, cost_basis = event_hmo.description.split

            event_sell = Verokrypto::Event.new :hmo
            event_buy = Verokrypto::Event.new :hmo

            event_sell.date = event.date
            event_buy.date = (event_sell.date.to_time + 1).to_datetime

            event_sell.debit_money = event.debit
            event_sell.credit = [
              # worth.to_f - (worth.to_f * 0.20) + cost_basis.to_f,
              # Right approach would need to set cost_basis := 0.80 * worth
              # but it's not possible to define cost_basis in Koinly :/
              cost_basis.to_f * 1.20,
              :eur
            ]
            event_buy.debit = [
              worth.to_f,
              :eur
            ]
            event_buy.credit_money = event.credit

            [event_sell, event_buy]
          else
            [event]
          end
        end.flatten

        puts Verokrypto::Koinly.to_csv(adjusted_events)
      end
    end
  end
end
