require "json"
require 'pathname'

class ResultsFileParser

  ## Example of JSON input
  # {"ResultFormatVersion"=>"0.1",
  #  "RunnerConfig"=>
  #  {"db-name"=>"benchmark",
  #   "batch-size"=>5000,
  #   "workers"=>16,
  #   "limit"=>0,
  #   "do-load"=>true,
  #   "do-create-db"=>true,
  #   "do-abort-on-exist"=>false,
  #   "reporting-period"=>10000000000,
  #   "hash-workers"=>false,
  #   "no-flow-control"=>false,
  #   "channel-capacity"=>0,
  #   "insert-intervals"=>"",
  #   "results-file"=>"results/timescaledb//4h_10s_cpu-only_4000_16w",
  #   "file"=>"/tmp/bulk_data/timescaledb_data_cpu-only_4000",
  #   "seed"=>0},
  # "StartTime"=>1625152513,
  # "EndTime"=>1625152766,
  # "DurationMillis"=>253343,
  # "Totals"=>{"metricRate"=>4092466.509558407, "rowRate"=>409246.6509558407}}
  def initialize(file)
    @file = file
    @target = Pathname.new(file).parent.basename.to_s
    @content = JSON.parse(IO.read(@file))
    parse_params!
  end

  attr_reader :target, :chunk_time, :log_interval, :use_case, :scale, :workers

  def started
    Time.at @content["StartTime"]
  end

  def ended
    Time.at @content["EndTime"]
  end

  def duration
    @content["DurationMillis"]
  end

  def metric_rate
    @content["Totals"]["metricRate"]
  end

  def row_rate
    @content["Totals"]["rowRate"]
  end

  def batch_size
    config['batch-size']
  end

  def attributes
    %i[
      target chunk_time log_interval use_case scale workers
      started ended duration metric_rate row_rate batch_size
    ].each_with_object({}) do |method, attrs|
      attrs[method] = send(method)
    end
  end

  private

  def config
    @content["RunnerConfig"]
  end

  def parse_params!
    @chunk_time, @log_interval, @use_case, @scale, @workers = Pathname.new(@file).basename.to_s.split '_'
    @workers = @workers[0..-2].to_i
  end
end
parser = ResultsFileParser.new "spec/support/fixtures/results/timescaledb/4h_10s_cpu-only_4000_16w"
pp parser.attributes
