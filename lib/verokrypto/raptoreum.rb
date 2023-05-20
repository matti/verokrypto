# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Raptoreum < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!; end

    def self.from_csv(reader, received_labels_path, sent_labels_path, prices_path)
      received_labels = YAML.safe_load(File.read(received_labels_path))
      sent_labels = YAML.safe_load(File.read(sent_labels_path))

      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :raptoreum

        e.date = values.fetch('Date')
        e.id = values.fetch('ID')
        e.description = values.fetch('Label')

        case values.fetch('Type')
        when 'Received with'
          label = values.fetch('Label')
          received_label = received_labels.fetch(label)
          e.label = received_label if received_label

          e.credit = [
            values.fetch('Amount (RTM)'),
            'RTM'
          ]
        when 'Sent to'
          label = values.fetch('Label')
          sent_label = sent_labels.fetch(label)
          e.label = sent_label if sent_label

          e.debit = [
            values.fetch('Amount (RTM)').sub('-', ''),
            'RTM'
          ]
        when 'Payment to yourself'
          # fee tx
          e.debit = [
            values.fetch('Amount (RTM)').sub('-', ''),
            'RTM'
          ]
          e.label = 'cost'
          e.id = values.fetch('ID')
        when 'Mined'
          # smartnode reward
          e.credit = [
            values.fetch('Amount (RTM)').sub('-', ''),
            'RTM'
          ]
          e.label = 'reward'
          e.id = values.fetch('ID')
        else
          pp values
          raise 'wat'
        end

        # TODO: copy/pasta in southxchange
        _, *prices_rows = Verokrypto::Helpers.parse_csv(File.open(prices_path))
        prices = prices_rows.to_h do |pair|
          [pair.first, pair.last.to_f]
        end

        # koinly has no raptoreum price data before this
        if e.date < DateTime.new(2021, 9, 21, 17, 0)
          price = prices[e.date.strftime('%Y-%m-%d')]
          raise 'no price' unless price

          e.net_worth = if e.credit
                          [e.credit.to_f * price, 'EUR']
                        else
                          [e.debit.to_f * price, 'EUR']
                        end
        end

        if e.label == 'mining' && e.description == '' && e.credit.to_f > 50_000
          pp values
          pp e
          raise 'too big for mining'
        end

        e
      end

      new events
    end
  end
end
