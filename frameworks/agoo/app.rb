# frozen_string_literal: true

require 'etc'

require 'date'
require 'agoo'

# worker_count must be set to 1 for state preservation on the mutation
# calls. If data is stored in a centralized store such as a database then
# multiple workers are fine. Multiple worker are fine for query only
# APIs. Most real world applications will use an external store, multiple
# workers would make more sense this benchmark test. Flip the flag to change
# the test.

# Uncomment for multiple workers and then comment out the following init call.
#worker_count = Etc.nprocessors() / 3
#worker_count = 1 if worker_count < 1
#Agoo::Server.init(3000, '.', thread_count: 2, worker_count: worker_count, graphql: '/graphql', poll_timeout: 0.1)

Agoo::Server.init(3000, '.', thread_count: 2, worker_count: 1, graphql: '/graphql', poll_timeout: 0.01)

# Empty response.
class Empty
  def self.call(_req)
    [200, {}, []]
  end

  def static?
    true
  end
end

# Implement the Ruby classes to support the API. The GraphQL type and Ruby
# class names are the same in this example to make it easier to follow.
class Artist
  attr_reader :name
  attr_reader :songs
  attr_reader :origin

  def initialize(name, origin)
    @name = name
    @songs = []
    @origin = origin
  end

  def song(args={})
    n = args['name']
    @songs.each { |s| return s if n = s.name }
    nil
  end

end

class Song
  attr_reader :name     # string
  attr_reader :artist   # reference
  attr_reader :duration # integer
  attr_reader :release  # date
  attr_accessor :likes  # integer

  def initialize(name, artist, duration, release)
    @name = name
    @artist = artist
    @duration = duration
    @release = release
    @likes = 0
    artist.songs << self
  end
end

# This is the class that implements the root query operation.
class Query
  attr_reader :artists

  def initialize(artists)
    @artists = artists
  end

  def artist(args={})
    n = args['name']
    @artists.each { |a| return a if n = a.name }
    nil
  end
end

class Mutation
  def initialize(artists)
    @artists = artists
    @lock = Mutex.new
  end

  def like(args={})
    an = args['artist']
    sn = args['song']
    @artists.each {|a|
      if an == a.name
	a.songs.each { |s|
	  if s.name == sn
	    @lock.synchronize { s.likes += 1 }
	    return s
	  end
	}
      end
    }
    nil
  end

end

class Schema
  attr_reader :query
  attr_reader :mutation

  def initialize(query)
    @query = query
    @mutation = Mutation.new(query.artists)
  end
end

# Populate the library.
fazerdaze = Artist.new('Fazerdaze', ['Morningside', 'Auckland', 'New Zealand'])
Song.new('Jennifer', fazerdaze, 240, Date.new(2017, 5, 5))
Song.new('Lucky Girl', fazerdaze, 170, Date.new(2017, 5, 5))
Song.new('Friends', fazerdaze, 194, Date.new(2017, 5, 5))
Song.new('Reel', fazerdaze, 193, Date.new(2015, 11, 2))

boys = Artist.new('Viagra Boys', ['Stockholm', 'Sweden'])
Song.new('Down In The Basement', boys, 216, Date.new(2018, 9, 28))
Song.new('Frogstrap', boys, 195, Date.new(2018, 9, 28))
Song.new('Worms', boys, 208, Date.new(2018, 9, 28))
Song.new('Amphetanarchy', boys, 346, Date.new(2018, 9, 28))

$schema = Schema.new(Query.new([fazerdaze, boys]))

Agoo::Server.handle(:GET, '/', Empty)

Agoo::Server.start
Agoo::GraphQL.schema($schema) {Agoo::GraphQL.load_file('song.graphql')}

sleep

#http://localhost:6464/graphql?query={artists{name,origin,songs{name,duration,likes}},__schema{types{name,kind,fields{name}}}}
