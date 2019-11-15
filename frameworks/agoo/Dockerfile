FROM ruby:2.6.5

WORKDIR /usr/src/app

COPY Gemfile app.rb song.graphql ./

RUN bundle install

EXPOSE 3000

CMD ruby app.rb
