# ActiveJobResqueSolo

A plugin for ActiveJob with Resque to prevent duplicate enqueing of jobs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_job_resque_solo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_job_resque_solo

## Usage

In your job class, include the plugin:

```ruby
class MyJob < ActiveJob::Base

  include ActiveJob::Plugins::Resque::Solo

  queue_as :default

  def perform(*args); end
end
```

If an instance of the job with matching arguments is either waiting for a worker or currently executing,
Solo will prevent a new instance of the job from being enqueued.

You can control which named arguments are used to determine uniqueness in the queue:

`solo_only_args`
`solo_except_args`

```ruby
class MyJob < ActiveJob::Base

  include ActiveJob::Plugins::Resque::Solo

  # Only compare "user" args when checking for duplicate jobs.
  solo_only_args :user

  queue_as :default

  def perform(user:, nonce:)
  end
end
```

Conversely, you can exclude arguments from being checked for duplicates.  This
is useful when plugins add arguments of their own to your jobs.

```ruby
class MyJob < ActiveJob::Base

  include ActiveJob::Plugins::Resque::Solo

  solo_except_args :nonce, :retry_count

  queue_as :default

  def perform(user:, nonce:)
  end
end
```

## Duplicate enqueues are still possible

While this plugin will greatly reduce duplicate instances of a job from being
enqueued, there are two scenarios where duplicates may still be enqueued,
so be sure to check out other gems for locking if your job is not idempotent.

1. When multiple processes simultaneously attempt to enqueue the same job two or
more may be enqueued.
2. If your queue has many jobs, and workers remove a job during while Solo scans
the queue, it's possible for the original enqueued job to be missed. Solo will allow
the new instance of the job to be enqueued.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/active_job_resque_solo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveJobResqueSolo project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/active_job_resque_solo/blob/master/CODE_OF_CONDUCT.md).