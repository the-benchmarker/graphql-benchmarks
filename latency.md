## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2019-11-08
- OS: Linux (version: 5.3.8-050308-generic, arch: x86_64)
- CPU Cores: 12
- Connections: 1000
- Duration: 20 seconds

| [Latency](latency.md) | [Throughput](rates.md) | [Verbosity](verbosity.md) | [README](README.md) |
| --------------------- | --------------------------- | ------------------------- | ------------------- |

### Latency
| Language | Framework | Average Latency | Mean Latency | 90th percentile | 99th percentile | Standard Deviation | Req/sec | Verbosity |
| ------------------ | ---------------------- | ---------------:| ------------:| ---------------:| -----------------:| ------------------:| ------:| ------:|
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.3) | 0.14 ms | **0.03 ms** | 0.22 ms | 1.95 ms | 0.38 | 167766 | 107 |
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.2) | 0.06 ms | **0.03 ms** | 0.18 ms | 0.18 ms | 0.08 | 436071 | 345 |
| go (1.13) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.8) | 0.08 ms | **0.08 ms** | 0.09 ms | 0.10 ms | 0.03 | 30833 | 392 |
<!-- Result till here -->
