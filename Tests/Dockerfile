FROM postgres:latest

RUN apt-get -y update && apt-get -y install libpq-dev
COPY . /var/www/Elephant

RUN psql --username=postgres --command="CREATE DATABASE elephant;"

