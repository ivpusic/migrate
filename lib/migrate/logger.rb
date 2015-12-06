require "colorize"

module Migrate
  class Log
    @@debug = true

    def self.verbose(verbose)
      @@debug = verbose
    end

    def self.info(msg)
      return if not @@debug
      puts ("[INFO] " + msg).green
    end

    def self.warn(msg)
      return if not @@debug
      puts ("[WARN] " + msg).yellow
    end

    def self.error(msg, e=nil)
      return if not @@debug
      puts ("[ERRPR] " + msg + (e != nil ? " #{e.message}" : "")).red

      if e != nil
        puts e.backtrace
      end
    end

    def self.success(msg)
      return if not @@debug
      puts ("[SUCCESS] " + msg).blue
    end

    def self.version(msg)
      puts (" [VERSION] #{msg} ").colorize(:color => :white, :background => :blue)
    end
  end
end
