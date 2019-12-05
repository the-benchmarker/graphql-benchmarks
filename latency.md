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

### Latency
| Language | Framework(version) | Rate | Mean Latency | Average Latency | 90th % | 99th % | Std Dev | Verbosity |
| -------- | ------------------ | ----:| ------------:| ---------------:| ------:| ------:| -------:| ---------:|
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 402167 | **0.029** | 0.057 | 0.175 | 0.187 | 0.07 | 320 |
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.4) | 183832 | **0.029** | 0.157 | 0.203 | 2.486 | 0.46 | 105 |
| go (1.13) | [ggql-i](https://gitlab.com/uhn/ggql) (0.9.9) | 176773 | **0.068** | 0.067 | 0.073 | 0.083 | 0.01 | 253 |
| go (1.13) | [ggql](https://gitlab.com/uhn/ggql) (0.9.9) | 170722 | **0.068** | 0.067 | 0.073 | 0.082 | 0.01 | 176 |
| go (1.13) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.8) | 29007 | **0.087** | 0.083 | 0.093 | 0.114 | 0.03 | 378 |
| javascript (12.13.1) | [express-graphql](https://github.com/graphql/express-graphql) (0.9.0) | 6753 | **0.142** | 0.143 | 0.154 | 0.179 | 0.04 | 78 |
| javascript (12.13.1) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (2.9.12) | 9118 | **0.154** | 0.309 | 0.721 | 0.766 | 0.32 | 95 |
| javascript (12.13.1) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (2.9.12) | 7534 | **0.165** | 0.185 | 0.191 | 0.590 | 0.20 | 94 |
| javascript (12.13.1) | [fastify-gql](https://github.com/mcollina/fastify-gql) (2.0.2) | 32103 | **0.209** | 0.627 | 1.769 | 2.163 | 0.83 | 90 |
<!-- Result till here -->
