require_relative "hero/version"
require_relative 'parser'
require_relative 'result'
require_relative 'machine'
require 'tempfile'
require 'dotenv'
require 'fileutils'

module Bench
  module Hero
    module_function

    def connect!
      Dotenv.load!
      ActiveRecord::Base.establish_connection(ENV['PG_URI'])
    end

    # Setup a new database creating the necessary tables.
    def setup! force: false
      connect!
      Result.setup! force: force
      Machine.setup! force: force
    end

    def digest_benchmarks! from_client:, to_server:
      print "\nEstablishing connection with TimescaleDB server..."
      connect!
      print "done!"
      print "\nFetch info from #{to_server}..."
      server = Machine.add_remote_database_server host: to_server
      print " done!"
      print "\nFetch info from #{from_client}..."
      client = Machine.add_remote_client host: from_client
      print " done!"

      print "\nSyncing results from the server ..."
      system "rsync -a #{from_client}:~/results ."
      print " done!"

      machines_info = {server_id: server.id, client_id: client.id}

      Dir["results/*/*"].each do |result_file|
        print "\n   Parsing #{result_file}... "
        attributes = Parser.new(result_file).attributes.merge(machines_info)
        print " saving ..."
        Result.create(attributes)
        print "done!"
      end
    end

    # Digests several JSON report files from tsbs result-file argument.
    # It allows you to do further analyzis of the data in your TimescaleDB.
    def digest! *report_files
      connect!
      report_files.each do |report_file|
        puts "Importing: #{report_file}"
        attributes = Parser.new(report_file).attributes
      end
    end
  end
end
