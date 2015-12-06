require "parseconfig"

module Migrate
  class Conf
    attr_reader :root

    def initialize(root, file)
      @root = root
      @file=file
      @file_path = "#{root}/#{file}"
      @loaded = false
    end

    def exists?
      File.exist? @file_path
    end

    def init(config)
      if not Dir.exist? @root
        Dir.mkdir @root
      end

      File.open(@file_path, "w") do |f|
        config.map do |key, value|
          f.puts "#{key}=#{value}\n"
        end
      end

      Log.success("Configuration file created. Location: `#{@file_path}`")
    end

    def load!
      Log.info("Loading configuration...")
      config = ParseConfig.new(@file_path)
  
      config.get_params.map do |param|
        self.class.send(:attr_reader, param)
        instance_variable_set("@#{param}", config[param])
      end

      @loaded = true
      Log.success("Configuration loaded.")
    end

    def delete
      File.delete @file_path
    rescue Exception => e
      Log.error("Error while removing configuration file.", e)
      exit
    end

    def get_db
      case @storage
      when "pg"
        if @pg == nil
          @pg = Storage::Postgres.new(self)
        end

        @pg
      when "mysql"
        if @mysql == nil
          @mysql = Storage::Mysql.new(self)
        end

        @mysql
      end
    end

    def get_lang
      case @lang
      when "sql"
        if @sql == nil
          @sql = Lang::Sql.new(get_db)
        end

        @sql
      when "javascript"
        if @javascript == nil
          @javascript = Lang::Javascript.new
        end

        @javascript
      when "ruby"
        if @ruby == nil
          @ruby = Lang::Ruby.new
        end

        @ruby
      when "go"
        if @go == nil
          @go = Lang::Go.new
        end

        @go
      when "python"
        if @python == nil
          @python = Lang::Python.new
        end

        @python
      end
    end
  end
end
