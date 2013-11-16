require 'spec_helper'

describe Premailer::Rails do
  describe '#config' do
    subject { Premailer::Rails.config }
    context 'when set' do
      before { Premailer::Rails.config = { foo: :bar } }
      it { should == { foo: :bar } }
    end
  end
end
