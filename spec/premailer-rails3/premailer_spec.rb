# coding: UTF-8

require 'spec_helper'

describe PremailerRails::Premailer do
  [ :nokogiri, :hpricot ].each do |adapter|
    context "when adapter is #{adapter}" do
      before { ::Premailer::Adapter.stubs(:use).returns(adapter) }

      describe '#to_plain_text' do
        it 'should include the text from the HTML part' do
          premailer = PremailerRails::Premailer.new(Fixtures::Message::HTML_PART)
          premailer.to_plain_text.gsub(/\s/, ' ').strip \
            .should == Fixtures::Message::TEXT_PART.gsub(/\s/, ' ').strip
        end
      end

      describe '#to_inline_css' do
        it 'should return the HTML with the CSS inlined' do
          PremailerRails::CSSHelper.stubs(:css_for_doc).returns('p { color: red; }')
          html = Fixtures::Message::HTML_PART
          premailer = PremailerRails::Premailer.new(html)
          premailer.to_inline_css.should include '<p style="color: red;">'
        end
      end
    end
  end

  describe '.new' do
    it 'should extract the CSS' do
      PremailerRails::CSSHelper.expects(:css_for_doc)
      PremailerRails::Premailer.new('some html')
    end

    it 'should pass on the configs' do
      PremailerRails.config = { :foo => :bar }
      premailer = PremailerRails::Premailer.new('some html')
      premailer.instance_variable_get(:'@options')[:foo].should == :bar
    end

    it 'should not allow to override with_html_string' do
      PremailerRails.config = { :with_html_string => false }
      premailer = PremailerRails::Premailer.new('some html')
      options = premailer.instance_variable_get(:'@options')
      options[:with_html_string].should == true
    end
  end
end
