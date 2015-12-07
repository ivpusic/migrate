# migrate
[![Build Status](https://travis-ci.org/ivpusic/migrate.svg?branch=master)](https://travis-ci.org/ivpusic/migrate)

Tool for managing and executing your database migrations.

## Installation

```
gem install db-migrate
```

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

## How to use it?

##### --help
```
Commands:
  migrate init               # make configuration file
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

#### new
After that you can start generating migrations by using **migrate new** command. This will generate migration script for you based on your prefered language.

#### up
When you are done with writing your `up` and `down` migration script, you can execute **migrate up** to run up migration script for new version. You can also execute multiple migrations in single call by providing `--to n` argument, where `n` is highest version where you want to navigate.

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
