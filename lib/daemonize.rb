require 'yaml'

# Used to Daemonize long running rake scripts.
# Usage:
# include this module in the class you want to daemonize
# BEFORE, you start the long running loop, call 'daemonize'
module DaemonizeHelper
  
  attr_accessor :configkey
  
  class PidFile
    def initialize(configkey)
      @pid_dir = File.expand_path(RAILS_ROOT)
      options = YAML.load_file(File.join(RAILS_ROOT,"config","director.yml"))
      abort "Cannot find 'pidfile' reference. Check the 'director.yml' configuration file." unless options[configkey]["pidfile"]
      @pid_file = File.join(@pid_dir, options[configkey]["pidfile"])
    end
    
    def check
      if pid = read_pid
        if process_running? pid
          raise "#{@pid_file} already exists (PID: #{pid})"
        else
          Log.info "Removing stale PID file: #{@pid_file}"
          remove
        end
      end
    end
    
    def ensure_dir
      FileUtils.mkdir_p @pid_dir
    end
  
    def write
      ensure_dir
      open(@pid_file,'w') {|f| f.write(Process.pid) }
      File.chmod(0644, @pid_file)
    end
  
    def remove
      File.delete(@pid_file) if exists?
    end
  
    def read_pid
      open(@pid_file,'r') {|f| f.read.to_i } if exists?
    end
    
    def exists?
      File.exists? @pid_file
    end

    def to_s
      @pid_file
    end
    
    private
    def process_running?(pid)
      Process.getpgid(pid) != -1
    rescue Errno::ESRCH
      false
    end
  end
  
  def daemonize
    pid_file = PidFile.new(configkey)
    pid_file.check
    exit if fork
    Process.setsid
    exit if fork
    File.umask 0000
    STDIN.reopen "/dev/null"
    STDOUT.reopen "/dev/null", "a"
    STDERR.reopen STDOUT
    pid_file.write
    at_exit { pid_file.remove }
  end
  
  def stop_daemon
    pid_file = PidFile.new(configkey)
    unless pid = pid_file.read_pid
      puts "#{pid_file} not found"
      exit
    end
    puts "Stopping daemon (PID: #{pid})."
    begin
      Process.kill('TERM', pid)
    rescue Errno::ESRCH
      puts "Process does not exist (PID: #x{pid})."
      exit
    end
    puts 'Done.'
  end
  
end
