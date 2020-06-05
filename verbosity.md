## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2020-06-05
- OS: Linux (version: 5.7.0-050700-generic, arch: x86_64)
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
| javascript (12.13.1) | [fastify-gql](https://github.com/mcollina/fastify-gql) (2.0.2) | 37344 | 0.594 | 0.579 | 0.639 | 0.647 | 0.08 | **78** |
| javascript (12.13.1) | [express-graphql](https://github.com/graphql/express-graphql) (0.9.0) | 7039 | 0.139 | 0.142 | 0.160 | 0.192 | 0.04 | **78** |
| javascript (12.13.1) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (2.9.12) | 6720 | 0.158 | 0.179 | 0.186 | 0.508 | 0.18 | **94** |
| javascript (12.13.1) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (2.9.12) | 8937 | 0.754 | 0.735 | 0.803 | 0.844 | 0.10 | **95** |
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.4) | 165531 | 0.026 | 0.057 | 0.160 | 0.285 | 0.07 | **105** |
| go (1.14) | [ggql](https://gitlab.com/uhn/ggql) (1.0.0) | 193449 | 0.065 | 0.065 | 0.070 | 0.085 | 0.01 | **176** |
| go (1.14) | [ggql-i](https://gitlab.com/uhn/ggql) (1.0.0) | 200421 | 0.066 | 0.067 | 0.071 | 0.078 | 0.01 | **253** |
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 437385 | 0.027 | 0.066 | 0.174 | 0.184 | 0.09 | **320** |
| go (1.14) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.9) | 32642 | 0.076 | 0.075 | 0.086 | 0.124 | 0.03 | **378** |
<!-- Result till here -->
