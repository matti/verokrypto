# frozen_string_literal: true

require_relative 'process_command'

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
    end
  end
end
