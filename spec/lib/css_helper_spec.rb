require 'spec_helper'

describe Premailer::Rails::CSSHelper do
  # Reset the CSS cache
  after { Premailer::Rails::CSSHelper.send(:instance_variable_set, '@cache', {}) }

  def load_css(path)
    Premailer::Rails::CSSHelper.send(:load_css, path)
  end

  def css_for_doc(doc)
    Premailer::Rails::CSSHelper.css_for_doc(doc)
  end

  describe '#css_for_doc' do
    let(:html) { Fixtures::HTML.with_css_links(*files) }
    let(:doc) { Hpricot(html) }

    context 'when HTML contains linked CSS files' do
      let(:files) { %w[ stylesheets/base.css stylesheets/font.css ] }

      it 'should return the content of both files concatenated' do
        Premailer::Rails::CSSHelper \
          .expects(:load_css) \
          .with('http://example.com/stylesheets/base.css') \
          .returns('content of base.css')
        Premailer::Rails::CSSHelper \
          .expects(:load_css) \
          .with('http://example.com/stylesheets/font.css') \
          .returns('content of font.css')

        css_for_doc(doc).should == "content of base.css\ncontent of font.css"
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
        cache =
          Premailer::Rails::CSSHelper.send(:instance_variable_get, '@cache')
        cache['/stylesheets/base.css'] = 'content of base.css'

        load_css('http://example.com/stylesheets/base.css') \
          .should == 'content of base.css'
      end
    end

    context 'when in development mode' do
      it 'should not return cached values' do
        cache =
          Premailer::Rails::CSSHelper.send(:instance_variable_get, '@cache')
        cache['/stylesheets/base.css'] = 'cached content of base.css'
        File.expects(:read) \
            .with('RAILS_ROOT/public/stylesheets/base.css') \
            .returns('new content of base.css')
        Rails.env.stubs(:development?).returns(true)

        load_css('http://example.com/stylesheets/base.css') \
          .should == 'new content of base.css'
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
      }

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
    end

    context 'when static stylesheets are used' do
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
