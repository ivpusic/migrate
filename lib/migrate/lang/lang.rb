module Migrate
  module Lang
    class Lang
      attr_reader :ext

      def create_migration(dir)
        raise "Implementation for creating new migration not found."
      end

      def exec_migration(dir, is_up)
        raise "Implementation for executing migration not found."
      end
    end
  end
end
