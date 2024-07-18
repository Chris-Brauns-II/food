FROM ruby:3.2.2

ENV INSTALL_PATH /app
ENV BUNDLE_WITHOUT="development:test"
RUN mkdir -p $INSTALL_PATH

RUN gem install rails bundler

WORKDIR $INSTALL_PATH

COPY . .

RUN bundle install

EXPOSE 3001

CMD ["bundle", "exec", "sidekiq", "-C", "config/local.sidekiq.yml"]
