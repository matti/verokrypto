# frozen_string_literal: true

module Verokrypto
  module Cli
    class StatsCommand < Clamp::Command
      parameter 'PATH ...', 'path'

      def take(from, event)
        # if event.debit.currency.id == :eur
        #   autofill_event = Event.new :autofill
        #   autofill_event.credit = [
        #     event.debit.amount.to_f,
        #     event.debit.currency.to_s
        #   ]

        #   from.push autofill_event
        # end

        pp [:f, from]
        pp [:available,
            from.map(&:credit).map(&:to_f).sum, from.first.credit.currency.id,
            event.debit.to_f, event.debit.currency.id]

        after = []
        remaining = event.debit

        from.each do |lot|
          # TODO: can this be negative like [2,3] take 5 first iteration: -3
          # p [:lot, lot.credit.to_f]
          lot_left = lot.credit - remaining

          if lot_left.positive?
            lot.credit_money = lot_left
            remaining -= remaining
            after.push lot
          elsif remaining.zero?
            remaining -= remaining
          else
            remaining -= lot.credit
          end
          # pp [:remaining, remaining.to_f]
        end
        if remaining.positive?
          pp [:credit_did_not_cover, remaining.to_f, remaining.currency.id]
          pp event
          raise 'err'
        end
        # pp [:after, after]

        after
      end

      def execute
        Verokrypto::Helpers.validate_csv_headers path_list

        events = path_list.map do |path|
          Verokrypto::Koinly.from_csv File.new path
        end.flatten

        pp [:events, events.size]

        last = nil
        events.each do |current|
          if last && (last.date > current.date)
            pp [:last, last]
            pp [:current, current]
            pp [:err, last.date, :gt, current.date]
            exit 1
          end
          last = current
        end

        fifo = {}
        events.each do |e|
          fifo[e.debit.currency.id] ||= [] if e.debit
          fifo[e.credit.currency.id] ||= [] if e.credit

          if e.debit && e.credit
            pp [:trade, :pre,
                e.date,
                e.debit.to_f, e.debit.currency.id,
                e.credit.to_f, e.credit.currency.id,
                e.description,
                fifo[e.credit.currency.id].map(&:credit).map(&:to_f).sum]

            fifo[e.debit.currency.id] = take fifo[e.debit.currency.id], e
            fifo[e.credit.currency.id].push e

            pp [:trade, :post,
                e.date,
                e.debit.to_f, e.debit.currency.id,
                e.credit.to_f, e.credit.currency.id,
                e.description,
                fifo[e.credit.currency.id].map(&:credit).map(&:to_f).sum]
          elsif e.debit && e.credit.nil?
            pp [:withdraw,
                e.date,
                e.debit.to_f, e.debit.currency.id,
                e.label, e.description,
                fifo[e.debit.currency.id].map(&:credit).map(&:to_f).sum]
            fifo[e.debit.currency.id] = take fifo[e.debit.currency.id], e
          else
            fifo[e.credit.currency.id].push e

            pp [
              :deposit,
              e.date,
              e.credit.to_f, e.credit.currency.id,
              e.label, e.description,
              fifo[e.credit.currency.id].map(&:credit).map(&:to_f).sum
            ]
          end
        end

        puts ''
        puts '-' * 80
        fifo.each_pair do |currency_id, credit_events|
          pp [currency_id, credit_events.map(&:credit).map(&:to_f).sum, credit_events.map(&:debit).map(&:to_f).sum]
        end
        # events.each do |e|
        #   if e.debit
        #     debits[e.debit.currency.id] ||= Money.from_amount(0, e.debit.currency)
        #     debits[e.debit.currency.id] += e.debit
        #   end
        #   if e.credit
        #     credits[e.credit.currency.id] ||= Money.from_amount(0, e.credit.currency)
        #     credits[e.credit.currency.id] += e.credit
        #   end
        # end

        # debits.each_pair do |currency_id, money|
        #   balance = (credits[currency_id] - debits[currency_id]).to_f
        #   pp [:debit, currency_id, money.amount.to_f, balance]
        # end
        # credits.each_pair do |currency_id, money|
        #   pp [:credit, currency_id, money.amount.to_f]
        # end

        # pp [:debits, debits]
        # pp [:credits, debits]

        # def self.print_pairs(pairs)
        #   pairs.each_pair do |currency, amount|
        #     warn "#{currency.id}\t#{amount}"
        #   end
        # end
      end
    end
  end
end
