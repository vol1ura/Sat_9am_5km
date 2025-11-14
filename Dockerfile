FROM ruby:3.4.5-alpine

RUN apk --no-cache add \
    build-base postgresql-dev nodejs yarn \
    tzdata vim openssh vips-dev yaml-dev curl

# Russian locale settings
ENV LANG ru_RU.UTF-8
# ENV LANGUAGE ru_RU.UTF-8
# ENV LC_ALL ru_RU.UTF-8

WORKDIR /tmp
RUN gem install bundler --version=2.4.10 --no-doc
COPY Gemfile* .
# Ensure the lockfile contains linux-musl and linux platforms so native gems
# (nokogiri, pg, ffi, google-protobuf, sass-embedded, etc.) are installed
# for the container architecture during image build.
RUN bundle lock --add-platform x86_64-linux-musl aarch64-linux-musl && \
  bundle install --jobs=4 --retry=3

WORKDIR /usr/src
COPY . .

RUN addgroup -S app && adduser -S app -G app && \
  RUN chown -R app:app /usr/src /tmp /usr/local/bundle


USER app

EXPOSE 3000

HEALTHCHECK --interval=600s --timeout=30s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/up || exit 1

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
