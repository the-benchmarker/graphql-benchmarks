# frozen_string_literal: true

require 'agoo'

Agoo::Log.configure(dir: '',
                    console: true,
                    classic: true,
                    colorize: true,
                    states: {
                      INFO: false,
                      DEBUG: false,
                      connect: false,
                      request: false,
                      response: false,
                      eval: false,
                      push: false
                    })

worker_count = 4
worker_count = ENV['AGOO_WORKER_COUNT'].to_i if ENV.key?('AGOO_WORKER_COUNT')
Agoo::Server.init(3000, '.', thread_count: 1, worker_count: worker_count, graphql: '/graphql')

# Empty response.
class Empty
  def self.call(_req)
    [200, {}, []]
  end

  def static?
    true
  end
end

class Query
  def hello
    'Hello'
  end
end

class Mutation
  def initialize
    @last = 'Hello'
  end

  def repeat(args={})
    @last = args['word']
  end
end

class Schema
  attr_reader :query
  attr_reader :mutation

  def initialize
    @query = Query.new()
    @mutation = Mutation.new()
  end
end

Agoo::Server.handle(:GET, '/', Empty)

Agoo::Server.start
Agoo::GraphQL.schema(Schema.new) {
  Agoo::GraphQL.load(%^
type Query {
  hello: String
}
type Mutation {
  repeat(word: String): String
}
^)
}

sleep
