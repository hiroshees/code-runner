FROM hiroshees/code-compiler:0.6 AS production

ENV JUDGE0_HOMEPAGE "https://codeofgenius.net/"
LABEL homepage=$JUDGE0_HOMEPAGE

ENV JUDGE0_SOURCE_CODE "https://github.com/hiroshees/code-runner"
LABEL source_code=$JUDGE0_SOURCE_CODE

ENV JUDGE0_MAINTAINER "Hiroshi Fujiwara <hiroshi.829f@gmail.com>"
LABEL maintainer=$JUDGE0_MAINTAINER

ENV PATH "/usr/local/ruby-2.7.0/bin:/opt/.gem/bin:$PATH"
ENV GEM_HOME "/opt/.gem/"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cron \
      libpq-dev \
      sudo && \
    rm -rf /var/lib/apt/lists/* && \
    echo "gem: --no-document" > /root/.gemrc && \
    gem install bundler:2.1.4 && \
    npm install -g --unsafe-perm aglio@2.3.0

ENV VIRTUAL_PORT 2358
EXPOSE $VIRTUAL_PORT

WORKDIR /api

COPY Gemfile* ./
RUN RAILS_ENV=production bundle

COPY cron /etc/cron.d
RUN cat /etc/cron.d/* | crontab -

COPY . .

ENTRYPOINT ["/api/docker-entrypoint.sh"]
CMD ["/api/scripts/server"]

ENV JUDGE0_VERSION "0.3"
LABEL version=$JUDGE0_VERSION


FROM production AS development

ARG DEV_USER=judge0
ARG DEV_USER_ID=1000

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tmux \
        vim && \
    useradd -u $DEV_USER_ID -m -r $DEV_USER && \
    echo "$DEV_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

USER $DEV_USER

CMD ["sleep", "infinity"]
