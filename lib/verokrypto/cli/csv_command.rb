# frozen_string_literal: true

module Verokrypto
  module Cli
    class CsvCommand < Clamp::Command
      parameter 'PATH ...', 'path'

      def execute
        Verokrypto::Helpers.validate_csv_headers path_list

        events = path_list.map do |path|
          Verokrypto::Koinly.events_from_csv File.new path
        end.flatten

        # unless events.size == events.map(&:id).uniq.size
        #   pp [:events, events.size, :vs, :uniq, events.map(&:id).uniq.size]
        #   raise 'not all uniq'
        # end

        events.sort! { |a, b| a.date <=> b.date }

        puts Verokrypto::Koinly.events_to_csv(events)
      end
    end
  end
end
