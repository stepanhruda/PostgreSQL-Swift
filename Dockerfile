FROM swiftdocker/swift:latest

RUN apt-get -y update && apt-get -y install libpq-dev make git
COPY Package.swift /var/www/Elephant/
COPY Source/*.swift /var/www/Elephant/Source/
COPY Tests/*.swift /var/www/Elephant/Tests/
WORKDIR /var/www/Elephant

