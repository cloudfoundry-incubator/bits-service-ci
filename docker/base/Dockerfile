FROM ubuntu:trusty

RUN apt-get update && \
    apt-get -y install git zip unzip wget curl dnsutils gettext software-properties-common \
        libxml2-dev libxslt-dev libcurl4-openssl-dev \
        build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev && \
        apt-get clean -y && \
        apt-get autoremove -y && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get -y install ruby2.4 ruby2.4-dev && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "gem: --no-rdoc --no-ri" > ~/.gemrc

# sticking this to 1.17.1 because our bits-service-client gem doesn't work with bundler 2.x yet
# we don't want to upgrade the gem yet, because cloud controller also still on 1.x
RUN gem install bundler -v 1.17.1

RUN wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64.zip && \
    unzip spiff_linux_amd64.zip && mv spiff /usr/local/bin/ && rm spiff_linux_amd64.zip

RUN wget https://github.com/geofffranks/spruce/releases/download/v1.11.0/spruce-linux-amd64 -O /usr/local/bin/spruce && \
    chmod +x /usr/local/bin/spruce

RUN curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" | tar -zx && mv cf /usr/local/bin

RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/local/bin/jq && chmod +x /usr/local/bin/jq

RUN wget https://storage.googleapis.com/golang/go1.10.1.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.10.1.linux-amd64.tar.gz
ENV PATH "$PATH:/usr/local/go/bin"

RUN add-apt-repository --yes ppa:masterminds/glide && apt-get update
RUN apt-get -y install glide

RUN wget -O - https://downloads.opvis.bluemix.net:5443/client/IBM_Logmet_repo_install.sh | bash
RUN apt-get -y install collectd collectd-write-mtlumberjack ibmcloud-monitoring netcat socat

RUN gem install \
        unf_ext:0.0.7.2 \
        msgpack:1.1.0 \
        yajl-ruby:1.3.1 \
        posix-spawn:0.3.11 \
        posix-spawn:0.3.9 \
        thin:1.6.4 \
        puma:2.16.0 \
        nokogiri:1.6.7.2 \
        nokogiri:1.6.7.1 \
        fog:1.34.0 \
        mime-types:3.0 \
        byebug:8.2.2 \
        json:2.1.0 \
        ffi:1.9.14

RUN git config --global user.email "flintstone+cibot@cloudfoundry.org" && \
    git config --global user.name "Flintstone CI"

RUN wget https://github.com/cloudfoundry/bosh-cli/releases/download/v5.3.1/bosh-cli-5.3.1-linux-amd64 -O /usr/local/bin/bosh && \
    chmod +x /usr/local/bin/bosh && ln -s /usr/local/bin/bosh /usr/local/bin/bosh2
