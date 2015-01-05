require 'spec_helper'

describe Premailer::Rails::CSSLoaders::AssetPipelineLoader do
  before do
    assets = double(prefix: '/assets')
    config = double(assets: assets)
    allow(Rails).to receive(:configuration).and_return(config)
  end

  describe ".file_name" do
    subject do
      Premailer::Rails::CSSLoaders::AssetPipelineLoader.file_name(asset)
    end

    context "when asset file path contains prefix" do
      let(:asset) { '/assets/application.css' }
      it { is_expected.to eq('application.css') }
    end

    context "when asset file path contains fingerprint" do
      let(:asset) { 'application-6776f581a4329e299531e1d52aa59832.css' }
      it { is_expected.to eq('application.css') }
    end

    context "when asset file page contains numbers, but not a fingerprint" do
      let(:asset) { 'test/20130708152545-foo-bar.css' }
      it { is_expected.to eq("test/20130708152545-foo-bar.css") }
    end

    context "when asset file page contains RAILS_RELATIVE_URL_ROOT" do
      before do
         ENV['RAILS_RELATIVE_URL_ROOT'] = '/development'
      end
      let(:asset) { "#{ENV['RAILS_RELATIVE_URL_ROOT']}foo-bar.css" }
      it { should == "foo-bar.css" }
    end
  end
end
