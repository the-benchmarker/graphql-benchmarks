## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2019-12-29
- OS: Linux (version: 5.4.6-050406-generic, arch: x86_64)
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
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 407242 | **0.029** | 0.058 | 0.174 | 0.185 | 0.07 | 320 |
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.4) | 180220 | **0.033** | 0.131 | 0.196 | 1.980 | 0.34 | 105 |
| go (1.13) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.8) | 29081 | **0.086** | 0.083 | 0.091 | 0.113 | 0.03 | 378 |
| javascript (12.13.1) | [express-graphql](https://github.com/graphql/express-graphql) (0.9.0) | 6830 | **0.142** | 0.145 | 0.162 | 0.183 | 0.04 | 78 |
| javascript (12.13.1) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (2.9.12) | 7582 | **0.159** | 0.177 | 0.184 | 0.377 | 0.18 | 94 |
| javascript (12.13.1) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (2.9.12) | 9556 | **0.172** | 0.320 | 0.778 | 0.782 | 0.30 | 95 |
| javascript (12.13.1) | [fastify-gql](https://github.com/mcollina/fastify-gql) (2.0.2) | 30869 | **0.188** | 0.450 | 1.180 | 1.245 | 0.52 | 90 |
<!-- Result till here -->
