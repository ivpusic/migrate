module Migrate
  class Migrator
    def initialize(config)
      @config = config
      @db = config.get_db
      @lang = config.get_lang

      if @db == nil
        throw "Database connection not found."
        exit
      end

      if @lang == nil
        throw "Language not found."
      end
    end

    def init
      @db.tx do
        if @db.tables_exists?
          Log.info("Version tables already exist.")
        else
          @db.create_tables
        end

        self.recover
      end
    end

    def recover
      @db.tx do
        directory = @config.root
        migrations = Dir.entries(directory).select { |file| File.directory? File.join(directory, file)}
        migrations.each do |migration|
          match = migration.match(/v(\d*)-(.*)/i)
          if match != nil
            v, desc = match.captures
            unless @db.version_exists?(v)
              self.new(desc, v)
            end
          end
        end
      end
    end


    def migration_dir(migration)
      date = DateTime.parse(migration["created_date"].to_s)
      "#{@config.root}/v#{migration["version"]}-#{migration["description"]}"
    end

    def new(desc, version=nil)
      @db.tx do
        Log.info("Creating new migration...")

        if version == nil
          version = @db.highest_version.to_i + 1
        end

        migration = @db.new_migration(version, desc)
        migration_dir = self.migration_dir(migration)

        if Dir.exists? migration_dir
          Log.info("Migration directory '#{migration_dir}' already exists.")
        else
          Dir.mkdir migration_dir
          @lang.create_migration(migration_dir)
        end

        Log.success("Migration for version #{migration["version"]} created.")
        migration_dir
      end
    rescue Exception => e
      Log.error("Error while creating new migration.", e)
      exit
    end

    # will execute single migration by running up or down script
    def exec_migration(migration, is_up)
      migration_dir = self.migration_dir(migration)
      result = @lang.exec_migration(migration_dir, is_up)
      if @lang.ext != "sql"
        puts result
      end

      Log.info("Updating current version number...")
      version = migration["version"]
      is_up ? @db.log_up(version) : @db.log_down(version)
    end

    # will execute range of migrations
    def exec_migrations(is_up=true)
      Log.info("Executing migrations...")
      migrations = yield @db.current_version

      if migrations.count == 0
        Log.warn("Migrations not found")
        return
      end

      migrations.each do |migration|
        self.exec_migration(migration, is_up)
      end
      Log.success("Migrations executed. Current version: #{@db.current_version}")
    end

    def up(to_version=nil)
      @db.tx do
        self.exec_migrations do |last_version|
          new_version = @db.next_version
          if to_version == nil
            to_version = new_version
          end

          @db.migrations_range(new_version, to_version, true)
        end
      end
    end

    def down(to_version=nil)
      @db.tx do
        self.exec_migrations(false) do |current_version|
          if current_version == 0
            raise VersionNotFound
          end

          if to_version == nil
            to_version = current_version
          else
            to_version = to_version.to_i + 1
          end

          @db.migrations_range(to_version, current_version, false)
        end
      end
    end

    def current_version
      @db.tx do
        return @db.current_version
      end
    end

    def delete(version)
      @db.tx do
        Log.info("Removing migration data...")

        if @db.current_version.to_i == version
          return Log.error("Cannot remove current version.")
        end

        dir = self.migration_dir(@db.get_migration(version))
        @db.delete version

        if Dir.exist? dir
          File.delete "#{dir}/up.sql"
          File.delete "#{dir}/down.sql"
          Dir.rmdir dir
        end

        Log.success("Migration data removed.")
      end
    end

    def list(select, limit)
      @db.tx do
        migrations = @db.list_migrations(select, limit)
        if not migrations.any?
          return Log.info("Migrations not found")
        end

        @db.print(migrations, "Migrations")
      end
    end
  end
end
