require 'spec_helper'

describe Premailer::Rails::CSSLoaders::FileSystemLoader do

  before do
    allow(Rails.configuration)
      .to receive(:assets).and_return(double(prefix: '/assets'))
  end

  describe ".file_name" do

    subject do
      Premailer::Rails::CSSLoaders::FileSystemLoader.file_name(asset)
    end

    context "when asset file path contains prefix and relative_url_root is set" do
      before do
        allow(Rails.configuration)
          .to receive(:relative_url_root).and_return('/foo')
      end

      let(:asset) { '/foo/assets/application.css' }
      it { is_expected.to eq('public/assets/application.css') }
    end

    context "when asset file path contains prefix and relative_url_root is NOT set" do
      before do
        allow(Rails.configuration)
          .to receive(:relative_url_root).and_return(nil)
      end

      let(:asset) { '/assets/application.css' }
      it { is_expected.to eq('public/assets/application.css') }
      puts Rails.configuration.class
    end


  end
end
