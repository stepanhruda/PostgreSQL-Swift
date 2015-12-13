TARGET=elephant
.PHONY: test db.migrate db.seed db.schema

default: help

help: ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrepep | sed -Ee 's/([a-z.]*):[^#]*##(.*)/\1##\2/' | sort | column -t -s "##"

ifeq ($(TRAVIS_OS_NAME),osx)
test: development.setup lint
	cd "OS X development" && xctool -workspace Elephant.xcworkspace -scheme Elephant test
else ifndef CONTAINERIZED
test: development.setup ## Run the unit tests in a Docker container against a Docker based database
	$(info running unit test containertainers)
	@docker-compose build test
	@docker-compose run test
else
test: lint ## (with "CONTAINERIZED=true") Run the unit tests directly
	swift build
endif

db.migrate: ## Migrate the database
	$(info migrating the database)
	sleep 5 ## give time for postgres to start up
	psql $(DB_NAME) < Tests/db/migrate.sql

db.seed: ## Seed the database
	$(info seeding the database)
	psql $(DB_NAME) < Tests/db/seed.sql

db.enter_console:
	psql $(DB_NAME)

lint:

development.setup:
	@docker-compose up postgres
	@docker-compose run migrate
