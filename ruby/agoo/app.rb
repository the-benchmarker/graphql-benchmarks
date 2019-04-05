# frozen_string_literal: true

require 'etc'
require 'agoo'

worker_count = Etc.nprocessors() * 3
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
  def hello(args={})
    'Hello ' + args['name'].to_s
  end
end

class Mutation
  def double(args={})
    args['number'] * 2
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
  hello(name: String!): String
}
type Mutation {
  "Double the number provided."
  double(number: Int!): Int
}
^)
}

sleep
