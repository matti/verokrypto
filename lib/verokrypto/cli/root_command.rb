# frozen_string_literal: true

require_relative 'process_command'
require_relative 'csv_command'
require_relative 'stats_command'
require_relative 'hmo_command'

module Verokrypto
  module Cli
    class RootCommand < Clamp::Command
      banner 'verokrypto'

      option ['-v', '--version'], :flag, 'Show version information' do
        puts Gem.loaded_specs.fetch(
          'verokrypto',
          Struct.new(:version).new('dev')
        ).version
        exit
      end

      subcommand ['process'], 'Process', Verokrypto::Cli::ProcessCommand
      subcommand ['csv'], 'CSV', Verokrypto::Cli::CsvCommand
      subcommand ['stats'], 'Stats', Verokrypto::Cli::StatsCommand
      subcommand ['hmo'], 'Hmo', Verokrypto::Cli::HmoCommand
    end
  end
end
