# coding: UTF-8

require 'spec_helper'

describe Premailer::Rails::CustomizedPremailer do
  [ :nokogiri, :hpricot ].each do |adapter|
    next if adapter == :hpricot and RUBY_PLATFORM == 'java'

    context "when adapter is #{adapter}" do
      before { Premailer::Adapter.stubs(:use).returns(adapter) }

      describe '#to_plain_text' do
        it 'should include the text from the HTML part' do
          premailer =
            Premailer::Rails::CustomizedPremailer
              .new(Fixtures::Message::HTML_PART)
          premailer.to_plain_text.gsub(/\s/, ' ').strip
            .should == Fixtures::Message::TEXT_PART.gsub(/\s/, ' ').strip
        end
      end

      describe '#to_inline_css' do
        context 'when inline CSS block present' do
          it 'should return the HTML with the CSS inlined' do
            Premailer::Rails::CSSHelper
              .stubs(:css_for_doc)
              .returns('p { color: red; }')
            html = Fixtures::Message::HTML_PART
            premailer = Premailer::Rails::CustomizedPremailer.new(html)
            premailer.to_inline_css.should =~ /<p style=("|')color: ?red;?\1>/
          end
        end

        context 'when CSS is loaded externally' do
          it 'should return the HTML with the CSS inlined' do
            html = Fixtures::Message::HTML_PART_WITH_CSS
            premailer = Premailer::Rails::CustomizedPremailer.new(html)
            premailer.to_inline_css.should =~ /<p style=("|')color: ?red;?\1>/
          end
        end
      end
    end
  end

  describe '.new' do
    it 'should extract the CSS' do
      Premailer::Rails::CSSHelper.expects(:css_for_doc)
      Premailer::Rails::CustomizedPremailer.new('some html')
    end

    it 'should pass on the configs' do
      Premailer::Rails.config = { foo: :bar }
      premailer = Premailer::Rails::CustomizedPremailer.new('some html')
      premailer.instance_variable_get(:'@options')[:foo].should == :bar
    end

    it 'should not allow to override with_html_string' do
      Premailer::Rails.config = { with_html_string: false }
      premailer = Premailer::Rails::CustomizedPremailer.new('some html')
      options = premailer.instance_variable_get(:'@options')
      options[:with_html_string].should == true
    end
  end
end
