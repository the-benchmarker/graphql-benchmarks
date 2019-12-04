'use strict'

const express = require('express')
const { ApolloServer, gql } = require('apollo-server-express')

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

const parseAppQql = (req, res, next) => {
  if (req.headers['content-type'] === 'application/graphql') {
    const body = []
    req
      .on('error', (err) => { next(err) })
      .on('data', (chunk) => { body.push(chunk) })
      .on('end', () => {
        req.body = { query: Buffer.concat(body).toString() }
        next()
      })
  } else {
    next()
  }
}

const app = express()

app.use('/graphql', parseAppQql)
server.applyMiddleware({ app })
app.get('/', (req, res) => res.send(''))
app.listen(3000, () => {
  console.log('GraphQL API server is listening at http://:3000/graphql')
})
