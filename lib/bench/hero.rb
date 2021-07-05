require "bench/hero/version"
require_relative 'parser'
require_relative 'result'
require 'dotenv'

module Bench
  module Hero
    module_function

    def connect!
      Dotenv.load!
      ActiveRecord::Base.establish_connection(ENV['PG_URI'])
    end

    def setup! force: false
      connect!
      Bench::Result.setup! force: force
    end

    # Digests several JSON report files from tsbs result-file argument.
    # It allows you to do further analyzis of the data in your TimescaleDB.
    def digest! *report_files
      connect!
      report_files.each do |report_file|
        puts "Importing: #{report_file}"
        attributes = Bench::Parser.new(report_file).attributes

        require "pry";binding.pry
        Bench::Result.create(attributes)
      end
    end
  end
end
