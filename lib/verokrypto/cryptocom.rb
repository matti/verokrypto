# frozen_string_literal: true

require 'csv'

module Verokrypto
  class Cryptocom < Source
    def initialize(events)
      super()
      @events = events
    end

    def sort!
      @events.reverse!
    end

    def self.from_csv(reader)
      fields, *rows = Verokrypto::Helpers.parse_csv(reader)
      events = rows.filter_map do |row|
        values = Verokrypto::Helpers.valuefy(fields, row)
        e = Verokrypto::Event.new :cryptocom

        e.date = values.fetch('Timestamp (UTC)')

        e.description = values.fetch('Transaction Description')
        e.id = values.fetch('Transaction Hash')

        case values.fetch('Transaction Kind')
        when 'lockup_lock', 'supercharger_deposit', 'lockup_unlock'
          # TODO: CRO stake
          next
        when 'crypto_deposit', 'viban_deposit'
          e.credit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]
        when 'card_top_up'
          e.debit = [
            values.fetch('Amount').sub('-', ''),
            values.fetch('Currency')
          ]
          e.credit = [
            values.fetch('Native Amount'),
            values.fetch('Native Currency')
          ]
        when 'crypto_viban_exchange', 'viban_purchase', 'crypto_exchange'
          e.debit = [
            values.fetch('Amount').sub('-', ''),
            values.fetch('Currency')
          ]
          e.credit = [
            values.fetch('To Amount'),
            values.fetch('To Currency')
          ]
        when 'referral_card_cashback', 'reimbursement'
          e.credit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]
        when 'dust_conversion_credited', 'dust_conversion_debited'
          # TODO
          next
        when 'card_cashback_reverted'
          # TODO
          next
        when 'admin_wallet_credited'
          e.credit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]
        when 'crypto_withdrawal'
          e.debit = [
            values.fetch('Amount').sub('-', ''),
            values.fetch('Currency')
          ]
        when 'crypto_purchase'
          e.debit = [
            values.fetch('Native Amount'),
            values.fetch('Native Currency')
          ]

          e.credit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]
        when 'crypto_wallet_swap_credited'
          e.credit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]
        when 'crypto_wallet_swap_debited'
          e.credit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]
        when 'referral_bonus'
          e.credit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]
        when 'supercharger_reward_to_app_credited'
          e.credit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]
        when 'supercharger_withdrawal'
          e.debit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]

          e.credit = [
            values.fetch('Native Amount'),
            values.fetch('Native Currency')
          ]
        when 'viban_withdrawal'
          e.debit = [
            values.fetch('Amount').sub('-', ''),
            values.fetch('Currency')
          ]
        when 'crypto_viban'
          e.debit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]

          e.credit = [
            values.fetch('To Amount'),
            values.fetch('To Currency')
          ]
        when 'viban_card_top_up'
          e.debit = [
            values.fetch('Amount'),
            values.fetch('Currency')
          ]
        else
          pp values
          raise 'wat'
        end

        e
      end

      new events
    end
  end
end
