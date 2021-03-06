require 'mysql2'

module Migrate
  module Storage
    class Mysql < DB
      def initialize(*args)
        super
        @conn = Mysql2::Client.new(
          :database => @config.database,
          :host => @config.host,
          :port => @config.port,
          :username => @config.user,
          :password => @config.password,
        )
      end

      def create_tables
        Log.info("Creating version table")
        self.exec_sql <<-eos
        CREATE TABLE #{@config.version_info}
        (
          version INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
          description TEXT,
          created_date TIMESTAMP NOT NULL,
          last_up TIMESTAMP NULL,
          last_down TIMESTAMP NULL
        );
        eos

        self.exec_sql <<-eos
        CREATE TABLE #{@config.version_number} (
          version int(11) not null,
          PRIMARY KEY (version)
        );
        eos

        self.exec_sql <<-eos
        INSERT INTO #{@config.version_number} VALUES(0);
        eos
        Log.success("Version table created")
      end

      def tables_exists?
        vi = self.exec_sql("SHOW TABLES LIKE '#{@config.version_info}'")
        vn = self.exec_sql("SHOW TABLES LIKE '#{@config.version_number}'")

        vi.length > 0 && vn.length > 0
      end

      def exec_sql(sql)
        results = []
        result = @tx.query sql
        return [] if result == nil

        result.each do |row|
          results << row
        end
      end

      def has_tx
        @tx != nil
      end

      def tx
        if has_tx
          yield
        else
          begin
            @conn.query "BEGIN;"
            @tx = @conn
            yield
            @conn.query "COMMIT;"
          rescue Exception => e
            @conn.query "ROLLBACK;"
            raise e
          ensure
            @tx = nil
          end
        end
      end

    end
  end
end
