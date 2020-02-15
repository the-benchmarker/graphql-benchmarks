## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2020-02-15
- OS: Linux (version: 5.5.4-050504-generic, arch: x86_64)
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
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 384497 | **0.030** | 0.066 | 0.178 | 0.187 | 0.08 | 320 |
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.4) | 170435 | **0.032** | 0.068 | 0.169 | 0.305 | 0.08 | 105 |
| go (1.13) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.9) | 29627 | **0.086** | 0.086 | 0.092 | 0.164 | 0.03 | 378 |
| javascript (12.13.1) | [express-graphql](https://github.com/graphql/express-graphql) (0.9.0) | 6904 | **0.141** | 0.148 | 0.155 | 0.198 | 0.05 | 78 |
| javascript (12.13.1) | [fastify-gql](https://github.com/mcollina/fastify-gql) (2.0.2) | 35275 | **0.147** | 0.324 | 0.811 | 1.024 | 0.37 | 78 |
| javascript (12.13.1) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (2.9.12) | 7493 | **0.156** | 0.173 | 0.181 | 0.508 | 0.18 | 94 |
| javascript (12.13.1) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (2.9.12) | 9680 | **0.672** | 0.721 | 0.811 | 0.860 | 0.11 | 95 |
<!-- Result till here -->
