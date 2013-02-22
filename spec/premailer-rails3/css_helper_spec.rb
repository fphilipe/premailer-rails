require 'spec_helper'

describe PremailerRails::CSSHelper do
  # Reset the CSS cache
  after { PremailerRails::CSSHelper.send(:instance_variable_set, '@cache', {}) }

  def load_css(path)
    PremailerRails::CSSHelper.send(:load_css, path)
  end

  def css_for_doc(doc)
    PremailerRails::CSSHelper.css_for_doc(doc)
  end

  describe '#css_for_doc' do
    let(:html) { Fixtures::HTML.with_css_links(*files) }
    let(:doc) { Hpricot(html) }

    context 'when HTML contains linked CSS files' do
      let(:files) { %w[ stylesheets/base.css stylesheets/font.css ] }

      it 'should return the content of both files concatenated' do
        PremailerRails::CSSHelper \
          .expects(:load_css) \
          .with('http://example.com/stylesheets/base.css') \
          .returns('content of base.css')
        PremailerRails::CSSHelper \
          .expects(:load_css) \
          .with('http://example.com/stylesheets/font.css') \
          .returns('content of font.css')

        css_for_doc(doc).should == "content of base.css\ncontent of font.css"
      end
    end

    context 'when HTML contains style tag' do
      let(:files) { [] }
      let(:html) { Fixtures::HTML.with_style_block }

      it 'should not load the default file' do
        PremailerRails::CSSHelper \
          .expects(:load_css) \
          .with(:default) \
          .never

        css_for_doc(doc).should be_nil
      end
    end

    context 'when HTML contains no linked CSS file nor style block tag' do
      let(:files) { [] }
      let(:html) { Fixtures::HTML.with_no_css_link }

      it 'should load the default file' do
        PremailerRails::CSSHelper \
          .expects(:load_css) \
          .with(:default) \
          .returns('content of default css')

        css_for_doc(doc).should == 'content of default css'
      end
    end
  end

  describe '#load_css' do
    context 'when path is a url' do
      it 'should load the CSS at the local path' do
        File.expects(:read).with('RAILS_ROOT/public/stylesheets/base.css')

        load_css('http://example.com/stylesheets/base.css?test')
      end
    end

    context 'when path is a relative url' do
      it 'should load the CSS at the local path' do
        File.expects(:read).with('RAILS_ROOT/public/stylesheets/base.css')

        load_css('/stylesheets/base.css?test')
      end
    end

    context 'when file is cached' do
      it 'should return the cached value' do
        cache = PremailerRails::CSSHelper.send(:instance_variable_get, '@cache')
        cache['/stylesheets/base.css'] = 'content of base.css'

        load_css('http://example.com/stylesheets/base.css') \
          .should == 'content of base.css'
      end
    end

    context 'when in development mode' do
      it 'should not return cached values' do
        cache = PremailerRails::CSSHelper.send(:instance_variable_get, '@cache')
        cache['/stylesheets/base.css'] = 'cached content of base.css'
        File.expects(:read) \
            .with('RAILS_ROOT/public/stylesheets/base.css') \
            .returns('new content of base.css')
        Rails.env.stubs(:development?).returns(true)

        load_css('http://example.com/stylesheets/base.css') \
          .should == 'new content of base.css'
      end
    end

    context 'when Hassle is used' do
      before { Rails.configuration.middleware.stubs(:include?) \
                                             .with(Hassle) \
                                             .returns(true) }

      it 'should load email.css when the default CSS is requested' do
        File.expects(:read) \
            .with('RAILS_ROOT/tmp/hassle/stylesheets/email.css') \
            .returns('content of default css')

        load_css(:default).should == 'content of default css'
      end

      it 'should return the content of the file compiled by Hassle' do
        File.expects(:read) \
            .with('RAILS_ROOT/tmp/hassle/stylesheets/base.css') \
            .returns('content of base.css')

        load_css('http://example.com/stylesheets/base.css') \
          .should == 'content of base.css'
      end
    end

    context 'when Rails asset pipeline is used' do

      before {
        Rails.configuration.stubs(:assets).returns(
          stub(
            :enabled => true,
            :prefix  => '/assets'
          )
        )
        PremailerRails::CSSLoaders::AssetPipelineLoader.stubs(:assets_precompiled?).returns(false)
      }

      it 'should load email.css when the default CSS is requested' do
        Rails.application.assets.expects(:find_asset) \
                                .with('email.css') \
                                .returns(mock(:to_s => 'content of default css'))

        load_css(:default).should == 'content of default css'
      end

      it 'should return the content of the file compiled by Rails' do
        Rails.application.assets.expects(:find_asset) \
                                .with('base.css') \
                                .returns(mock(:to_s => 'content of base.css'))

        load_css('http://example.com/assets/base.css') \
          .should == 'content of base.css'
      end

      it 'should return same file when path contains file fingerprint' do
        Rails.application.assets \
                         .expects(:find_asset) \
                         .with('base.css') \
                         .returns(mock(:to_s => 'content of base.css'))

        load_css(
          'http://example.com/assets/base-089e35bd5d84297b8d31ad552e433275.css'
        ).should == 'content of base.css'
      end

      context 'when asset can not be found' do
        before {
          Rails.application.assets.stubs(:find_asset).returns(nil)
          Rails.configuration.stubs(:action_controller).returns(
            stub(:asset_host => 'http://example.com')
          )
          Rails.configuration.stubs(:assets).returns(
            stub(
              :enabled => true,
              :prefix  => '/assets',
              :digests => {
                'base.css' => 'base-089e35bd5d84297b8d31ad552e433275.css'
              }
            )
          )
        }
        let(:string_io) { StringIO.new('content of base.css') }
        let(:url) {
          'http://example.com/assets/base-089e35bd5d84297b8d31ad552e433275.css'
        }

        it 'should request the file' do
          Kernel.expects(:open).with(url).returns(string_io)

          load_css(
            'http://example.com/assets/base.css'
          ).should == 'content of base.css'
        end

        it 'should request the same file when path contains file fingerprint' do
          Kernel.expects(:open).with(url).returns(string_io)

          load_css(
            'http://example.com/assets/base-089e35bd5d84297b8d31ad552e433275.css'
          ).should == 'content of base.css'
        end
      end

      context 'when assets are precompiled' do
        before {
          PremailerRails::CSSLoaders::AssetPipelineLoader.stubs(:assets_precompiled?).returns(true)
        }

        it 'should load precompiled assets from the filesystem' do
          File.expects(:read) \
              .with('RAILS_ROOT/public/somewhere/on/the/disk/precompiled.css') \
              .returns('content of compiled css')

          load_css('precompiled.css').should == 'content of compiled css'
        end
      end
    end

    context 'when static stylesheets are used' do
      it 'should load email.css when the default CSS is requested' do
        File.expects(:read) \
            .with('RAILS_ROOT/public/stylesheets/email.css') \
            .returns('content of default css')

        load_css(:default).should == 'content of default css'
      end

      it 'should return the content of the static file' do
        File.expects(:read) \
            .with('RAILS_ROOT/public/stylesheets/base.css') \
            .returns('content of base.css')

        load_css('http://example.com/stylesheets/base.css') \
          .should == 'content of base.css'
      end
    end
  end
end
