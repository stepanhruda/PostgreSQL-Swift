TARGET=elephant
.PHONY: test db.migrate db.seed db.schema

default: help

help: ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrepep | sed -Ee 's/([a-z.]*):[^#]*##(.*)/\1##\2/' | sort | column -t -s "##"

ifndef CONTAINERIZED
test: ## Run the unit tests in a Docker container against a Docker based database
	$(info running unit test containertainers)
	@docker-compose stop data &> /dev/null
	@docker-compose rm -v --force data test &> /dev/null
	@docker-compose build test
	@docker-compose run test
else
test: lint db.migrate db.seed ## (with "CONTAINERIZED=true") Run the unit tests directly via go
	godep 	go test $(LDFLAGS) -cover ./...
endif

db.migrate: ## Migrate the database
	$(info migrating the database)
	psql $(DB_NAME) < db/migrate.sql

db.seed: ## Seed 		the database
	$(info seeding the database)
	PGPASSWORD=$(DB_PASSWORD) psql -h $(DB_HOST) -p $(DB_PORT) -U $(DB_USER) $(DB_NAME) < db/seed.sql

db.schema: ## Dump the database schema
	PGPASSWORD=$(DB_PASSWORD) pg_dump -s -x -h $(DB_HOSTOST) -p $(DB_PORT) -U $(DB_USER) $(DB_NAME)

db.enter_console:
	PGPASSWORDWORD=$(DB_PASSWORD) psql -h $(DB_HOST) -p $(DB_PORT) -U $(DB_USER) $(DB_NAME)

lint:

