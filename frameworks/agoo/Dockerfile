FROM ruby:2.6.2

WORKDIR /usr/src/app

COPY Gemfile app.rb ./

RUN bundle install

EXPOSE 3000

CMD ruby app.rb
