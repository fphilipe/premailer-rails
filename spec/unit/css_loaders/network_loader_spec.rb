require 'spec_helper'

describe Premailer::Rails::CSSLoaders::NetworkLoader do
  describe '#uri_for_url' do
    let(:path){ '/assets/foo.css' }
    subject{ described_class.uri_for_url(path) }

    context 'with an asset host' do
      let(:host){ 'example.com' }
      let(:config){ double(action_controller: double(asset_host: host)) }

      before{ allow(Rails).to receive(:configuration).and_return(config) }

      it 'creates a URI with the asset host' do
        expect(subject.host).to eq(host)
      end

      it 'creates a URI with the proper scheme' do
        expect(subject.scheme).to eq('http')
      end

      it 'infers the scheme from the asset host if present' do
        allow(config.action_controller).to receive(:asset_host){ "https://#{host}" }
        expect(subject.host).to eq(host)
        expect(subject.scheme).to eq('https')
      end

      it 'creates a URI with the proper request uri' do
        expect(subject.request_uri).to eq(path)
      end
    end

    context 'without an asset host' do
      let(:config){ double(action_controller: double(asset_host: nil)) }

      before{ allow(Rails).to receive(:configuration).and_return(config) }

      it{ is_expected.to be(nil) }
    end

    context 'already valid URL' do
      let(:path){ 'http://example2.com/image.jpg' }

      it 'creates a URI with the proper host' do
        expect(subject.host).to eq('example2.com')
      end

      it 'creates a URI with the proper scheme' do
        expect(subject.scheme).to eq('http')
      end

      it 'creates a URI with the proper request uri' do
        expect(subject.request_uri).to eq('/image.jpg')
      end
    end
  end
end
