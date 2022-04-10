FROM ruby:3.1.1 AS builder

WORKDIR /app
COPY Gemfile Gemfile.lock verokrypto.gemspec ./

RUN bundle install
COPY . .
RUN rake
RUN rake build
RUN ls pkg

FROM ruby:3.1.1

COPY --from=builder /app/pkg/*.gem /tmp
RUN gem install /tmp/*.gem && rm /tmp/*.gem
ENTRYPOINT [ "/usr/local/bundle/bin/verokrypto" ]