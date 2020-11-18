## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2020-11-17
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
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.3) | 382287 | **0.030** | 0.069 | 0.178 | 0.189 | 0.09 | 320 |
| ruby (2.7) | [agoo](github.com/ohler55/agoo) (2.14.0) | 130966 | **0.033** | 0.067 | 0.168 | 0.299 | 0.08 | 105 |
| go (1.15) | [ggql-i](https://github.com/uhn/ggql) (1.2.1) | 180850 | **0.064** | 0.060 | 0.070 | 0.079 | 0.02 | 253 |
| go (1.15) | [ggql](https://github.com/uhn/ggql) (1.2.1) | 180620 | **0.064** | 0.062 | 0.069 | 0.087 | 0.02 | 176 |
| go (1.15) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.9) | 30536 | **0.084** | 0.081 | 0.093 | 0.151 | 0.03 | 378 |
| javascript (14.15.0) | [apollo-server-fastify](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-fastify) (2.19.0) | 7611 | **0.161** | 0.349 | 0.827 | 0.852 | 0.35 | 95 |
| javascript (14.15.0) | [fastify-mercurius](https://github.com/mercurius-js/mercurius) (6.4.0) | 29783 | **0.184** | 0.637 | 1.769 | 1.901 | 0.85 | 78 |
| javascript (14.15.0) | [express-graphql](https://github.com/graphql/express-graphql) (0.11.0) | 4619 | **0.186** | 0.194 | 0.199 | 0.330 | 0.09 | 78 |
| javascript (14.15.0) | [apollo-server-express](https://github.com/apollographql/apollo-server/tree/master/packages/apollo-server-express) (2.9.12) | 4457 | **0.207** | 0.221 | 0.229 | 0.483 | 0.13 | 94 |
<!-- Result till here -->
