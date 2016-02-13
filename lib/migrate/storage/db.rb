require 'terminal-table'

module Migrate
  module Storage
    class DB
      attr_reader :config

      def initialize(config)
        @config = config
      end

      def type
        @config.storage
      end

      def new_migration(version=0, description="")
        self.exec_sql <<-eos
          INSERT INTO #{@config.version_info} (version, description, created_date)
          VALUES(#{version}, '#{description}', now())
        eos

        res = self.exec_sql <<-eos
          SELECT * FROM #{@config.version_info} ORDER BY version DESC LIMIT 1
        eos
        res[0]
      end

      def list_migrations(selects, limit)
        self.exec_sql <<-eos
          SELECT #{(selects == nil ? "*" : selects)} FROM #{@config.version_info}
          ORDER BY last_up, version
          #{limit != nil ? "LIMIT #{limit}" : ""}
        eos
      end

      def migrations_range(from, to, is_up)
        self.exec_sql <<-eos
          SELECT * FROM #{@config.version_info}
            WHERE version >= #{from} AND version <= #{to}
          ORDER BY version #{!is_up ? "DESC" : ""}
          eos
      end

      def extract_version(results)
        if results && results.count > 0
          results[0]["version"]
        else
          raise VersionNotFound
        end
      end

      def lowest_version
        self.extract_version self.exec_sql <<-eos
          SELECT version FROM #{@config.version_info}
            ORDER BY version
          LIMIT 1
        eos
      end

      def highest_version
        self.extract_version self.exec_sql <<-eos
          SELECT version FROM #{@config.version_info}
            ORDER BY version DESC
          LIMIT 1
        eos
      rescue VersionNotFound => e
        0
      end

      def next_version
        self.extract_version self.exec_sql <<-eos
          SELECT version FROM #{@config.version_info}
            WHERE version > (SELECT version FROM #{@config.version_number} LIMIT 1)
          ORDER BY version
          LIMIT 1
        eos
      end

      def current_version
        self.extract_version self.exec_sql <<-eos
          SELECT * FROM #{config.version_number}
          LIMIT 1
        eos
      end

      def prev_version
        self.extract_version self.exec_sql <<-eos
          SELECT version FROM #{@config.version_info}
            WHERE version < (SELECT version FROM #{@config.version_number} LIMIT 1)
          ORDER BY version DESC
          LIMIT 1
        eos
      end

      def log_up(version)
        self.exec_sql "UPDATE #{@config.version_info} SET last_up=now() WHERE version=#{version}"
        self.exec_sql "UPDATE #{@config.version_number} SET version=#{version}"
      end

      def log_down(version)
        self.exec_sql "UPDATE #{@config.version_info} SET last_down=now() WHERE version=#{version}"

        lowest_version = self.lowest_version
        version_to_save = lowest_version.to_i < version.to_i ? self.prev_version().to_i : 0
        self.exec_sql "UPDATE #{@config.version_number} SET version=#{version_to_save}"
      end

      def get_migration(version)
        res = self.exec_sql "SELECT * FROM #{@config.version_info} WHERE version=#{version}"
        if res && res.count > 0
          res[0]
        else
          raise VersionNotFound
        end
      end

      def version_exists?(version)
        self.get_migration(version)
        true
      rescue VersionNotFound
        false
      end

      def delete(version)
        self.exec_sql "DELETE FROM #{@config.version_info} WHERE version=#{version}"
      end

      def print(results, title="")
        rows = []
        headings = results[0].keys

        results.each do |result|
          row = []
          result.each do |column, value|
            if column == "description"
              if value.length > 70
                value = value.scan(/.{1,70}/).join("\n")
              end
            end

            row << value
          end
          rows << row
        end

        table = Terminal::Table.new :headings => headings, :rows => rows
        table.title = title
        puts table
      end

      # Will create database model used by tool
      def create_tables
        raise "Implementation for creating tables not found"
      end

      def tables_exists?
        raise "Implementation for checking if version tables already exists not found"
      end

      # Executes SQL
      def exec_sql(sql)
        raise "Implementation for executing SQL script not found"
      end

      # Creates new transaction. Should accept block.
      def tx
        raise "Implementation for starting new transaction not found"
      end
    end
  end
end
