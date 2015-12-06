require_relative "../lib/migrate"
include Migrate

Log.verbose(false)

$config_base = {
  :lang => "sql",
  :database => "migrate_test",
  :host => "localhost",
  :version_info => "version_info",
  :version_number => "version_number"
}

$pg_config_hash = $config_base.merge({
  :storage => "pg",
  :port => 5432,
  :user => "postgres",
  :password => ""
})

def load_pg_config  
  config = Conf.new("spec/lib/fixtures", "example_pg.config")
  config.init($pg_config_hash)
  config.load!
  return config
end

$mysql_config_hash = $config_base.merge({
  :storage => "mysql",
  :port => 3306,
  :user => "root",
  :password => ""
})

def load_mysql_config
  config = Conf.new("spec/lib/fixtures", "example_mysql.config")
  config.init($mysql_config_hash)
  config.load!
  return config
end

$dbs = [load_pg_config().get_db, load_mysql_config().get_db]
$version_info = $config_base[:version_info]
$version_number = $config_base[:version_number]

def load_fixtures
  drop_fixtures
  $dbs.each do |db|
    if db.has_tx
      case db.type
      when "pg"
        db.exec_sql "ALTER SEQUENCE #{$version_info}_version_seq RESTART WITH 1"
      when "mysql"
        db.exec_sql "ALTER TABLE #{$version_info} AUTO_INCREMENT = 1"
      end

      db.exec_sql "INSERT INTO #{$version_info} (created_date) VALUES (now())"
      db.exec_sql "INSERT INTO #{$version_info} (created_date) VALUES (now())"
      db.exec_sql "INSERT INTO #{$version_info} (created_date) VALUES (now())"
      db.exec_sql "INSERT INTO #{$version_info} (created_date) VALUES (now())"
      db.exec_sql "INSERT INTO #{$version_info} (created_date) VALUES (now())"
      db.exec_sql "UPDATE #{$version_number} SET version=3"
    end
  end
end

def drop_fixtures
  $dbs.each do |db|
    if db.has_tx
      db.exec_sql "DELETE FROM #{$version_info}"
    end
  end
end

def create_tables
  $dbs.each do |db|
    db.tx do
      db.create_tables
    end
  end
end

def drop_tables
  $dbs.each do |db|
    db.tx do
      db.exec_sql "DROP TABLE IF EXISTS #{$version_info}"
      db.exec_sql "DROP TABLE IF EXISTS #{$version_number}"
    end
  end
end

RSpec.configure do |config|

  config.before(:all) do
    create_tables
  end

  config.before(:each) do
    load_fixtures
  end

  config.after(:each) do
    drop_fixtures
  end

  config.after(:all) do
    drop_tables
  end
end
