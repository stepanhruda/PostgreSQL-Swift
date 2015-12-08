FROM swiftdocker/swift:latest

RUN apt-get -y update && apt-get -y install libpq-dev make git
COPY Package.swift /var/www/Elephant/
COPY Sources/*.swift /var/www/Elephant/Sources/
COPY Tests/*.swift /var/www/Elephant/Tests/
WORKDIR /var/www/Elephant

