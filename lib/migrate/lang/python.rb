module Migrate
  module Lang
    class Python < Lang
      def initialize
        @ext = "py"
      end

      def create_migration(dir)
        File.open("#{dir}/up.#{@ext}", "w") do |f|
          f.puts "# Here goes Python code for migration forward\n"
        end

        File.open("#{dir}/down.#{@ext}", "w") do |f|
          f.puts "# Here goes Python code for migration backward\n"
        end
      end

      def exec_migration(dir, is_up)
        script = "#{dir}/#{is_up ? "up" : "down"}.#{@ext}"
        Log.info("Executing #{script}...")
        `python #{script}`
      end
    end
  end
end
