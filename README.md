# Which is the fastest GraphQL?

It's all about GraphQL server benchmarking across many languages.

Benchmarks cover maximum throughput and normal use latency. For a more
detailed description of the methodology used, the how, and the why see the
bottom of this page.

## Results

<!-- Result from here -->
Last updates: 2019-04-01

OS: Linux (version: 5.0.5-050005-generic, arch: x86_64)

CPU Cores: 4

Connections: 1000

Duration: 15 seconds

### Top 5 Ranking
|    | Requests/second | Latency (milliseconds) |
|:--:| --------------- | ---------------------- |
| :one: | agoo (ruby) | agoo (ruby) |

### Rate (requests per second)
| Language (Runtime) | Framework (Middleware) | Requests/second | Throughput (MB/sec) |
| -------------------| ---------------------- | ---------------:| -------------------:|
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.8) | 121374 | 13.61 MB/sec |

### Latency
| Language (Runtime) | Framework (Middleware) | Average | Mean | 90th percentile | 99th percentile | 99.9th percentile | Standard Deviation |
| ------------------ | ---------------------- | -------:| ----:| ---------------:| ---------------:| -----------------:| ------------------:|
| ruby (2.6) | [agoo](github.com/ohler55/agoo) (2.8) | 0.14 ms | 0.05 ms | 0.09 ms | 0.11 ms | 29.96 ms | 2.55 |
<!-- Result till here -->

## Requirements

+ [Crystal](https://crystal-lang.org) as some `built-in` tools are made in this language
+ [Ruby](https://www.ruby-lang.org) for tooling
+ [Docker](https://www.docker.com) as **frameworks** are `isolated` into _containers_
+ [perfer](https://github.com/ohler55/perfer), the benchmarking tool, `>= 1.5.1`
+ [Oj](https://github.com/ohler55/oj), needed by the benchmarking Ruby script, `>= 3.7`

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
bin/benchmarker [tools]
```

## How to contribute ?

In any way you want ...

+ Request a framework addition
+ Report a bug (on any implementation)
+ Suggest an idea
+ ...

All ideas are welcome.

## Contributors

- [Peter Ohler](https://github.com/ohler55) - Author, maintainer
- [the-benchmarker/web-frameworks](https://github.com/the-benchmarker/web-frameworks) - the original cloned source that has been modified for this repository
