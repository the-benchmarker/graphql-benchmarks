## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2021-08-16
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
| ruby (2.7) | [agoo](github.com/ohler55/agoo) (2.14.0) | 138950 | **0.027** | 0.057 | 0.160 | 0.269 | 0.07 | 105 |
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 447337 | **0.028** | 0.069 | 0.176 | 0.209 | 0.11 | 320 |
| go (1.16) | [ggql](https://github.com/uhn/ggql) (1.2.12) | 201365 | **0.064** | 0.062 | 0.070 | 0.079 | 0.02 | 176 |
| go (1.16) | [ggql-i](https://github.com/uhn/ggql) (1.2.12) | 206508 | **0.064** | 0.061 | 0.070 | 0.078 | 0.02 | 253 |
| go (1.16) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.9) | 30293 | **0.082** | 0.080 | 0.090 | 0.145 | 0.03 | 378 |
| javascript (16.6.2) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (3.1.2) | 10243 | **0.145** | 0.439 | 1.158 | 1.180 | 0.56 | 95 |
| javascript (16.6.2) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (3.1.2) | 5059 | **0.187** | 0.204 | 0.214 | 0.362 | 0.24 | 97 |
| javascript (16.6.2) | [fastify-mercurius](https://github.com/mercurius-js/mercurius) (8.1.2) | 34221 | **0.197** | 0.652 | 1.868 | 1.901 | 0.87 | 74 |
| javascript (16.6.2) | [express-graphql](https://github.com/graphql/express-graphql) (0.12.0) | 4754 | **0.227** | 0.230 | 0.246 | 0.291 | 0.06 | 77 |
<!-- Result till here -->
