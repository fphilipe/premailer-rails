require 'spec_helper'

if defined?(::Propshaft)
  describe Premailer::Rails::CSSLoaders::PropshaftLoader do
    before do
      allow(Rails.application)
        .to receive(:assets).and_return(double(prefix: '/assets'))
      allow(Rails.configuration).to receive(:relative_url_root).and_return(nil)
    end

    describe ".file_name" do
      subject do
        described_class.file_name(asset)
      end

      context "when asset file path contains prefix" do
        let(:asset) { '/assets/application.css' }
        it { is_expected.to eq('application.css') }
      end

      context "when asset file path contains prefix and relative_url_root is set" do
        before do
          allow(Rails.configuration)
            .to receive(:relative_url_root).and_return('/foo')
        end

        let(:asset) { '/foo/assets/application.css' }
        it { is_expected.to eq('application.css') }
      end

      context "when asset file path contains prefix and relative_url_root is set to root" do
        before do
          allow(Rails.configuration)
            .to receive(:relative_url_root).and_return('/')
        end

        let(:asset) { '/assets/application.css' }
        it { is_expected.to eq('application.css') }
      end

      context "when asset file path contains 7 chars fingerprint" do
        let(:asset) { 'application-1234567.css' }
        it { is_expected.to eq('application.css') }
      end

      context "when asset file path contains 128 chars fingerprint" do
        let(:asset) { 'application-02275ccb3fd0c11615bbfb11c99ea123ca2287e75045fe7b72cefafb880dad2b.css' }
        it { is_expected.to eq('application.css') }
      end

      context "when asset file page contains numbers, but not a fingerprint" do
        let(:asset) { 'test/20130708152545-foo-bar.css' }
        it { is_expected.to eq("test/20130708152545-foo-bar.css") }
      end
    end
  end
end
