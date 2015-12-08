TARGET=elephant
.PHONY: test db.migrate db.seed db.schema

default: help

help: ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrepep | sed -Ee 's/([a-z.]*):[^#]*##(.*)/\1##\2/' | sort | column -t -s "##"

ifeq ($(TRAVIS_OS_NAME),osx)
test: dependencies.osx lint db.migrate db.seed
	cd "OS X development" && xctool -workspace Elephant.xcworkspace -scheme Elephant test
else ifndef CONTAINERIZED
test: ## Run the unit tests in a Docker container against a Docker based database
	$(info running unit test containertainers)
	@docker-compose stop data &> /dev/null
	@docker-compose rm -v --force data test &> /dev/null
	@docker-compose build test
	@docker-compose run test
else
test: lint db.migrate db.seed ## (with "CONTAINERIZED=true") Run the unit tests directly
	swift build
endif

db.migrate: ## Migrate the database
	$(info migrating the database)
	sleep 5 ## give time for postgres to start up
	psql $(DB_NAME) < db/migrate.sql

db.seed: ## Seed 		the database
	$(info seeding the database)
	psql $(DB_NAME) < db/seed.sql

db.enter_console:
	psql $(DB_NAME)

lint:

dependencies.osx:
	pg_ctl -D /usr/local/var/postgres start
	sleep 5 ## give time for postgres to start up
	initdb -D /usr/local/pgsql/data
	psql -d postgres -c 'create database travis'
