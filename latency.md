## Results

<!-- Result from here -->

#### Parameters
- Last updates: 2019-11-07
- OS: Linux (version: 5.3.8-050308-generic, arch: x86_64)
- CPU Cores: 12
- Connections: 1000
- Duration: 20 seconds

| [Latency](latency.md) | [Throughput](throughput.md) | [Verbosity](verbosity.md) | [README](README.md) |
| --------------------- | --------------------------- | ------------------------- | ------------------- |

### Latency
| Language (Runtime) | Framework (Middleware) | Average Latency | Mean Latency | 90th percentile | 99th percentile | 99.9th percentile | Standard Deviation |
| ------------------ | ---------------------- | ---------------:| ------------:| ---------------:| ---------------:| -----------------:| ------------------:|
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.2) | 0.06 ms | **0.03 ms** | 0.18 ms | 0.18 ms | 1.01 ms | 0.12 |
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.3) | 0.16 ms | **0.03 ms** | 0.33 ms | 1.96 ms | 3.01 ms | 0.38 |
| go (1.13) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.8) | 0.08 ms | **0.08 ms** | 0.09 ms | 0.11 ms | 0.36 ms | 0.02 |
<!-- Result till here -->
