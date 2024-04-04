FROM ruby:3.0

WORKDIR /app

RUN gem install bundler

# Copy the examples into the image and install deps.
COPY examples/ ./examples/
RUN cd ./examples/hello-world && bundle install

# From this point forward, we're operating on the example app.
WORKDIR /app/examples/hello-world
CMD ["ruby", "app.rb"]
