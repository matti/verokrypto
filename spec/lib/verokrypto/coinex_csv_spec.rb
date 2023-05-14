# frozen_string_literal: true

RSpec.describe Verokrypto::CoinexCsv do
  let(:reader) { File.open(csv_path) }

  describe 'deposit' do
    let(:csv_path) { 'spec/data/coinex/deposit.csv' }
    let(:deposit1) do
      Verokrypto::Event.new(
        :coinex_deposit,
        date: '2021-11-25 09:48:33',
        credit: %w[+4028.12000001 RTM]
      )
    end
    let(:deposit2) do
      Verokrypto::Event.new(
        :coinex_deposit,
        date: '2021-10-24 09:40:30',
        credit: %w[+1000.00000010 RTM]
      )
    end
    let(:deposit3) do
      Verokrypto::Event.new(
        :coinex_deposit,
        date: '2021-09-23 10:20:30',
        credit: %w[+2001.99999999 RTM]
      )
    end
    let(:deposits) { [deposit1, deposit2, deposit3] }

    it 'finds deposits' do
      expect(described_class.parse_transactions(reader).events).to eq deposits
    end
  end

  describe 'withdrawal' do
    let(:csv_path) { 'spec/data/coinex/withdrawal.csv' }

    let(:withdrawal1) do
      Verokrypto::Event.new(
        :coinex_withdrawal,
        date: '2021-11-30 11:48:56',
        debit: %w[-4250.29263412 RTM]
      )
    end
    let(:withdrawal2) do
      Verokrypto::Event.new(
        :coinex_withdrawal,
        date: '2021-10-29 12:01:02',
        debit: %w[-1234.12345678 RTM]
      )
    end
    let(:withdrawal3) do
      Verokrypto::Event.new(
        :coinex_withdrawal,
        date: '2021-10-29 12:01:01',
        debit: %w[-5432.00000001 RTM]
      )
    end
    let(:withdrawals) { [withdrawal1, withdrawal2, withdrawal3] }

    it 'finds withdrawals' do
      expect(described_class.parse_transactions(reader).events).to eq withdrawals
    end
  end

  describe 'trade' do
    let(:csv_path) { 'spec/data/coinex/trade.csv' }
    let(:trade1) do
      Verokrypto::Event.new(
        :coinex_trade,
        date: '2021-12-31 20:04:28',
        credit: %w[+63.21915579 USDT],
        debit: %w[-3067.40202776 RTM],
        fee: %w[-0.18965747 USDT]
      )
    end
    let(:trade2) do
      Verokrypto::Event.new(
        :coinex_trade,
        date: '2021-12-30 12:30:10',
        credit: %w[+10.9999999 USDT],
        debit: %w[-4567.0000001 RTM],
        fee: %w[-0.123456 USDT]
      )
    end
    let(:trade3) do
      Verokrypto::Event.new(
        :coinex_trade,
        date: '2021-10-30 11:30:11',
        credit: %w[+20.0999999 USDT],
        debit: %w[-3567.00000010 RTM],
        fee: %w[-0.654321 USDT]
      )
    end
    let(:trades) { [trade1, trade2, trade3] }

    it 'finds trades' do
      expect(described_class.parse_transactions(reader).events).to eq trades
    end
  end

  describe 'combined' do
    let(:csv_path) { 'spec/data/coinex/combined.csv' }
    let(:trade1) do
      Verokrypto::Event.new(
        :coinex_trade,
        date: '2021-12-19 19:08:18',
        fee: %w[-0.03276364 USDT],
        credit: %w[+10.92121344 USDT],
        debit: %w[-391.68000000 RTM]
      )
    end
    let(:trade2) do
      Verokrypto::Event.new(
        :coinex_trade,
        date: '2021-12-19 19:08:18',
        fee: %w[-0.00425082 USDT],
        credit: %w[+1.41694000 USDT],
        debit: %w[-50.75000000 RTM]
      )
    end
    let(:deposit1) do
      Verokrypto::Event.new(
        :coinex_deposit,
        date: '2021-12-19 18:51:40',
        credit: %w[+59.43000000 RTM]
      )
    end
    let(:deposit2) do
      Verokrypto::Event.new(
        :coinex_deposit,
        date: '2021-12-19 18:51:40',
        credit: %w[+383.00000000 RTM]
      )
    end
    let(:trade3) do
      Verokrypto::Event.new(
        :coinex_trade,
        date: '2021-12-15 10:12:03',
        fee: %w[-0.02837160 USDT],
        credit: %w[+9.45720000 USDT],
        debit: %w[-333.00000000 RTM]
      )
    end
    let(:deposit3) do
      Verokrypto::Event.new(
        :coinex_deposit,
        date: '2021-12-15 10:08:36',
        credit: %w[+314.00000000 RTM]
      )
    end
    let(:deposit4) do
      Verokrypto::Event.new(
        :coinex_deposit,
        date: '2021-12-15 10:08:36',
        credit: %w[+19.00000000 RTM]
      )
    end
    let(:withdrawal1) do
      Verokrypto::Event.new(
        :coinex_withdrawal,
        date: '2021-12-13 23:11:28',
        debit: %w[-64160.30793772 USDT]
      )
    end
    let(:withdrawal2) do
      Verokrypto::Event.new(
        :coinex_withdrawal,
        date: '2021-12-13 22:48:29',
        debit: %w[-10001.10000000 USDT]
      )
    end
    let(:trade4) do
      Verokrypto::Event.new(
        :coinex_trade,
        date: '2021-12-13 22:28:05',
        fee: %w[-14.06078794 USDT],
        credit: %w[+7030.39397220 USDT],
        debit: %w[-0.15065668 BTC]
      )
    end
    let(:expected_events) do
      [
        trade1, trade2,
        deposit1, deposit2,
        trade3, deposit3,
        deposit4, withdrawal1,
        withdrawal2, trade4
      ]
    end
    it 'parses combined transactions' do
      events = described_class.parse_transactions(reader).events

      events.each_with_index do |e, i|
        expect(e).to eq(expected_events[i])
      end

      expect(events).to eq(expected_events)
    end
  end
end
