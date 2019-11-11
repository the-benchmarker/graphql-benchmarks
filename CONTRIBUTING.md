## How to contribute

Contributions of any kind a :heart: accepted

+ Adding new frameworks
+ Fix some frameworks
+ Update dependencies
+ Discuss best practices

## Adding a framework

+ All frameworks **MUST** follow these rules:

### GraphQL Schema

The GraphQL schema for the benchmarks requests assumes this schema:

```graphql
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
```

### GraphQL Query using GET

When set an HTTP request:

 - Method: GET
 - Route: `/graphql?query={artists{name,origin,songs{name,duration,likes}},__schema{types{name,fields{name}}}}`
 - Request Body: _none_

An example using `curl` is `curl '172.17.0.2:3000/graphql?query=\{artists\{name,origin,songs\{name,duration,likes\}\},__schema\{types\{name,fields\{name\}\}\}\}'`

Must respond with:

 - Status Code: `200`
 - Response Body: A JSON body that passes the rspec `spec.rb` tests. A passing example is [here](response.json)
 - Header Check for: `Content-Type: application/json`

The JSON can be formatted with or without indentation. Order of the
object elements is not considered.

### GraphQL Mutation using POST

When set an HTTP request:

 - Method: POST
 - Route: `/graphql`
 - Request Body: `mutation{like(artist:"Fazerdaze",song:"Jennifer"){likes}}`
 - Header: `Content-Type: application/graphql`

An example using `curl` is `curl -H 'Content-Type: application/graphql' -d 'mutation{like(artist:"Fazerdaze",song:"Jennifer"){likes}}' 172.17.0.2:3000/graphql`

Must respond with:

 - Status Code: `200`
 - Response Body: `{"data":{"like":{"likes":3}}}`
 - Header Check for: `Content-Type: application/json`

The returned value must be one more than the previous returned value
and is the number of times the mutation has been called since
starting.

+ All framework **MUST** contain a `Dockerfile`

+ All framework **MUST** contain a `info.yml`

The `info.yml` file should must have these fields but with the values
in between the `<` and `>` replaced with appropriate values.

name: <frameowrk name>
website: <github.com/<account>/<framework>
version: <version>
language: <language>
language-version: <language version>
bench-adjust: 0.5
experimental: false
post-format: graphql
code: <source files separated by commas>

The bench-adjust value default to 1.0. Experiment with it. 0.5 works
well for most frameworks.
