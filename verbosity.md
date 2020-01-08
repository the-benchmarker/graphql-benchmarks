## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2020-01-08
- OS: Linux (version: 5.4.8-050408-generic, arch: x86_64)
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
| Language | Framework(version) | Rate | Median Latency | Average Latency | 90th % | 99th % | Std Dev | Verbosity |
| -------- | ------------------ | ----:| ------------:| ---------------:| ------:| ------:| -------:| ---------:|
| javascript (12.13.1) | [express-graphql](https://github.com/graphql/express-graphql) (0.9.0) | 6803 | 0.142 | 0.145 | 0.157 | 0.185 | 0.04 | **78** |
| javascript (12.13.1) | [fastify-gql](https://github.com/mcollina/fastify-gql) (2.0.2) | 35909 | 0.123 | 0.263 | 0.582 | 0.614 | 0.26 | **90** |
| javascript (12.13.1) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (2.9.12) | 7420 | 0.160 | 0.179 | 0.194 | 0.471 | 0.21 | **94** |
| javascript (12.13.1) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (2.9.12) | 9922 | 0.168 | 0.319 | 0.762 | 0.782 | 0.30 | **95** |
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.4) | 175252 | 0.032 | 0.103 | 0.180 | 1.014 | 0.24 | **105** |
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 403322 | 0.030 | 0.061 | 0.177 | 0.186 | 0.08 | **320** |
| go (1.13) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.8) | 28841 | 0.087 | 0.086 | 0.092 | 0.113 | 0.02 | **378** |
<!-- Result till here -->
