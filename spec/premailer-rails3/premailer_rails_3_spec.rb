require 'spec_helper'

describe PremailerRails3 do
  describe '#config' do
    subject { PremailerRails3.config }
    it { should == {} }

    context 'when set' do
      before { PremailerRails3.config = { :foo => :bar } }
      it { should == { :foo => :bar } }
    end
  end
end
