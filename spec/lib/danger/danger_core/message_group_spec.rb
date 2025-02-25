require "danger/danger_core/messages/violation"
require "danger/danger_core/message_group"

RSpec.describe Danger::MessageGroup do
  subject(:message_group) { described_class.new(file: file, line: line) }

  shared_examples_for "with varying line and file" do |behaves_like:|
    context "with nil file and line" do
      let(:file) { nil }
      let(:line) { nil }
      it_behaves_like behaves_like
    end

    context "with a filename and nil line" do
      let(:file) { "test.txt" }
      let(:line) { nil }
      it_behaves_like behaves_like
    end

    context "with a line and nil filename" do
      let(:file) { nil }
      let(:line) { 180 }
      it_behaves_like behaves_like
    end
    context "with a file and line" do
      let(:file) { "test.txt" }
      let(:line) { 190 }
      it_behaves_like behaves_like
    end
  end

  describe "#same_line?" do
    subject { message_group.same_line? other }

    shared_examples_for "true when same line" do
      context "on the same line" do
        let(:other_file) { file }
        let(:other_line) { line }

        it { is_expected.to be true }
      end

      context "on a different line" do
        let(:other_file) { file }
        let(:other_line) { 200 }

        it { is_expected.to be false }
      end

      context "in a different file" do
        let(:other_file) { "jeff.txt" }
        let(:other_line) { line }

        it { is_expected.to be false }
      end

      context "in a different on a different line" do
        let(:other_file) { "jeff.txt" }
        let(:other_line) { 200 }

        it { is_expected.to be false }
      end
    end

    context "when other is a Violation" do
      let(:other) { Danger::Violation.new("test message",
                                          false,
                                          other_file,
                                          other_line) }
      include_examples "with varying line and file", behaves_like: "true when same line"
    end

    context "when other is a Markdown" do
      let(:other) { Danger::Markdown.new("test message",
                                         other_file,
                                         other_line) }

      include_examples "with varying line and file", behaves_like: "true when same line"
    end

    context "when other is a MessageGroup" do
      let(:other) { described_class.new(file: other_file,
                                        line: other_line) }

      include_examples "with varying line and file", behaves_like: "true when same line"
    end
  end

  describe "<<" do
    subject { message_group << message }

    shared_examples_for "adds when same line" do
      context "on the same line" do
        let(:other_file) { file }
        let(:other_line) { line }

        it { expect { subject }.to change { message_group.messages.count }.by 1 }
      end

      context "on a different line" do
        let(:other_file) { file }
        let(:other_line) { 200 }

        it { expect { subject }.not_to change { message_group.messages.count } }
      end

      context "in a different file" do
        let(:other_file) { "jeff.txt" }
        let(:other_line) { line }

        it { expect { subject }.not_to change { message_group.messages.count } }
      end

      context "in a different file on a different line" do
        let(:other_file) { "jeff.txt" }
        let(:other_line) { 200 }

        it { expect { subject }.not_to change { message_group.messages.count } }
      end
    end

    context "when message is a Violation" do
      let(:message) { Danger::Violation.new("test message",
                                            false,
                                            other_file,
                                            other_line) }
      include_examples "with varying line and file", behaves_like: "adds when same line"
    end

    context "when message is a Markdown" do
      let(:message) { Danger::Markdown.new("test message",
                                           other_file,
                                           other_line) }

      include_examples "with varying line and file", behaves_like: "adds when same line"
    end
  end
end
