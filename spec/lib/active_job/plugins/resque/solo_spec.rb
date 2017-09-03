require 'spec_helper'

RSpec.describe ActiveJob::Plugins::Resque::Solo do
  include_context "fake resque"

  QUEUE = "default_test_queue"

  describe "#perform_later" do
    class DefaultTestJob < ActiveJob::Base
      include ActiveJob::Plugins::Resque::Solo
      queue_as QUEUE

      def self.resque_present?; true; end
      def perform(*args); end
    end

    let(:job_class) { DefaultTestJob }

    subject { DefaultTestJob.perform_later }

    context "when the job is already on the queue" do
      it "should not enqueue the job" do
        expect { subject }.to_not have_enqueued(DefaultTestJob).on_queue(QUEUE)
      end
    end

    context "when the job class is already on the queue for a different class" do
      class OtherJob < ActiveJob::Base; end

      let(:job_class) { OtherJob }

      it "should enqueue the job" do
        expect { DefaultTestJob.perform_later }.to have_enqueued(DefaultTestJob).on_queue(QUEUE)
      end
    end

    context "when the job is not already enqueued" do
      let(:enqueued_job) { nil }

      it "should appear on the queue" do
        expect { subject }.to have_enqueued(DefaultTestJob).on_queue(QUEUE)
      end
    end

    context "when the job is already executing" do
      let(:arguments) { [] }
      let(:processing) { {"queue"=>QUEUE, "payload"=>{"args"=>[{"job_class"=>job_class.to_s, "queue_name"=>QUEUE, "arguments"=> arguments }]}} }

      it "should not enqueue the job" do
        expect { subject }.to_not have_enqueued(DefaultTestJob).on_queue(QUEUE)
      end
    end
  end

  describe "#solo_only_args" do
    class DefaultTestOnlyJob < ActiveJob::Base
      include ActiveJob::Plugins::Resque::Solo
      queue_as QUEUE

      solo_only_args :user

      def self.resque_present?; true; end
      def perform(user: nil, ignored_arg: nil); end
    end

    let(:user) { "USER" }
    let(:ignored_arg) { enqueued_ignored_arg }
    let(:enqueued_ignored_arg) { 1 }
    let(:job_class) { DefaultTestOnlyJob }

    let(:arg1) { { "user" => user, "ignored_arg" => enqueued_ignored_arg } }

    subject { DefaultTestOnlyJob.perform_later(user: user, ignored_arg: ignored_arg) }

    context "when the job is already enqueued with the same args" do
      it "should not enqueue a job" do
        expect { subject }.to_not have_enqueued(DefaultTestOnlyJob)
      end
    end

    context "when the job is already enqueued with a different ignored arg" do
      let(:ignored_arg) { 2 }

      it "should not enqueue a job" do
        expect { subject }.to_not have_enqueued(DefaultTestOnlyJob)
      end
    end
  end

  describe "#solo_except_args" do
    class DefaultTestExceptJob < ActiveJob::Base
      include ActiveJob::Plugins::Resque::Solo
      queue_as QUEUE

      solo_except_args :ignored_arg

      def self.resque_present?; true; end
      def perform(user: nil, ignored_arg: nil); end
    end

    let(:user) { "USER" }
    let(:ignored_arg) { enqueued_ignored_arg }
    let(:enqueued_ignored_arg) { 1 }
    let(:job_class) { DefaultTestExceptJob }

    let(:arg1) { { "user" => user, "ignored_arg" => enqueued_ignored_arg } }

    subject { DefaultTestExceptJob.perform_later(user: user, ignored_arg: ignored_arg) }

    context "when the job is already enqueued with the same args" do
      it "should not enqueue a job" do
        expect { subject }.to_not have_enqueued(DefaultTestExceptJob)
      end
    end

    context "when the job is already enqueued with a different ignored arg" do
      let(:ignored_arg) { 2 }

      it "should not enqueue a job" do
        expect { subject }.to_not have_enqueued(DefaultTestExceptJob)
      end
    end
  end
end
