require 'spec_helper'

describe Premailer::Rails::Hook do
  describe "#perform" do
    let(:hook) { described_class.new message }

    let(:message) { double :message, header: header, content_type: content_type }
    let(:perform_hook) { hook.perform }
    let(:rails_config) { { } }
    let(:header) { { } }
    let(:content_type) { "text/html, something/else"}

    before(:each) do
      allow(Premailer::Rails).to receive(:config).and_return rails_config
    end

    class << self
      def it_doesnt_inline_styles
        it "doesn't inline styles" do
          expect(hook).not_to receive(:replace_html_part)
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

    context "and Rails.config[:disable_premailer] is set" do
      let(:rails_config) { { disable_premailer: true } }

      context "and the header has no enable_premailer" do
        it_doesnt_inline_styles
      end

      context "and the header has enable_premailer" do
        let(:header) { { enable_premailer: true } }

        before(:each) do
          allow(hook).to receive(:generate_html_part_replacement).and_return "replacement"
          allow(hook).to receive(:replace_html_part)
        end

        it "removes enable_premailer header" do
          perform_hook
          expect(header[:enable_premailer]).to be_nil
        end

        it "inlines CSS" do
          expect(hook).to receive(:replace_html_part).with("replacement")
          perform_hook
        end

      end
    end
  end
end
