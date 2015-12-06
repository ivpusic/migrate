require "pg"
require "pry"

module Migrate
  module Storage
    class Postgres < DB
      def initialize(*args)
        super
        @conn = PG.connect({
          dbname: @config.database,
          host: @config.host,
          user: @config.user,
          password: @config.password,
        })
      end

      def create_tables
        Log.info("Creating version table")
        self.exec_sql <<-eos
        CREATE TABLE #{@config.version_info}
        (
          version SERIAL PRIMARY KEY NOT NULL,
          description TEXT,
          created_date TIMESTAMP WITH TIME ZONE NOT NULL,
          last_up TIMESTAMP WITH TIME ZONE,
          last_down TIMESTAMP WITH TIME ZONE
        );
        CREATE UNIQUE INDEX #{@config.version_info}_version_uindex ON #{@config.version_info} (version);

        CREATE TABLE #{@config.version_number}
        (
          version INT PRIMARY KEY NOT NULL
        );

        INSERT INTO #{@config.version_number} VALUES(0);
        eos
        Log.success("Version table created")
      end


      def extract_version(results)
        if results && results.count > 0
          results[0]["version"]
        else
          raise VersionNotFound
        end
      end

      def exec_sql(sql)
        @tx.exec sql
      end

      def has_tx
        @tx != nil
      end

      def tx
        if has_tx
          yield
        else
          begin
            @conn.transaction do |tx|
              @tx = tx
              yield
            end
          ensure
            @tx = nil
          end
        end
      end

    end
  end
end
