FROM ruby:3.2.2

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

RUN gem install rails bundler

WORKDIR $INSTALL_PATH

COPY . .

RUN bundle install

EXPOSE 3001

CMD ["rails", "server", "-p", "3001", "-b", "0.0.0.0"]
