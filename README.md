# Goliath::Proxy

Allows goliath to be used as a http proxy server.  The request that was proxied is forwarded on to the goliath application.
Useful for debugging proxies, test proxies or anywhere else where you may want to intercept requests via your goliath
application.

## Caution

This code works, but is not yet finished. It allowed me to continue with my project and I intend to come back to this
and test it more thoroughly when my project is complete.

Saying that, dont be afraid to try it - just run it using a normal runner (like in the custom server example in goliath) - there is no binary for it yet

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'goliath-proxy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install goliath-proxy

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/garytaylor/goliath-proxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
