require 'spec_helper'

describe Premailer::Rails::CSSHelper do
  # Reset the CSS cache:
  after do
    Premailer::Rails::CSSHelper.reset_cache!
  end

  def load_css(path)
    Premailer::Rails::CSSHelper.send(:load_css, path)
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
          receive(:load_css)
            .with('http://example.com/stylesheets/base.css')
            .and_return('content of base.css')
        allow(Premailer::Rails::CSSHelper).to \
          receive(:load_css)
            .with('http://example.com/stylesheets/font.css')
            .and_return('content of font.css')

        expect(css_for_doc(doc)).to eq("content of base.css\ncontent of font.css")
      end
    end
  end

  describe '#load_css' do
    context 'when path is a url' do
      it 'loads the CSS at the local path' do
        expect_file('public/stylesheets/base.css')

        load_css('http://example.com/stylesheets/base.css?test')
      end
    end

    context 'when path is a relative url' do
      it 'loads the CSS at the local path' do
        expect_file('public/stylesheets/base.css')
        load_css('/stylesheets/base.css?test')
      end
    end

    context 'when file is cached' do
      it 'returns the cached value' do
        cache = Premailer::Rails::CSSHelper.cache
        cache['http://example.com/stylesheets/base.css'] = 'content of base.css'

        expect(load_css('http://example.com/stylesheets/base.css')).to \
          eq('content of base.css')
      end
    end

    context 'when in development mode' do
      it 'does not return cached values' do
        cache = Premailer::Rails::CSSHelper.cache
        cache['http://example.com/stylesheets/base.css'] =
          'cached content of base.css'
        content = 'new content of base.css'
        expect_file('public/stylesheets/base.css', content)
        allow(Rails.env).to receive(:development?).and_return(true)

        expect(load_css('http://example.com/stylesheets/base.css')).to eq(content)
      end
    end

    context 'when Rails asset pipeline is used' do
      before do
        allow(Rails.configuration).to receive(:assets).and_return(double(prefix: '/assets'))
      end

      context 'and a precompiled file exists' do
        it 'returns that file' do
          path = '/assets/email-digest.css'
          content = 'read from file'
          expect_file("public#{path}", content)
          expect(load_css(path)).to eq(content)
        end
      end

      it 'returns the content of the file compiled by Rails' do
        expect(Rails.application.assets).to \
          receive(:find_asset)
            .with('base.css')
            .and_return(double(to_s: 'content of base.css'))

        expect(load_css('http://example.com/assets/base.css')).to \
          eq('content of base.css')
      end

      it 'returns same file when path contains file fingerprint' do
        expect(Rails.application.assets).to \
          receive(:find_asset)
            .with('base.css')
            .and_return(double(to_s: 'content of base.css'))

        expect(load_css(
          'http://example.com/assets/base-089e35bd5d84297b8d31ad552e433275.css'
        )).to eq('content of base.css')
      end

      context 'when asset can not be found' do
        let(:response) { 'content of base.css' }
        let(:path) { '/assets/base-089e35bd5d84297b8d31ad552e433275.css' }
        let(:url) { "http://assets.example.com#{path}" }
        let(:asset_host) { 'http://assets.example.com' }

        before do
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
          expect(load_css(url)).to eq('content of base.css')
        end

        context 'when file url does not include the host' do
          it 'requests the file using the asset host as host' do
            expect(load_css(path)).to eq('content of base.css')
          end

          context 'and the asset host uses protocol relative scheme' do
            let(:asset_host) { '//assets.example.com' }

            it 'requests the file using http as the scheme' do
              expect(load_css(path)).to eq('content of base.css')
            end
          end
        end
     end
    end

    context 'when static stylesheets are used' do
      it 'returns the content of the static file' do
        content = 'content of base.css'
        expect_file('public/stylesheets/base.css', content)
        loaded_content = load_css('http://example.com/stylesheets/base.css')
        expect(loaded_content).to eq(content)
      end
    end
  end
end
