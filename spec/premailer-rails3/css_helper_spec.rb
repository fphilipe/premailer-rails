require 'spec_helper'

describe PremailerRails::CSSHelper do
  # Reset the CSS cache
  after { PremailerRails::CSSHelper.send(:class_variable_set, '@@css_cache', {}) }

  def load_css_at_path(path)
    PremailerRails::CSSHelper.send(:load_css_at_path, path)
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
          .expects(:load_css_at_path) \
          .with('http://example.com/stylesheets/base.css') \
          .returns('content of base.css')
        PremailerRails::CSSHelper \
          .expects(:load_css_at_path) \
          .with('http://example.com/stylesheets/font.css') \
          .returns('content of font.css')

        css_for_doc(doc).should == "content of base.css\ncontent of font.css"
      end
    end

    context 'when HTML contains no linked CSS file' do
      let(:files) { [] }

      it 'should return the content of the default file' do
        PremailerRails::CSSHelper \
          .expects(:load_css_at_path) \
          .with(:default) \
          .returns('content of default css file')

        css_for_doc(doc).should == 'content of default css file'
      end
    end
  end

  describe '#load_css_at_path' do
    context 'when path is a url' do
      it 'should load the CSS at the local path' do
        File.expects(:read).with('RAILS_ROOT/public/stylesheets/base.css')

        load_css_at_path('http://example.com/stylesheets/base.css?test')
      end
    end

    context 'when file is cached' do
      it 'should return the cached value' do
        cache = PremailerRails::CSSHelper.send(:class_variable_get, '@@css_cache')
        cache['/stylesheets/base.css'] = 'content of base.css'

        load_css_at_path('http://example.com/stylesheets/base.css') \
          .should == 'content of base.css'
      end
    end

    context 'when in development mode' do
      it 'should not return cached values' do
        cache = PremailerRails::CSSHelper.send(:class_variable_get, '@@css_cache')
        cache['/stylesheets/base.css'] = 'cached content of base.css'
        File.expects(:read) \
            .with('RAILS_ROOT/public/stylesheets/base.css') \
            .returns('new content of base.css')
        Rails.env.stubs(:development?).returns(true)

        load_css_at_path('http://example.com/stylesheets/base.css') \
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

        load_css_at_path(:default).should == 'content of default css'
      end

      it 'should return the content of the file compiled by Hassle' do
        File.expects(:read) \
            .with('RAILS_ROOT/tmp/hassle/stylesheets/base.css') \
            .returns('content of base.css')

        load_css_at_path('http://example.com/stylesheets/base.css') \
          .should == 'content of base.css'
      end
    end

    context 'when Rails asset pipeline is used' do
      before { Rails.configuration.assets.stubs(:enabled).returns(true) }

      it 'should load email.css when the default CSS is requested' do
        Rails.application.assets.expects(:find_asset) \
                                .with('email.css') \
                                .returns(mock(:body => 'content of default css'))

        load_css_at_path(:default).should == 'content of default css'
      end

      it 'should return the content of the file compiled by Rails' do
        Rails.application.assets.expects(:find_asset) \
                                .with('base.css') \
                                .returns(mock(:body => 'content of base.css'))

        load_css_at_path('http://example.com/assets/base.css') \
          .should == 'content of base.css'
      end
    end

    context 'when static stylesheets are used' do
      it 'should load email.css when the default CSS is requested' do
        File.expects(:read) \
            .with('RAILS_ROOT/public/stylesheets/email.css') \
            .returns('content of default css')

        load_css_at_path(:default).should == 'content of default css'
      end

      it 'should return the content of the static file' do
        File.expects(:read) \
            .with('RAILS_ROOT/public/stylesheets/base.css') \
            .returns('content of base.css')

        load_css_at_path('http://example.com/stylesheets/base.css') \
          .should == 'content of base.css'
      end
    end
  end
end
