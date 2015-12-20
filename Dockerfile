FROM swiftdocker/swift:latest

RUN apt-get -y update && apt-get -y install libpq-dev make git postgresql-client
COPY . /var/www/PostgreSQL-Swift
WORKDIR /var/www/PostgreSQL-Swift
RUN touch Makefile
