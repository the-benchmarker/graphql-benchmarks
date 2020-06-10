## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2020-06-10
- OS: Linux (version: 5.7.1-050701-generic, arch: x86_64)
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
| Language | Framework(version) | Rate | Median Latency | Average Latency | 90th % | 99th % | Std Dev | Verbosity |
| -------- | ------------------ | ----:| ------------:| ---------------:| ------:| ------:| -------:| ---------:|
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 442020 | **0.026** | 0.064 | 0.174 | 0.183 | 0.09 | 320 |
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.4) | 159428 | **0.026** | 0.055 | 0.158 | 0.270 | 0.07 | 105 |
| go (1.14) | [ggql-i](https://github.com/uhn/ggql) (1.0.0) | 205058 | **0.062** | 0.060 | 0.068 | 0.088 | 0.02 | 253 |
| go (1.14) | [ggql](https://github.com/uhn/ggql) (1.0.0) | 201986 | **0.062** | 0.057 | 0.066 | 0.073 | 0.02 | 176 |
| go (1.14) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.9) | 32843 | **0.078** | 0.075 | 0.086 | 0.102 | 0.03 | 378 |
| javascript (12.13.1) | [express-graphql](https://github.com/graphql/express-graphql) (0.9.0) | 7205 | **0.101** | 0.109 | 0.115 | 0.146 | 0.05 | 78 |
| javascript (12.13.1) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (2.9.12) | 6872 | **0.155** | 0.173 | 0.179 | 0.362 | 0.17 | 94 |
| javascript (12.13.1) | [fastify-gql](https://github.com/mcollina/fastify-gql) (2.0.2) | 37167 | **0.604** | 0.589 | 0.647 | 0.664 | 0.07 | 78 |
| javascript (12.13.1) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (2.9.12) | 8910 | **0.651** | 0.697 | 0.774 | 0.799 | 0.09 | 95 |
<!-- Result till here -->
