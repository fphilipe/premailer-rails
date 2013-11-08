require 'spec_helper'

describe Premailer::Rails::CSSLoaders::AssetPipelineLoader do
  before { Rails.stubs(:configuration).returns stub(assets: stub(prefix: '/assets')) }

  describe ".file_name" do
    subject { Premailer::Rails::CSSLoaders::AssetPipelineLoader.file_name asset }

    context "when asset file path contains prefix" do
      let(:asset) { '/assets/application.css' }
      it { should == 'application.css' }
    end

    context "when asset file path contains fingerprint" do
      let(:asset) { 'application-6776f581a4329e299531e1d52aa59832.css' }
      it { should == 'application.css' }
    end

    context "when asset file page contains numbers, but not a fingerprint" do
      let(:asset) { 'test/20130708152545-foo-bar.css' }
      it { should == "test/20130708152545-foo-bar.css" }
    end
  end
end