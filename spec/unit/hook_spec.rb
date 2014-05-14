require 'spec_helper'

describe Premailer::Rails::Hook do
  describe ".perform" do
    let(:message) { double :message, header: header }
    let(:perform_hook) { Premailer::Rails::Hook.perform(message) }

    class << self
      def it_doesnt_inline_styles
        it "doesn't inline styles" do
          expect(described_class).not_to receive(:replace_html_part)
          perform_hook
        end
      end
    end

    context "when the skip_premailer is set" do
      let(:header) { { skip_premailer: true } }

      it "removes the skip_premailer" do
        perform_hook
        expect(header[:skip_premailer]).to be_nil
      end

      it_doesnt_inline_styles
    end

    context "when the skip_premailer is not set" do
      let(:header) { }
    end
  end
end
