## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2019-12-05
- OS: Linux (version: 5.4.0-050400-generic, arch: x86_64)
- CPU Cores: 12
- Connections: 1000
- Duration: 20 seconds
- Units:
  - _Rates_ are in requests per second.
  - _Latency_ is in milliseconds.
  - _Verbosity_ is the number of non-blank lines of code excluding comments.

| [Rate](rates.md) | [Latency](latency.md) | [Verbosity](verbosity.md) | [README](README.md) |
| ---------------- | --------------------- | ------------------------- | ------------------- |

### Verbosity
| Language | Framework(version) | Rate | Mean Latency | Average Latency | 90th % | 99th % | Std Dev | Verbosity |
| -------- | ------------------ | ----:| ------------:| ---------------:| ------:| ------:| -------:| ---------:|
| javascript (12.13.1) | [express-graphql](https://github.com/graphql/express-graphql) (0.9.0) | 6745 | 0.145 | 0.152 | 0.166 | 0.186 | 0.05 | **78** |
| javascript (12.13.1) | [fastify-gql](https://github.com/mcollina/fastify-gql) (2.0.2) | 31076 | 0.214 | 0.767 | 2.097 | 2.359 | 1.04 | **90** |
| javascript (12.13.1) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (2.9.12) | 7469 | 0.161 | 0.186 | 0.186 | 0.672 | 0.24 | **94** |
| javascript (12.13.1) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (2.9.12) | 9763 | 0.155 | 0.318 | 0.754 | 0.762 | 0.31 | **95** |
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.4) | 183064 | 0.032 | 0.141 | 0.210 | 1.956 | 0.35 | **105** |
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 406736 | 0.029 | 0.057 | 0.175 | 0.184 | 0.07 | **320** |
| go (1.13) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.8) | 29069 | 0.086 | 0.084 | 0.092 | 0.106 | 0.03 | **378** |
<!-- Result till here -->
