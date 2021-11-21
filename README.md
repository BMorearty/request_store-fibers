# RequestStore::Fibers

Ya know how sometimes you need to keep track of per-request state in a Rails app?
You reach for [RequestStore](https://github.com/steveklabnik/request_store)
to do that, right? Works great.

## The problem

But now you want to start using the [Async](https://github.com/socketry/async)
gem with the [Falcon](https://github.com/socketry/falcon) server for
asynchronous I/O and improved performance and scalability. 
Problem is, those gems work by creating fibers—and the thread-local storage that 
RequestStore uses is also fiber-local, so
it doesn’t get passed down into child fibers. You could be in the middle
of handling a request, start a new fiber to fire off an async I/O request to
a service, and that fiber no longer has access to the per-request store.

## The solution

Any time a fiber is created, this gem copies the 
`RequestStore` data into the new fiber’s thread-local storage.

## But how?

Ruby! It’s magical! You can hook into anything, including standard library calls.
I hook into `Fiber.new` and store `Thread.current[:request_store]` in a 
variable. Once the newly-created fiber resumes for the first time, I copy that value
into the fiber’s `Thread.current[:request_store]`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'request_store-fibers'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install request_store-fibers

## Usage

Make an initializer that does this:

```ruby
RequestStore::Fibers.hook_up
```

If you ever need to unhook fiber creation, here’s how:

```ruby
RequestStore::Fibers.unhook
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BMorearty/request_store-fibers.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
