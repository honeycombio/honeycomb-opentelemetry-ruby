FROM ruby:3.0

WORKDIR /app

RUN gem install bundler

COPY honeycomb-opentelemetry.gemspec ./
COPY lib ./lib

# Copy the examples into the image and install deps.
RUN mkdir examples
COPY examples/sinatra/ ./examples/sinatra/
RUN cd ./examples/sinatra && bundle install

# From this point forward, we're operating on the example app.
WORKDIR /app/examples/sinatra
CMD ["bundle", "exec", "ruby", "app.rb"]
