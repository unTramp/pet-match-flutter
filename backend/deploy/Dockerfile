FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

ENV DART_SUPPRESS_ANALYTICS=true

EXPOSE 8080

CMD ["dart", "run", "backend/bin/server.dart", "--host", "0.0.0.0", "--port", "8080"]
