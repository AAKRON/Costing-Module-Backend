  FROM ruby:2.7.7

  # Install docker
  RUN apt-get update && apt-get install -y postgresql-client

  WORKDIR /app
  COPY Gemfile* .
  RUN bundle install
  COPY . .
  EXPOSE 3000
  CMD ["rails", "server", "-b", "0.0.0.0"]