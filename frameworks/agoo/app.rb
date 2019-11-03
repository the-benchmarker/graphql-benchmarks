# frozen_string_literal: true

require 'etc'
require 'agoo'

# worker_count must be set to 1 for state preservation on the mutation calls.
worker_count = Etc.nprocessors() / 3
worker_count = 1 if worker_count < 1
Agoo::Server.init(3000, '.', thread_count: 2, worker_count: worker_count, graphql: '/graphql', poll_timeout: 0.01)

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
  def initialize
    @like_count = 0
    @lock = Mutex.new
  end
  def like(args={})
    @lock.synchronize { @like_count += 1 }
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
  "Increment the like-count and return the new value."
  like: Int
}
^)
}

sleep
