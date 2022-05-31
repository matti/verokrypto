# frozen_string_literal: true

module Verokrypto
  module Cli
    class CsvCommand < Clamp::Command
      parameter 'PATH ...', 'path'

      def execute
        Verokrypto::Helpers.validate_csv_headers path_list

        events = path_list.map do |path|
          Verokrypto::Koinly.from_csv(File.new(path)).events
        end.flatten

        events.sort! { |a, b| a.date <=> b.date }

        puts Verokrypto::Koinly.to_csv(events)
      end
    end
  end
end
