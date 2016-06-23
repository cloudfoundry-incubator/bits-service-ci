FROM ubuntu:15.10

RUN apt-get update && \
    apt-get -y install git zip unzip wget curl software-properties-common \
        libxml2-dev libxslt-dev libcurl4-openssl-dev \
        build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev && \
        apt-get clean -y && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get -y install ruby2.3 ruby2.3-dev && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc

RUN gem install bundler && \
    gem install bosh_cli -v 1.3232.0

RUN wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64.zip && \
    unzip spiff_linux_amd64.zip && mv spiff /usr/local/bin/ && rm spiff_linux_amd64.zip

RUN wget https://github.com/geofffranks/spruce/releases/download/v1.1.2/spruce-linux-amd64 -O /usr/local/bin/spruce && \
    chmod +x /usr/local/bin/spruce

ADD ./cache_cf_release_blobs.sh /tmp/cache_cf_release_blobs.sh
RUN /tmp/cache_cf_release_blobs.sh

RUN gem install \
        unf_ext:0.0.7.2 \
        msgpack:0.5.9 \
        yajl-ruby:1.2.1 \
        posix-spawn:0.3.11 \
        posix-spawn:0.3.9 \
        thin:1.6.4 \
        puma:2.16.0 \
        nokogiri:1.6.7.2 \
        nokogiri:1.6.7.1 \
        fog:1.34.0 \
        mime-types:3.0 \
        byebug:8.2.2 \
        json:1.8.3 \
        ffi:1.9.10

RUN git config --global user.email "flintstone+cibot@cloudfoundry.org" && \
    git config --global user.name "Flintstone CI"
