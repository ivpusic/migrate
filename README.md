# migrate
[![Build Status](https://travis-ci.org/ivpusic/migrate.svg?branch=master)](https://travis-ci.org/ivpusic/migrate)

Tool for managing and executing your database migrations.

## Installation

```
gem install db-migrate
```

If you are going to use for example Postgres with **migrate**, make sure that you have Postgresql server running.

## Demo
![img](http://i.giphy.com/26tPaeasgQYU2mCoE.gif)

## How it works?
It saves metadata about your migrations to database and uses that metadata for executing and creating new migrations.

It supports multiple databases and multiple languages for executing migrations.

#### Supported databases
- PostgreSQL
- MySQL

#### Supported languages
- SQL
- Ruby
- Python
- Javascript (Node.js)
- Go

#### Additional features
- ENV variables support in configuration file

## How to use it?

##### --help
```
Commands:
  migrate init               # initialize tables and create config file if necessary
  migrate new [DESCRIPTION]  # generate files for new migration
  migrate up                 # Upgrade database schema
  migrate down               # Downgrade database schema
  migrate list               # Show list of all migrations
  migrate delete [VERSION]   # Will delete migration data
  migrate version            # Show current version
  migrate help [COMMAND]     # Describe available commands or one specific
Options:
  -r, [--root=ROOT]      # Sepcify migration root directory, where config file is located
                         # Default: .
  -c, [--config=CONFIG]  # Specify custom configuration file name
                         # Default: migrate.conf
```

#### init
First thing you have to do is to make initial configuration with **migrate init** command.

**migrate** will look for file `migrate.conf`. If file exists, it will make configuration based on file contents.
Example configuration file:

```bash
# pg or mysql
storage=pg
# can be one of: sql, ruby, javascript, go, python
lang=sql
# db host
host=localhost
# db port
port=5432
# name of database to use
database=mydb
# db user
user=myuser
# db password
password=${SOME_ENV_VARIABLE}
# name of table where version information will be stored
version_info=version_info_table_name
# name of table where version number will be stored
version_number=version_number_table_name
```

If configuration file does not exist, it will run interactive configuration file creation process. You will answer few questions about your database, and **migrate** will create configuration file for you.

#### new
This command will generate migration scripts for you based on your prefered language.

You will get new directory in format `vXXX-YYYY`, where `XXX` is version number, and `YYY` is short description you provide. Inside generated directory there will be two files. `up.LANG` and `down.LANG`, where `LANG` is language you use for writing migration scripts.

#### up
When you are done with writing your `up` and `down` migration script, you can execute **migrate up** to run up migration script for new version.

Running `up` without arguments will move for one version up. You can also execute multiple migrations in single call by providing `--to n` argument, where `n` is highest version where you want to navigate.

If you want to run all remaining available migrations, you can pass `-a` flag to `up` command, and **migrate** will run all available migrations.

#### down
You can also use **migrate down** to go one version back. `down` comand also accepts `--to n` argument, but in this case `n` is lowest version where you want to navigate.

#### version
If you are asking yourself about current version, use **migrate version** to find out current version.

#### delete
If you don't need some migration, use **migrate delete n** to remove version `n`.

#### list
You can see list of your migrations by running **migrate list**. This command also provides some additional options for filtering results.

## Contributing
- do ruby magic
- write tests!
- send pull request

## License
*MIT*
