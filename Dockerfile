FROM ruby:3.4.3-slim AS builder

RUN apt-get update \
    && apt-get install -y \
            build-essential \
            cmake \
            git \
            libicu-dev \
            libssl-dev \
            libyaml-dev \
            pkg-config \
    && apt-get clean
COPY Gemfile* /tmp/
COPY gollum.gemspec* /tmp/
WORKDIR /tmp
RUN bundle install

RUN gem install \
    asciidoctor \
    commonmarker \
    creole \
    wikicloth \
    org-ruby \
    RedCloth \
    bibtex-ruby \
    && echo "gem-extra complete"

WORKDIR /app
COPY . /app
RUN bundle exec rake install

FROM ruby:3.4.3-slim

ARG UID=1000
ARG GID=1000

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

WORKDIR /wiki
RUN apt-get update \
    && apt-get install -y \
            bash \
            git \
            openssh-client \
    && apt-get clean \
    && groupmod -g $GID www-data \
    && usermod -u $UID -g www-data www-data \
    && mkdir -p /var/www \
    && git config --file /var/www/.gitconfig --add safe.directory /wiki \
    && chown -R www-data:www-data /var/www

COPY docker-run.sh /docker-run.sh
COPY config.rb /etc/gollum/config.rb
RUN chmod +x /docker-run.sh
USER www-data
VOLUME /wiki

ENTRYPOINT ["/docker-run.sh", "--config", "/etc/gollum/config.rb", "--css"]
