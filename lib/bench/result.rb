require 'active_record'
require 'pg'

# Benchmark results representation.
class Bench::Result < ActiveRecord::Base
  self.primary_key = :time
  self.table_name = "benchmark_results"
  before_create do
    self.time ||= Time.now
  end

  # Allow you to execute like a migration block getting access directly to the
  # connection
  def self.with_connection &block
    connection.instance_exec(&block)
  end

  # Creates `benchmark_results` table if it doesn't exists
  def self.setup! force: false
    if (exists=self.table_exists?) && !force
      logger.info("Table #{Bench::Result.table_name} already exists (#{Bench::Result.count} records).")
      return
    end

    with_connection do
      drop_table(Bench::Result.table_name) if exists && force
      create_table(Bench::Result.table_name, id: false) do |t|
        t.timestamp :time, null: false, default: 'now()'
        t.string :target, :chunk_time, :log_interval, :use_case, null: false
        t.integer :scale, :workers, :duration, :batch_size, null: false
        t.timestamp :started, :ended, null: false
        t.float :row_rate, :metric_rate, null: false
      end

      execute("SELECT create_hypertable('benchmark_results', 'time')")
    end
  end
end
