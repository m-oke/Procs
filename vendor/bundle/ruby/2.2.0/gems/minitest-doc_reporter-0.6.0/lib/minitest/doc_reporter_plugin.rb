require_relative 'doc_reporter'

module Minitest
  include Minitest::DocReporter

  def self.plugin_doc_reporter_options(opts, options)
  end

  def self.plugin_doc_reporter_init(options) 
    self.reporter.reporters = []
    self.reporter << DocReporter::DocReporter.new(options)
  end
end
