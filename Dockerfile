FROM swiftdocker/swift:latest

RUN apt-get -y update && apt-get -y install libpq-dev make git postgresql-client
COPY . /var/www/Elephant
WORKDIR /var/www/Elephant
RUN touch Makefile
