require 'spec_helper'

describe PremailerRails.config do
  subject { PremailerRails.config }

  it { should be_a Hash }

  context 'when set' do
    before do
      @old_config = PremailerRails.config
      PremailerRails.config = { :foo => :bar }
    end

    after do
      PremailerRails.config = @old_config
    end

    it { should == { :foo => :bar } }
  end

  describe ':generate_text_part' do
    subject { PremailerRails.config[:generate_text_part] }

    context 'by default' do
      it { should be_true }
    end
  end
end
