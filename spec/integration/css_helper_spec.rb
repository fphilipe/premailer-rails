require 'spec_helper'

describe Premailer::Rails::CSSHelper do
  # Reset the CSS cache:
  after do
    Premailer::Rails::CSSHelper.cache = {}
  end

  def css_for_url(path)
    Premailer::Rails::CSSHelper.css_for_url(path)
  end

  def css_for_doc(doc)
    Premailer::Rails::CSSHelper.css_for_doc(doc)
  end

  def expect_file(path, content='file content')
    path = "#{Rails.root}/#{path}"
    allow(File).to receive(:file?).with(path).and_return(true)
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

        expect(css_for_doc(doc)).to eq("content of base.css\ncontent of font.css")
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
    let(:req) { double("Net::HTTP::Get") }
    let(:response) { double("Net::HTTP::Response", body: 'content of base.css') }

    before do
      allow(Net::HTTP::Get).to receive(:new).and_return(req)
      allow(Net::HTTP).to receive(:start).and_yield(double("request", request: response))
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

    context 'when cache is enabled' do
      before do
        allow(Premailer::Rails::CSSHelper).to receive(:cache_enabled?).and_return(true)
      end

      context 'when file is cached' do
        it 'returns the cached value' do
          Premailer::Rails::CSSHelper.cache['http://example.com/stylesheets/base.css'] = 'content of base.css'

          expect(css_for_url('http://example.com/stylesheets/base.css')).to \
            eq('content of base.css')
        end
      end
    end

    context 'when cache is disabled' do
      before do
        allow(Premailer::Rails::CSSHelper).to receive(:cache_enabled?).and_return(false)
      end

      it 'does not return cached values' do
        Premailer::Rails::CSSHelper.cache['http://example.com/stylesheets/base.css'] = 'cached content'
        content = 'new content of base.css'
        expect_file('public/stylesheets/base.css', content)

        expect(css_for_url('http://example.com/stylesheets/base.css')).to eq(content)
      end
    end

    if defined?(::Sprockets)
      context 'when Rails asset pipeline is used' do
        before do
          allow(Rails.configuration)
            .to receive(:assets).and_return(double(prefix: '/assets'))
          allow(Rails.configuration)
            .to receive(:relative_url_root).and_return(nil)
        end

        context 'and a precompiled file exists' do
          it 'returns that file' do
            path = '/assets/email-digest.css'
            content = 'read from file'
            expect_file("public#{path}", content)
            expect(css_for_url(path)).to eq(content)
          end
        end

        context "when find_sources raises TypeError" do
          let(:uri) { URI('http://example.com/assets/base.css') }

          it "falls back to Net::HTTP" do
            expect(Rails.application.assets_manifest).to \
              receive(:find_sources)
                .with('base.css')
                .and_raise(TypeError)

            expect(Net::HTTP::Get).to receive(:new).with(uri.path, { 'Accept' => 'text/css' }).and_return(req)
            expect(Net::HTTP).to receive(:start).with(uri.host, uri.port, {
              :use_ssl => false,
              :verify_mode => OpenSSL::SSL::VERIFY_PEER
            }).and_yield(double("request", request: response))

            expect(css_for_url('http://example.com/assets/base.css')).to eq('content of base.css')
          end
        end

        context "when find_sources raises Errno::ENOENT" do
          let(:uri) { URI('http://example.com/assets/base.css') }

          it "falls back to Net::HTTP" do
            expect(Rails.application.assets_manifest).to \
              receive(:find_sources)
                .with('base.css')
                .and_raise(Errno::ENOENT)

            expect(css_for_url('http://example.com/assets/base.css')).to \
              eq('content of base.css')
          end
        end

        it 'returns the content of the file compiled by Rails' do
          expect(Rails.application.assets_manifest).to \
            receive(:find_sources)
              .with('base.css')
              .and_return(['content of base.css'])

          expect(css_for_url('http://example.com/assets/base.css')).to \
            eq('content of base.css')
        end

        it 'returns same file when path contains file fingerprint' do
          expect(Rails.application.assets_manifest).to \
            receive(:find_sources)
              .with('base.css')
              .and_return(['content of base.css'])

          expect(css_for_url(
            'http://example.com/assets/base-089e35bd5d84297b8d31ad552e433275.css'
          )).to eq('content of base.css')
        end

        context 'when asset can not be found' do
          let(:path) { '/assets/base-089e35bd5d84297b8d31ad552e433275.css' }
          let(:url) { "http://assets.example.com#{path}" }
          let(:asset_host) { 'http://assets.example.com' }

          before do
            allow(Rails.application.assets_manifest).to \
              receive(:find_sources).and_return([])

            config = double(asset_host: asset_host)
            allow(Rails.configuration).to \
              receive(:action_controller).and_return(config)
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
      end
    elsif defined?(::Propshaft)
      context 'when Propshaft is used' do
        before do
          allow(Rails.configuration)
            .to receive(:assets).and_return(double(prefix: '/assets'))
          allow(Rails.configuration)
            .to receive(:relative_url_root).and_return(nil)
        end

        context 'and a precompiled file exists' do
          it 'returns that file' do
            path = '/assets/email-digest.css'
            content = 'read from file'
            expect_file("public#{path}", content)
            expect(css_for_url(path)).to eq(content)
          end
        end

        it 'returns the content of the file compiled by Propshaft' do
          asset = double()

          expect(Rails.application.assets.load_path).to \
            receive(:find)
              .with('base.css')
              .and_return(asset)

          expect(Rails.application.assets.compilers).to \
            receive(:compile)
              .with(asset)
              .and_return('content of base.css')

          expect(css_for_url('http://example.com/assets/base.css')).to \
            eq('content of base.css')
        end

        it 'returns same file when path contains file fingerprint' do
          asset = double()

          expect(Rails.application.assets.load_path).to \
            receive(:find)
              .with('base.css')
              .and_return(asset)

          expect(Rails.application.assets.compilers).to \
            receive(:compile)
              .with(asset)
              .and_return('content of base.css')

          expect(css_for_url(
            'http://example.com/assets/base-089e35bd5d84297b8d31ad552e433275.css'
          )).to eq('content of base.css')
        end

        context 'when asset can not be found' do
          let(:response) { 'content of base.css' }
          let(:path) { '/assets/base-089e35bd5d84297b8d31ad552e433275.css' }
          let(:url) { "http://assets.example.com#{path}" }
          let(:asset_host) { 'http://assets.example.com' }

          before do
            expect(Rails.application.assets.load_path).to \
              receive(:find)
                .with('base.css')
                .and_return(nil)

            config = double(asset_host: asset_host)
            allow(Rails.configuration).to \
              receive(:action_controller).and_return(config)

            allow(Net::HTTP).to \
              receive(:get)
                .with(URI(url), { 'Accept' => 'text/css' })
                .and_return(response)
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
  end
end
