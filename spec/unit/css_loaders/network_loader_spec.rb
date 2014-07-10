require 'spec_helper'

describe Premailer::Rails::CSSLoaders::NetworkLoader do
  before do
    assets = double(prefix: '/assets')
    action_controller = double(asset_host: 'http://assets.example.com')
    config = double(assets: assets, action_controller: action_controller)
    allow(Rails).to receive(:configuration).and_return(config)
  end

  describe ".uri_for_url" do
    subject do
      Premailer::Rails::CSSLoaders::NetworkLoader.uri_for_url(url)
    end

    context "for a schema-less url, responds_to method used internally" do
      let(:url) { '//assets.example.com/assets/application.css' }
      it { is_expected.to respond_to(:request_uri) }
    end

  end
end
