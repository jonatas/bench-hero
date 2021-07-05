require 'net/ssh'

# Represents a machine configuration, being used both to describe the
# configuration of the TSBS client and the Database server running.
# Until now we just collect basic info like cpu/memory and disk specs.
# @example
#   Bench::Machine.add_remote_client(host: "supertsbs")
#   Bench::Machine.add_remote_database_server(host: "benchdb")
#
class Bench::Machine < ActiveRecord::Base
  self.table_name = 'benchmark_machines'

  # Creates `benchmark_results` table if it doesn't exists
  def self.setup! force: false
    if (exists=self.table_exists?) && !force
      logger.info("Table #{Bench::Machine.table_name} already exists (#{Bench::Machine.count} records).")
      return
    end

    with_connection do
      drop_table(Bench::Machine.table_name) if exists && force
      create_table(Bench::Machine.table_name) do |t|
        t.string :purpose, :mem, :ip, null: false
        t.integer :cpu, null: false
        t.text :hd
      end
    end
  end

  # Allow you to execute like a migration block getting access directly to the connection
  def self.with_connection &block
    connection.instance_exec(&block)
  end
  
  def self.add_remote_client(host:)
    add_remote host: host, purpose: "client"
  end

  def self.add_remote_database_server(host:)
    add_remote host: host, purpose: "server"
  end

  attr_accessor :host
  def self.add_remote(host:, purpose:)
    create({purpose: purpose, host: host}.merge(Remote.new(host).info))
  end

  def remote
    Remote.new host
  end

  # Small class to wrap Remote ssh calls to get more information about the
  # machine. It's useful to fetch hardware information from both client and
  # server being used for the benchmark.
  # @example
  #   Bench::Machine::Remote.new("bench").info
  #   # => {:cpu=>8, :mem=>"63GiB", :hd=> "..."}
  class Remote
    def initialize(host)
      @host = host
    end

    def info
      {
        cpu: cpu_cores,
        mem: memory_size,
        hd: hard_disk_specs,
        ip: ip
      }
    end

    def cpu_cores
      run_ssh_command(%|grep "cpu cores" /proc/cpuinfo -m 1|)
        .lines.first.split(' ').last.to_i
    end

    def memory_size
      run_ssh_command(%{lshw -c memory | grep size}).split(' ').last
    end

    def hard_disk_specs
      run_ssh_command(%{sudo lshw -class disk -class storage})
    end

    def ip
      run_ssh_command(%{curl http://checkip.amazonaws.com}).lines.last.chomp
    end

    # Make sure you have all configured all the SSH config details in the ~/.ssh/config file
    # @example of different username
    # Host tsbs
    #    User ubuntu
    def ssh
      @ssh ||= Net::SSH.start(@host)
    end

    def run_ssh_command cmd
      #puts "running remote command: #{ cmd }"
      ssh.exec!(cmd)
    end
  end
end
