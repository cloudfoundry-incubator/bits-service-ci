FROM flintstonecf/ci:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
                    libpq-dev \
                    libmysql++-dev \
                    mysql-server && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mysql_install_db
RUN service mysql start; sleep 10 && /usr/bin/mysqladmin -u root password 'password'

RUN gem install \
    http_parser.rb:0.6.0 \
    msgpack:0.5.9 \
    mysql2:0.3.20 \
    pg:0.16.0 \
    posix-spawn:0.3.11 \
    unf_ext:0.0.6 \
    vmstat:2.1.0 \
    ruby-debug-ide:0.5.0 \
    nokogiri:1.6.7.2 \
    fog:1.34.0 \
    byebug:4.0.5 \
    thin:1.6.4 \
    json:1.8.3 \
    eventmachine:1.0.8 \
    yajl-ruby:1.2.1 \
    --no-rdoc --no-ri
