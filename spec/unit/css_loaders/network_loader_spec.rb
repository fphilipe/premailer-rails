require 'spec_helper'

describe Premailer::Rails::CSSLoaders::NetworkLoader do
  describe '#uri_for_url' do
    subject { described_class.uri_for_url(url) }
    let(:asset_host) { nil }

    before do
      action_controller = double(asset_host: asset_host)
      config = double(action_controller: action_controller)
      allow(Rails).to receive(:configuration).and_return(config)
    end

    context 'with a valid URL' do
      let(:url) { 'http://example.com/test.css' }
      it { is_expected.to eq(URI(url)) }
    end

    context 'with a protocol relative URL' do
      let(:url) { '//example.com/test.css' }
      it { is_expected.to eq(URI("http:#{url}")) }
    end

    context 'with a file path' do
      let(:url) { '/assets/foo.css' }

      context 'and a domain as asset host' do
        let(:asset_host) { 'example.com' }
        it { is_expected.to eq(URI("http://example.com#{url}")) }
      end

      context 'and a URL as asset host' do
        let(:asset_host) { 'https://example.com' }
        it { is_expected.to eq(URI("https://example.com/assets/foo.css")) }
      end

      context 'and a protocol relative URL as asset host' do
        let(:asset_host) { '//example.com' }
        it { is_expected.to eq(URI("http://example.com/assets/foo.css")) }
      end

      context 'and a callable object as asset host' do
        let(:asset_host) { double }

        it 'calls #call with the asset path as argument' do
          expect(asset_host).to receive(:call).with(url).and_return(
            'http://example.com')
          expect(subject).to eq(URI('http://example.com/assets/foo.css'))
        end
      end

      context 'without an asset host' do
        let(:asset_host) { nil }
        it { is_expected.not_to be }
      end
    end
  end

  describe '#load' do
    subject { described_class.load(url) }
    let(:url) { 'https://example.com/style.css' }

    context 'when resource exists' do
      it 'returns the body' do
        response = Net::HTTPSuccess.new('1.1', 200, nil)
        allow(response).to receive(:body).and_return('BODY')
        allow(Net::HTTP).to receive(:get_response).and_return(response)

        expect(subject).to eq('BODY')
      end
    end

    context 'when resource is not found' do
      it 'returns the body' do
        response = Net::HTTPNotFound.new('1.1', 404, 'Not Found')
        allow(Net::HTTP).to receive(:get_response).and_return(response)

        expect(subject).to be_nil
      end
    end
  end
end
