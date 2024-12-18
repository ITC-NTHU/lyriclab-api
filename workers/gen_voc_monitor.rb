# frozen_string_literal: true

module GenerateVocabulary
    module GenerateMonitor
      WORK_PROGRESS = {
        'STARTED'   => 15,
        'extracting'   => 30,
        'filtering'    => 50,
        'processing' => 70,
        'finalizing' => 80,
        'FINISHED'  => 100
      }.freeze
  
      def self.starting_percent
        WORK_PROGRESS['STARTED'].to_s
      end
  
      def self.finished_percent
        WORK_PROGRESS['FINISHED'].to_s
      end
  
      def self.progress(line)
        WORK_PROGRESS[first_word_of(line)].to_s
      end
  
      def self.percent(stage)
        WORK_PROGRESS[stage].to_s
      end
  
      def self.first_word_of(line)
        line.match(/^[A-Za-z]+/).to_s
      end
    end
  end