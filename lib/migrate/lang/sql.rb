module Migrate
  module Lang
    class Sql < Lang
      def initialize(db)
        @db = db
        @ext = "sql"
      end

      def create_migration(dir)
        File.open("#{dir}/up.#{@ext}", "w") do |f|
          f.puts "-- Here goes SQL for migration forward\n"
        end

        File.open("#{dir}/down.#{@ext}", "w") do |f|
          f.puts "-- Here goes SQL for migration backward\n"
        end
      end

      def exec_migration(dir, is_up)
        script = "#{dir}/#{is_up ? "up" : "down"}.#{@ext}"
        Log.info("Executing #{script}...")
        @db.exec_sql(File.read(script))
      end
    end
  end
end
