# Which is the fastest GraphQL?

It's all about GraphQL server benchmarking across many languages.

Benchmarks cover maximum throughput and normal use latency. For a more
detailed description of the methodology used, the how, and the why see the
bottom of this page.

## Results

<!-- Result from here -->
### Top 5 Ranking
|     | Requests/second |     | Latency (milliseconds) |
|:---:| --------------- |:---:| ---------------------- |
| :one: | agoo (ruby) | :one: | agoo (ruby) |

#### Parameters
- Last updates: 2019-04-02
- OS: Linux (version: 5.0.5-050005-generic, arch: x86_64)
- CPU Cores: 4
- Connections: 1000
- Duration: 15 seconds

### Rate (requests per second)
| Language (Runtime) | Framework (Middleware) | Requests/second | Throughput (MB/sec) |
| -------------------| ---------------------- | ---------------:| -------------------:|
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.8) | 131252 | 10.28 MB/sec |

### Latency
| Language (Runtime) | Framework (Middleware) | Average Latency | Mean Latency | 90th percentile | 99th percentile | 99.9th percentile | Standard Deviation |
| ------------------ | ---------------------- | -------:| ----:| ---------------:| ---------------:| -----------------:| ------------------:|
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.8) | 0.10 ms | 0.05 ms | 0.08 ms | 0.10 ms | 30.52 ms | 1.40 |
<!-- Result till here -->

## Requirements

+ [Crystal](https://crystal-lang.org) as some `built-in` tools are made in this language
+ [Ruby](https://www.ruby-lang.org) for tooling
+ [Docker](https://www.docker.com) as **frameworks** are `isolated` into _containers_
+ [perfer](https://github.com/ohler55/perfer) the benchmarking tool, `>= 1.5.1`
+ [Oj](https://github.com/ohler55/oj) is needed by the benchmarking Ruby script, `>= 3.7`

## Usage

+ Install all dependencies

```sh
shards install
```

+ Build internal tools

```sh
shards build
```

+ Build containers

> jobs are either languages (example : crystal) or frameworks (example : router.cr)

```sh
bin/neph [job1] [job2] [job3] ...
```

+ Start the benchmark ....

> tools is a list of language / framework to challenge (example : ruby kemal amber go python)

```sh
bin/benchmarker.rb [tools]
```

## How to contribute

In any way you want ...

+ Provide a Pull Request for a framework addition
+ Report a bug (on any implementation)
+ Suggest an idea
+ [More details](CONTRIBUTING.md)

All ideas are welcome.

## Contributors

- [Peter Ohler](https://github.com/ohler55) - Author, maintainer
- [the-benchmarker/web-frameworks](https://github.com/the-benchmarker/web-frameworks) - the original cloned source that has been modified for this repository
