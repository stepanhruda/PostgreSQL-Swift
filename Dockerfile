FROM swiftdocker/swift:latest

RUN apt-get -y update && apt-get -y install libpq-dev make git postgresql-client
RUN git clone https://github.com/Zewo/libvenice.git && cd libvenice && make && make package && dpkg -i libvenice.deb && cd .. && rm -rf /tmp/libvenice
COPY . /var/www/PostgreSQL-Swift
WORKDIR /var/www/PostgreSQL-Swift
RUN touch Makefile
