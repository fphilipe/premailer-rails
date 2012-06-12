require 'spec_helper'

describe PremailerRails::Hook do
  describe '.delivering_email' do
    before { File.stubs(:read).returns('') }
    def run_hook(message)
      PremailerRails::Hook.delivering_email(message)
    end

    context 'when message contains html part' do
      let(:message) { Fixtures::Message.with_parts :html }

      it 'should create a text part from the html part' do
        PremailerRails::Premailer.any_instance.expects(:to_plain_text)
        run_hook(message)
        message.text_part.should be_a Mail::Part
      end

      it 'should inline the css in the html part' do
        PremailerRails::Premailer.any_instance.expects(:to_inline_css)
        run_hook(message)
      end

      it 'should not create a text part if disabled' do
        PremailerRails::Premailer.any_instance.expects(:to_plain_text).never
        PremailerRails.config[:generate_text_part] = false
        run_hook(message)
        PremailerRails.config[:generate_text_part] = true
        message.text_part.should be_nil
        message.html_part.should be_a Mail::Part
      end

      it 'should not create an additional html part' do
        run_hook(message)
        message.parts.count { |i| i.content_type =~ /text\/html/ }.should == 1
      end
    end

    context 'when message contains text part' do
      let(:message) { Fixtures::Message.with_parts :text }

      it 'should not modify the message' do
        Premailer.expects(:new).never
        run_hook(message)
      end
    end

    context 'when message contains html and text part' do
      let(:message) { Fixtures::Message.with_parts :html, :text }

      it 'should not create a text part from the html part' do
        PremailerRails::Premailer.any_instance.expects(:to_plain_text).never
        run_hook(message)
        message.text_part.should be_a Mail::Part
      end

      it 'should inline the css in the html part' do
        PremailerRails::Premailer.any_instance.expects(:to_inline_css)
        run_hook(message)
      end
    end

    context 'when message contains html body' do
      let(:message) { Fixtures::Message.with_body :html }

      it 'should create a text part from the html part' do
        PremailerRails::Premailer.any_instance.expects(:to_plain_text)
        run_hook(message)
      end

      it 'should create a html part and inline the css' do
        PremailerRails::Premailer.any_instance.expects(:to_inline_css)
        run_hook(message)
        message.html_part.should be_a Mail::Part
      end

      it 'should not create a text part if disabled' do
        PremailerRails::Premailer.any_instance.expects(:to_plain_text).never
        PremailerRails.config[:generate_text_part] = false
        run_hook(message)
        PremailerRails.config[:generate_text_part] = true
        message.text_part.should be_nil
        message.html_part.should be_nil
        message.body.should_not be_empty
      end
    end

    context 'when message contains text body' do
      let(:message) { Fixtures::Message.with_body :text }

      it 'should not modify the message' do
        Premailer.expects(:new).never
        run_hook(message)
      end
    end
  end
end
