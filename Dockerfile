FROM phusion/passenger-ruby27
ARG precompileassets

RUN apt-get update && apt-get upgrade -y -o Dpkg::Options::="--force-confold"

RUN apt-get update && apt-get install -y curl gnupg
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN curl -q https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get -y update && \
      apt-get install --fix-missing --no-install-recommends -qq -y \
        build-essential \
        vim \
        wget gnupg \
        git-all \
        curl \
        ssh \
        tzdata \
        postgresql-client-11 libpq5 libpq-dev -y && \
      wget -qO- https://deb.nodesource.com/setup_12.x  | bash - && \
      apt-get install -y nodejs && \
      wget -qO- https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
      apt-get update && \
      apt-get install yarn

RUN apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]
EXPOSE 8443

ARG INSTALL_PATH=/opt/dockerrailsdemo
ENV INSTALL_PATH $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN gem install bundler -v 2.1.4
#Install gems
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
# RUN yarn install

COPY . .

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# COPY nginx.conf /opt/nginx/conf/nginx.conf
COPY sites.conf /etc/nginx/sites-enabled/sites.conf

RUN scripts/potential_asset_precompile.sh $precompileassets
RUN chown -R app:app $INSTALL_PATH

RUN mkdir -p /etc/my_init.d
COPY deploy-tasks.sh /etc/my_init.d/deploy-tasks.sh
RUN chmod +x /etc/my_init.d/deploy-tasks.sh