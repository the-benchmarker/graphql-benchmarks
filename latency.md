## Results

<!-- Result from here -->

#### Parameters
- Last updated: 2019-11-09
- OS: Linux (version: 5.3.8-050308-generic, arch: x86_64)
- CPU Cores: 12
- Connections: 1000
- Duration: 20 seconds

| [Rate](rates.md) | [Latency](latency.md) | [Verbosity](verbosity.md) | [README](README.md) |
| ---------------- | --------------------- | ------------------------- | ------------------- |

### Latency
| Language | Framework | Mean (msecs) | Latency (msecs) Aver / 90th % / 99th % | StdDev | Req/sec | Verbosity |
| ------------------ | ---------------------- | ---------------:| -----------------:| ------------------:| ------:| ------:|
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.11.3) | **0.028** | 0.143/0.329/1.396 | 0.34 | 175276 | 107 |
| c (11) | [agoo-c](github.com/ohler55/agoo-c) (0.7.2) | **0.029** | 0.059/0.175/0.185 | 0.08 | 434214 | 345 |
| go (1.13) | [graphql-go](https://github.com/graphql-go/graphql) (0.7.8) | **0.084** | 0.081/0.090/0.108 | 0.03 | 30869 | 392 |
<!-- Result till here -->
