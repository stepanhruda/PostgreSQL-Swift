TARGET=PostgreSQL
UNAME := $(shell uname)
.PHONY: test db.migrate db.seed db.schema

default: help

help: ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrepep | sed -Ee 's/([a-z.]*):[^#]*##(.*)/\1##\2/' | sort | column -t -s "##"

ifeq ($(TRAVIS_OS_NAME),osx)
test: dependencies.travis lint db.migrate db.seed development.test
else ifeq ($(UNAME),Darwin)
test: development.setup lint development.test
else ifndef CONTAINERIZED
test: development.setup ## Run the unit tests in a Docker container against a Docker based database
	$(info running unit test containers)
	@docker-compose build test
	@docker-compose run test
else
test: lint ## (with "CONTAINERIZED=true") Run the unit tests directly
	swift build
endif

ifeq ($(UNAME),Darwin)
dependencies:
	brew tap zewo/tap
	brew install libvenice
endif

db.migrate: ## Migrate the database
	$(info migrating the database)
	sleep 5 ## give time for postgres to start up
	psql < Tests/db/migrate.sql

db.seed: ## Seed the database
	$(info seeding the database)
	psql < Tests/db/seed.sql

db.enter_console:
	psql

lint:

dependencies.travis:
	pg_ctl -D /usr/local/var/postgres start &> /dev/null
	sleep 5 ## give time for postgres to start up
	initdb -D /usr/local/pgsql/data &> /dev/null
	psql -d postgres -c 'create database travis' &> /dev/null

development.setup:
	@git apply "OS X development/docker-environment-variables.patch" &> /dev/null || true
	@docker-compose stop postgres &> /dev/null
	@docker-compose rm -v --force postgres test &> /dev/null
	@docker-compose up -d postgres
	@docker-compose build migrate && docker-compose run migrate

development.test:
	cd "OS X development" && xctool -workspace PostgreSQL.xcworkspace -scheme PostgreSQL test
