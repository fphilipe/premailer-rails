require 'spec_helper'

describe PremailerRails::Hook do
  describe '.delivering_email' do
    before { File.stubs(:read).returns('') }
    def run_hook(message)
      PremailerRails::Hook.delivering_email(message)
    end

    context 'when message contains html part' do
      let(:message) { Fixtures::Message.with_parts :html }

      it 'should not create a text part from the html part' do
        PremailerRails::Premailer.any_instance.expects(:to_plain_text).never
        run_hook(message)
      end

      it 'should inline the css in the html part' do
        PremailerRails::Premailer.any_instance.expects(:to_inline_css)
        run_hook(message)
      end
    end

    context 'when message contains html part and content-type is set to "multipart/mixed"' do
      let(:message) { Fixtures::Message.with_mixed_parts :html }

      it 'should not change content-type' do
        PremailerRails::Premailer.any_instance.expects(:to_inline_css)
        run_hook(message)
        message.content_type.should == 'multipart/mixed'
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
        PremailerRails::Premailer.any_instance.expects(:to_inline_css).returns("<html>body</html>")
        run_hook(message)
        message.html_part.body.should == "<html>body</html>"
      end
    end

    context 'when message contains html body' do
      let(:message) { Fixtures::Message.with_body :html }

      it 'should not create a text part from the html part' do
        PremailerRails::Premailer.any_instance.expects(:to_plain_text).never
        run_hook(message)
      end

      it 'should update message body and inline the css' do
        PremailerRails::Premailer.any_instance.expects(:to_inline_css).returns("<html>body</html>")
        run_hook(message)
        message.body.should == "<html>body</html>"
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
