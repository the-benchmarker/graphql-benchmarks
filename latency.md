## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2020-01-19
- OS: Linux (version: 5.4.13-050413-generic, arch: x86_64)
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
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 409031 | **0.028** | 0.053 | 0.172 | 0.183 | 0.10 | 320 |
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.4) | 171028 | **0.034** | 0.111 | 0.185 | 1.132 | 0.25 | 105 |
| go (1.13) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.8) | 28822 | **0.086** | 0.082 | 0.090 | 0.115 | 0.03 | 378 |
| javascript (12.13.1) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (2.9.12) | 7499 | **0.128** | 0.148 | 0.169 | 0.410 | 0.18 | 94 |
| javascript (12.13.1) | [express-graphql](https://github.com/graphql/express-graphql) (0.9.0) | 6846 | **0.139** | 0.140 | 0.157 | 0.183 | 0.04 | 78 |
| javascript (12.13.1) | [fastify-gql](https://github.com/mcollina/fastify-gql) (2.0.2) | 35693 | **0.147** | 0.310 | 0.725 | 0.782 | 0.31 | 78 |
| javascript (12.13.1) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (2.9.12) | 9497 | **0.164** | 0.331 | 0.758 | 0.762 | 0.31 | 95 |
<!-- Result till here -->
