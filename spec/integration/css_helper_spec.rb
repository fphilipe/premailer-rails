require 'spec_helper'

describe Premailer::Rails::CSSHelper do
  # Reset the CSS cache:
  after do
    Premailer::Rails::CSSLoaders::CacheLoader.clear!
  end

  def css_for_url(path)
    Premailer::Rails::CSSHelper.css_for_url(path)
  end

  def css_for_doc(doc)
    Premailer::Rails::CSSHelper.css_for_doc(doc)
  end

  def expect_file(path, content='file content')
    allow(File).to receive(:exist?).with(path).and_return(true)
    expect(File).to receive(:read).with(path).and_return(content)
  end

  describe '#css_for_doc' do
    let(:html) { Fixtures::HTML.with_css_links(*files) }
    let(:doc) { Nokogiri(html) }

    context 'when HTML contains linked CSS files' do
      let(:files) { %w[ stylesheets/base.css stylesheets/font.css ] }

      it 'returns the content of both files concatenated' do
        allow(Premailer::Rails::CSSHelper).to \
          receive(:css_for_url)
            .with('http://example.com/stylesheets/base.css')
            .and_return('content of base.css')
        allow(Premailer::Rails::CSSHelper).to \
          receive(:css_for_url)
            .with('http://example.com/stylesheets/font.css')
            .and_return('content of font.css')

        expect(css_for_doc(doc)).to eq(
          "content of base.css\ncontent of font.css")
      end
    end

    context 'when HTML contains ignored links' do
      let(:files) { ['ignore.css', 'data-premailer' => 'ignore'] }

      it 'ignores links' do
        expect(Premailer::Rails::CSSHelper).to_not receive(:css_for_url)
        css_for_doc(doc)
      end
    end
  end

  describe '#css_for_url' do
    context 'with file system strategy enabled' do
      before do
        expect(Premailer::Rails).to receive(:config).and_return(
          strategies: [Premailer::Rails::CSSLoaders::FileSystemLoader])
      end

      context 'when path is a url' do
        it 'loads the CSS at the local path' do
          expect_file('public/stylesheets/base.css')

          css_for_url('http://example.com/stylesheets/base.css?test')
        end
      end

      context 'when path is a relative url' do
        it 'loads the CSS at the local path' do
          expect_file('public/stylesheets/base.css')
          css_for_url('/stylesheets/base.css?test')
        end
      end
    end

    context 'with cache strategy enabled' do
      before do
        expect(Premailer::Rails).to receive(:config).and_return(
          strategies: [Premailer::Rails::CSSLoaders::CacheLoader])
      end

      context 'when file is cached' do
        it 'returns the cached value' do
          Premailer::Rails::CSSLoaders::CacheLoader.store(
            'http://example.com/stylesheets/base.css',
            'cached content of base.css'
          )

          expect(css_for_url('http://example.com/stylesheets/base.css')).to \
            eq('cached content of base.css')
        end
      end

      context 'when in development mode' do
        it 'does not return cached values' do
          Premailer::Rails::CSSLoaders::CacheLoader.store(
            'http://example.com/stylesheets/base.css',
            'cached content of base.css'
          )
          allow(Rails.env).to receive(:development?).and_return(true)

          expect do
            css_for_url('http://example.com/stylesheets/base.css')
          end.to raise_error(Premailer::Rails::CSSHelper::FileNotFound)
        end
      end
    end

    context 'whith asset pipeline strategy enabled' do
      before do
        expect(Premailer::Rails).to receive(:config).and_return(
          strategies: [Premailer::Rails::CSSLoaders::AssetPipelineLoader])
        allow(Rails.configuration).to receive(:assets).and_return(double(prefix: '/assets'))
      end

      it 'returns the content of the file compiled by Rails' do
        expect(Rails.application.assets).to \
          receive(:find_asset)
            .with('base.css')
            .and_return(double(to_s: 'content of base.css'))

        expect(css_for_url('http://example.com/assets/base.css')).to \
          eq('content of base.css')
      end

      it 'returns same file when path contains file fingerprint' do
        expect(Rails.application.assets).to \
          receive(:find_asset)
            .with('base.css')
            .and_return(double(to_s: 'content of base.css'))

        expect(css_for_url(
          'http://example.com/assets/base-089e35bd5d84297b8d31ad552e433275.css'
        )).to eq('content of base.css')
      end
    end

    context 'with network strategy enabled' do
      let(:response) { 'content of base.css' }
      let(:path) { '/assets/base-089e35bd5d84297b8d31ad552e433275.css' }
      let(:url) { "http://assets.example.com#{path}" }
      let(:asset_host) { 'http://assets.example.com' }

      before do
        expect(Premailer::Rails).to receive(:config).and_return(
          strategies: [Premailer::Rails::CSSLoaders::NetworkLoader])

        allow(Rails.application.assets).to \
          receive(:find_asset).and_return(nil)

        config = double(asset_host: asset_host)
        allow(Rails.configuration).to \
          receive(:action_controller).and_return(config)

        uri_satisfaction = satisfy { |uri| uri.to_s == url }
        allow(Net::HTTP).to \
          receive(:get).with(uri_satisfaction).and_return(response)
      end

      it 'requests the file' do
        expect(css_for_url(url)).to eq('content of base.css')
      end

      context 'when file url does not include the host' do
        it 'requests the file using the asset host as host' do
          expect(css_for_url(path)).to eq('content of base.css')
        end

        context 'and the asset host uses protocol relative scheme' do
          let(:asset_host) { '//assets.example.com' }

          it 'requests the file using http as the scheme' do
            expect(css_for_url(path)).to eq('content of base.css')
          end
        end
      end
    end

    context 'when static stylesheets are used' do
      it 'returns the content of the static file' do
        content = 'content of base.css'
        expect_file('public/stylesheets/base.css', content)
        loaded_content = css_for_url('http://example.com/stylesheets/base.css')
        expect(loaded_content).to eq(content)
      end
    end

    context 'with all strategies disabled' do
      before do
        expect(Premailer::Rails).to receive(:config).and_return(strategies: [])
      end

      it 'does not load the CSS at the local path' do
        expect do
          css_for_url('http://example.com/stylesheets/base.css?test')
        end.to raise_error(Premailer::Rails::CSSHelper::FileNotFound)
      end
    end
  end
end
