# distributed-dataset

[![Documentation](https://img.shields.io/badge/-api%20documentation-informational.svg)](https://utdemir.github.io/distributed-dataset/)
[![Build Status](https://travis-ci.org/utdemir/distributed-dataset.svg?branch=master)](https://travis-ci.org/utdemir/distributed-dataset)

An experiment to create a distributed data processing framework in pure Haskell. Inspired by [Apache Spark](https://spark.apache.org/).

[An example is worth a thousand words](/examples/gh/Main.hs).

## Packages

### distributed-dataset

* Control.Distributed.Dataset

  This module provides a `Dataset` type which lets you express transformations on a distributed multiset.

  API is highly inspired from Apache Spark's RDD API. See the [example](/examples/gh/Main.hs) to get a taste.

  It uses pluggable `ShuffleStore`'s for storing intermediate compuation results. See 'distributed-dataset-aws' for an implementation using S3.

* Control.Distributed.Fork

  This module contains a `fork` function which lets you run arbitrary IO actions on remote machines; leveraging [StaticPointers language extension](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/glasgow_exts.html#static-pointers) and [distributed-closure library](https://hackage.haskell.org/package/distributed-closure).

  You can solely use this if your task is [embarrassingly parallel](https://en.wikipedia.org/wiki/Embarrassingly_parallel):

    * Load test an application by sending thousands of HTTP requests.
    * Run different iterations of a simulation in parallel.
    * Generate thumbnails for a set of images.

  It uses pluggable `Backend`s for spawning executors. See 'distributed-dataset-aws' for an implementation using AWS Lambda .

### distributed-dataset-aws

This package provides backends for 'distributed-dataset' to run using AWS services. Currently it supports running functions on AWS Lambda and using an S3 bucket as a shuffle store.

### distributed-dataset-opendatasets

Provides `Dataset`'s reading from public open datasets. Currently it can fetch GitHub event data from [GH Archive](https://www.gharchive.org).

A [Common Crawl](http://commoncrawl.org/) implementation is planned next.

## Example

See [the example](examples/gh/Main.hs).

### Running

* Make sure that you have a working [Nix](https://nixos.org/nix/) installation. 

* Make sure that you have AWS credentials set up. The easiest way is to install [AWS command line interface](https://aws.amazon.com/cli/) and to run:

```
aws configure
```

* Create a bucket on AWS to put the deployment artifact in. You can use the console or the CLI:

```
aws s3api create-bucket --bucket my-s3-bucket
```

* Optional: Use [my binary cache on Cachix](https://utdemir.cachix.org/) to reduce the amount of compilation necessary.

* Build an run the example:

```sh
$(nix-build -A example-gh)/bin/example-gh my-s3-bucket
```

## Stability

Experimental. Expect lots of missing features, bugs, instability and API changes. You will probably need to modify the source if you want to do anything serious.

### Known Bugs & Missing features & TODO

* Exceptions does not always cause the created resources to terminate.
* Sorting datasets, topN queries.
* Joins.
* Documentation.
* Nicer API for writing a 'Backend'.
* Consider using: http://hackage.haskell.org/package/aws-lambda-haskell-runtime
* Utility functions to read/write to common data stores with common data formats.

## Contributing

I am open to contributions; any issue, PR or opinion is more than welcome.

## Hacking

* I use Nix to develop. If you use `stack` or any alternative build system, I'd appreciate a PR to extend the docs.
* 'nix-shell' gives you a development shell with `cabal`, `ghcid` and `stylish-haskell`. Example:

```
$ nix-shell --pure --run 'ghcid -c "cabal new-repl distributed-dataset-opendatasets"'
```
* You can use [my binary cache on cachix](https://utdemir.cachix.org/) to make sure that you don't recompile half of the hackage.
* Use stylish-haskell and hlint:

```
nix-shell --command 'find -name "*.hs" -exec stylish-haskell -i {} \;'
nix-shell --run 'hlint .'
``` 

## See Also

* [Sparkle](https://github.com/tweag/sparkle): Run Haskell on top of Apache Spark. This is what you are looking for if you are going to do anything serious.
* [HSpark](https://github.com/yogeshsajanikar/hspark): An attempt at porting Apache Spark to Haskell.

## Related Work

* [Towards Haskell in Cloud](https://www.microsoft.com/en-us/research/publication/towards-haskell-cloud/) by Jeff Epstein, Andrew P. Black, Simon L. Peyton Jones 
* [Resilient Distributed Datasets: A Fault-Tolerant Abstraction for In-Memory Cluster Computing](https://cs.stanford.edu/~matei/papers/2012/nsdi_spark.pdf) by Matei Zaharia, et al.
