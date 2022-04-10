# frozen_string_literal: true

module Verokrypto
  module Cli
    class CsvCommand < Clamp::Command
      parameter 'PATH ...', 'path'

      def execute
        headers = []
        path_list.each do |path|
          f = File.open(path)
          headers << f.gets
        ensure
          f.close
        end

        if headers.uniq.size > 1
          warn headers
          raise 'not all headers same'
        end

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
