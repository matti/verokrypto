# frozen_string_literal: true

RSpec.describe Verokrypto::CoinexCsv do
  let(:reader) { File.open(csv_path) }

  describe '#deposits' do
    let(:csv_path) { 'spec/data/coinex/deposit.csv' }
    let(:deposit_event) do
      Verokrypto::Event.new(
        :coinex_deposit,
        date: '2021-11-25 09:48:33',
        credit: %w[+4028.12000001 RTM]
      )
    end
    let(:deposits) { [deposit_event] }

    it 'finds deposits' do
      expect(described_class.deposits(reader).events).to eq deposits
    end
  end

  describe '#withdrawals' do
    let(:csv_path) { 'spec/data/coinex/withdrawal.csv' }

    let(:withdrawal_event) do
      Verokrypto::Event.new(
        :coinex_withdrawal,
        date: '2021-11-30 11:48:56',
        debit: %w[-4250.29263412 RTM]
      )
    end
    let(:withdrawals) { [withdrawal_event] }

    it 'finds withdrawals' do
      expect(described_class.withdrawals(reader).events).to eq withdrawals
    end
  end

  describe '#trades' do
    let(:csv_path) { 'spec/data/coinex/trade.csv' }
    let(:trade_event) do
      Verokrypto::Event.new(
        :coinex_trade,
        date: '2021-12-31 20:04:28',
        debit: %w[-4250.29263412 RTM],
        credit: %w[+63.21915579 USDT],
        fee: %w[-0.18965747 USDT]
      )
    end
    let(:trades) { [trade_event] }

    it 'finds trades' do
      expect(described_class.trades(reader).events).to eq trades
    end
  end
end
