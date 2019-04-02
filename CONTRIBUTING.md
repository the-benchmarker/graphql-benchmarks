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
  hello(name: String!): String
}
type Mutation {
  repeat(word: String!): String
}
```

### Root GET

When set an HTTP request:

 - Method: GET
 - Route: `/`
 - Request Body: _none_

An example using `curl` is `curl 172.17.0.2:3000`

Must respond with:

 - Status Code: `200`
 - Response Body: _empty_


### GraphQL Query using GET

When set an HTTP request:

 - Method: GET
 - Route: `/graphql?query={hello(name:"World")}`
 - Request Body: _none_

An example using `curl` is `curl '172.17.0.2:3000/graphql?query=\{hello(name:"World")\}'`

Must respond with:

 - Status Code: `200`
 - Response Body: `{"data":{"hello":"Hello World"}}`
 - Header Check for: `Content-Type: application/json`

The returned second word of the returned string must match the word provided
in the route. IN the example it is "World".

### GraphQL Mutation using POST

When set an HTTP request:

 - Method: POST
 - Route: `/graphql`
 - Request Body: `mutation{repeat(word:"GraphQL")}`
 - Header: `Content-Type: application/graphql`

An example using `curl` is `curl -H 'Content-Type: application/graphql' -d 'mutation {repeat(word:"GraphQL")}' 172.17.0.2:3000/graphql`

Must respond with:

 - Status Code: `200`
 - Response Body: `{"data":{"repeat":"GraphQL"}}`
 - Header Check for: `Content-Type: application/json`

The returned word must match the word in the returned JSON response. In the
example it is "GraphQL".

+ All framework **MUST** contain a `Dockerfile`

+ All framework **MUST** be referenced in :
   + `FRAMEWORKS.yml`, a description of each framework
   + `neph.yaml`, a target group for the language, and a target for the framework
