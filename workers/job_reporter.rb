# frozen_string_literal: true

require_relative 'progress_publisher'

module GenerateVocabulary
  # Reports job progress to client
  class JobReporter
    attr_accessor :song

    def initialize(request_json, config)
      voc_request = LyricLab::Representer::VocabularyRequest
        .new(Struct.new)
        # .new(OpenStruct.new)
        .from_json(request_json)

      @song = voc_request.song
      @publisher = ProgressPublisher.new(config, voc_request.id)
    end

    def report(msg)
      @publisher.publish msg
    end

    def report_each_second(seconds, &operation)
      seconds.times do
        sleep(1)
        report(operation.call)
      end
    end
  end
end
