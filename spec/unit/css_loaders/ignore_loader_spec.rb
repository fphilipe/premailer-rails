require 'spec_helper'

describe Premailer::Rails::CSSLoaders::IgnoreLoader do
  describe '#load' do
    subject { described_class.load('test') }
    it { is_expected.to eq('') }
  end
end
