module Migrate
  module Storage
    require_relative "./storage/db"
    require_relative "./storage/postgres"
    require_relative "./storage/mysql"
  end
end
