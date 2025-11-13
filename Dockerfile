FROM ruby:3.4.5-alpine

RUN apk --no-cache add \
    build-base postgresql-dev nodejs yarn \
    tzdata vim openssh vips-dev yaml-dev curl

# Russian locale settings
ENV LANG ru_RU.UTF-8
# ENV LANGUAGE ru_RU.UTF-8
# ENV LC_ALL ru_RU.UTF-8

WORKDIR /tmp
RUN gem install bundler --version=2.4.10 --no-doc && \
    bundle config set force_ruby_platform true
COPY Gemfile* .
RUN bundle install

WORKDIR /usr/src
COPY . .

RUN addgroup -S app && adduser -S app -G app && \
  RUN chown -R app:app /usr/src /tmp /usr/local/bundle


USER app

EXPOSE 3000

HEALTHCHECK --interval=600s --timeout=30s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/up || exit 1

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
