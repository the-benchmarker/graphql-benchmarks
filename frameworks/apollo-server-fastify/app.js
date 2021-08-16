import fastify from 'fastify'
import { ApolloServer, gql } from 'apollo-server-fastify'

const app = fastify()

async function startApolloServer() {
  const typeDefs = gql`
    type Query {
      artist(name: String!): Artist
      artists: [Artist]
    }

    type Mutation {
      like(artist: String!, song: String!): Song
    }

    type Artist {
      name: String!
      songs: [Song]
      origin: [String]
    }

    type Song {
      name: String!
      artist: Artist
      duration: Int
      release: Date
      likes: Int
    }

    scalar Date
  `

  const artists = [
    { name: 'Fazerdaze', origin: ['Morningside', 'Auckland', 'New Zealand'] },
    { name: 'Viagra Boys', origin: ['Stockholm', 'Sweden'] }
  ]

  const songs = [
    { name: 'Jennifer', artist: 'Fazerdaze', duration: 240, released: '2017-05-05T00:00:00.000Z', likes: 0 },
    { name: 'Lucky Girl', artist: 'Fazerdaze', duration: 170, released: '2017-05-05T00:00:00.000Z', likes: 0 },
    { name: 'Friends', artist: 'Fazerdaze', duration: 194, released: '2017-05-05T00:00:00.000Z', likes: 0 },
    { name: 'Reel', artist: 'Fazerdaze', duration: 193, released: '2015-11-02T00:00:00.000Z', likes: 0 },
    { name: 'Down In The Basement', artist: 'Viagra Boys', duration: 216, released: '2018-09-28T00:00:00.000Z', likes: 0 },
    { name: 'Frogstrap', artist: 'Viagra Boys', duration: 195, released: '2018-08-28T00:00:00.000Z', likes: 0 },
    { name: 'Worms', artist: 'Viagra Boys', duration: 208, released: '2018-09-28T00:00:00.000Z', likes: 0 },
    { name: 'Amphetanarchy', artist: 'Viagra Boys', duration: 346, released: '2018-09-28T00:00:00.000Z', likes: 0 }
  ]

  const resolvers = {
    Query: {
      artist: (_, { name }) => artists.find(a => name === a.name),
      artists: () => artists
    },
    Mutation: {
      like: (_, { artist, song }) => {
        const likedSong = songs.find(s => (artist === s.artist) && (song === s.name))
        if (likedSong) {
          ++likedSong.likes
        }
        return likedSong
      }
    },
    Artist: {
      songs: (artist) => songs.filter(s => s.artist === artist.name)
    },
    Song: {
      artist: (song) => songs.filter(s => s.artist === song.name)
    }
  }

  const server = new ApolloServer({
    typeDefs,
    resolvers,
    introspection: true // required for tests
  })

  // fastify does not support application/graphql parser
  if (!app.hasContentTypeParser('application/graphql')) {
    app.addContentTypeParser('application/graphql', function (req, payload, done) {
      var data = ''
      payload.on('data', function (chunk) {
        data += chunk
      })
      payload.on('end', function () {
        done(null, { query: data.replace('=', ' ') })
      })
      payload.on('error', done)
    })
  }
  await server.start()
  app
    .get('/', (request, reply) => reply.send())
    .register(server.createHandler())
    .listen(3000, '0.0.0.0')
    .then((address) => console.log(`GraphQL API server is listening at ${address}${server.graphqlPath}`))
}

startApolloServer()