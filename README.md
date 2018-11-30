# ActionCounter

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action_counter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install action_counter

## Usage

```ruby
require 'action_counter'

# array = [] # in memory array
array = Redis::List.new('redis_key')

counter = ActionCounter.new(array)
counter.audit('action1') { sleep 1 }
counter.audit('action1') { sleep 2 }
counter.audit('action2') { sleep 1 }

counter.results(sort_key: :sum) # [{action_name: action1, count: 2, sum: 3, min: 1, max: 2, avg: 1.5},
                                #  {action_name: action2, count: 1, sum: 1, min: 1, max: 1, avg: 1}]
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bluerabbit/action_counter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
