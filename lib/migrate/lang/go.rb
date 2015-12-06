module Migrate
  module Lang
    class Go < Lang
      def initialize
        @ext = "go"
      end

      def create_migration(dir)
        File.open("#{dir}/up.#{@ext}", "w") do |f|
          f.puts <<-eot
package main

func main() {
    // Here goes your Go migration forward
}
          eot
        end

        File.open("#{dir}/down.#{@ext}", "w") do |f|
          f.puts <<-eot
package main

func main() {
    // Here goes your Go migration backward
}
          eot
        end
      end

      def exec_migration(dir, is_up)
        script = "#{dir}/#{is_up ? "up" : "down"}.#{@ext}"
        Log.info("Executing #{script}...")
        `go run #{script}`
      end
    end
  end
end
