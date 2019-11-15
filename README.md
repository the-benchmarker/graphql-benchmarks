# Which is the fastest GraphQL?

It's all about GraphQL server benchmarking across many languages.

Benchmarks cover maximum throughput and normal use latency. For a more
detailed description of the methodology used, the how, and the why see the
bottom of this page.

## Results

<!-- Result from here -->
### Top 5 Ranking
|     | Rate | Latency | Verbosity |
|:---:| ---- | ------- | --------- |
| :one: | agoo-c (c) | agoo-c (c) | agoo (ruby) |
| :two: | agoo (ruby) | agoo (ruby) | agoo-c (c) |
| :three: | graphql-go (go) | graphql-go (go) | graphql-go (go) |

#### Parameters
- Last updated: 2019-11-09
- OS: Linux (version: 5.3.8-050308-generic, arch: x86_64)
- CPU Cores: 12
- Connections: 1000
- Duration: 20 seconds

| [Rate](rates.md) | [Latency](latency.md) | [Verbosity](verbosity.md) | [README](README.md) |
| ---------------- | --------------------- | ------------------------- | ------------------- |
<!-- Result till here -->

## Requirements

+ [Ruby](https://www.ruby-lang.org) for tooling
+ [Docker](https://www.docker.com) as **frameworks** are `isolated` into _containers_
+ [perfer](https://github.com/ohler55/perfer) the benchmarking tool, `>= 1.5.3`
+ [Oj](https://github.com/ohler55/oj) is needed by the benchmarking Ruby script, `>= 3.7`
+ [RSpec](https://rubygems.org/gems/rspec) is needed for testing

## Usage

+ Install all dependencies, Ruby, Docker, Perfer, Oj, and RSpec.

+ Build containers

> build all

```sh
build.rb
```

> build just named targets

```sh
build.rb [target] [target] ...
```

+ Runs the tests (optional)

```sh
rspec spec.rb
```

+ Run the benchmarks

> frameworks is an options list of frameworks or languages run (example: ruby agoo-c)

```sh
benchmarker.rb [frameworks...]
```

## Methodology

Performance of a framework includes latency and maximum number of requests
that can be handled in a span of time. The assumption is that users of a
framework will choose to run at somewhat less that fully loaded. Running fully
loaded would leave no room for a spike in usage. With that in mind, the
maximum number of requests per second will serve as the upper limit for a
framework.

Latency tends to vary significantly not only radomly but according to the
load. A typical latency versus throughput curve starts at some low-load value
and stays fairly flat in the normal load region until some inflection
point. At the inflection point until the maximum throughput the latency
increases.

```
 |                                                                  *
 |                                                              ****
 |                                                          ****
 |                                                      ****
 |******************************************************
 +---------------------------------------------------------------------
  ^               \             /                       ^           ^
  low-load          normal-load                         inflection  max
```

These benchmarks show the normal-load latency as that is what most users will
see when using a service. Most deployments do not run at near maximum
throughput but try to stay in the normal-load are but are prepared for spike
in usage. To accomdate slower frameworks a value of 1000 request per second is
used for determing the mean latency. The assumption is that a rate of 1000
request per second falls in the normal range for most if not all frameworks
tested.

The `perfer` benchmarking tool is used for these reasons:

- A rate can be specified for latency determination.
- JSON output makes parsing output easier.
- Fewer threads are needed by `perfer` leaving more for the application being benchmarked.
- `perfer` is faster than `wrk` albeit only slightly

## How to Contribute

In any way you want ...

+ Provide a Pull Request for a framework addition
+ Report a bug (on any implementation)
+ Suggest an idea
+ [More details](CONTRIBUTING.md)

All ideas are welcome.

## Contributors

- [Peter Ohler](https://github.com/ohler55) - Author, maintainer
- [the-benchmarker/web-frameworks](https://github.com/the-benchmarker/web-frameworks) - the original cloned source that has been modified for this repository
