# Bench::Hero

This repo helps to collect metadata over complex benchmarking scenarios using [tsbs](https://github.com/timescale/tsbs).

It pipes benchmark results data to a TimescaleDB, adding machine specs used in the benchmark.

This project is in thevery early stages. Convenient features:

- [x] Track tsbs client and db server hardware specs
- [x] Save benchmark with client and server specs
- [ ] Track db engine specs (version and configuration parameters)
- [ ] Orchestrates a plan for multiple runs (parameters optimization) over a
    single target
- [ ] Orchestrate a plan for multiple runs with several targets (start and stop
    services on demand)


## Usage

```
git clone git@github.com/jonatas/bench-hero.git
cd bench-hero
bundle install
```

## Setup the benchmark database

The most important objective of this project is store benchmark results in a
long term. Allowing us to better understand the evolutions between versions and
compare benchmarks running in different hardware scenarios.

### Configure `.env`

Create a `.env` file in the root of the project with a new TimescaleDB instance
to save the benchmark results.

You can setup a micro instance of [Timescale for free](https://www.timescale.com/timescale-signup)
and use the PG_URI here if necessary.

```
PG_URI="postgres://<user>:<password>@<host>:<port>/tsdb?sslmode=require"
```

### Configure `/etc/hosts`

To avoid pulling and pushing IPs as remote references, let's name `bench` the
database machine and `tsbs` the client that will push the workload to the `bench`.

```
<some-ip-here> bench
<some-ip-here> tsbs
```

### `bin/setup_benchmark_results_database`

Use it once to create the necessary tables structure. It includes the following
tables:

* `benchmark_results` for storing results of each benchmark and what machine was
    used as client and server.
* `benchmark_machines` for storing hardware metadata.

The plan is to also add `benchmark_machine_stats` to track cpu/mem/io allocation
during the benchmark :wink:

:warning: You can also use `bin/setup_benchmark_results_database --force` to drop the
tables in case you need to refresh the table schemas.

### `bin/diggest_results --from <tsbs-host> --to <db-server-host>`

Used to fetch results from the remote tsbs client machine and save into the
benchmark database.

The process is done in the following way:

1. SSH to TSBS client and Database Server machine and collect hardware information.
2. Sync `~:/results` folder from the TSBS client machine
3. Parse local benchmark results, combine with hardware info and save on the benchmark database.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jonatas/bench-hero. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/bench-hero/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Bench::Hero project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/bench-hero/blob/master/CODE_OF_CONDUCT.md).
