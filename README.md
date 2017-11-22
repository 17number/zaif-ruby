# Zaif

Zaif API wrapper for ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'zaif', github: "17number/zaif-ruby"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install specific_install
    $ gem specific_install https://github.com/17number/zaif-ruby.git

## Usage

### Initialize

#### For api key access:

```ruby
require 'zaif'
api = Zaif::API.new(:api_key => ZAIF_KEY, :api_secret => ZAIF_SECRET)
```
#### For oauth token access:

```ruby
require 'zaif'
api = Zaif::API.new(:token => ZAIF_ACCESS_TOKEN)
```

### APIs

#### Public API
```ruby
api.get_last_price("btc")
api.get_ticker("btc")
api.get_trades("btc")
api.get_depth("btc")
```

#### Trade API
```ruby
api.get_info
api.get_info2
api.get_my_trades
api.get_active_orders
api.bid("btc", 30760, 0.0001)
api.ask("btc", 30320, 0.0001)
api.bid("btc", 30760, 0.0001, 30780) # with limit
api.ask("btc", 30320, 0.0001, nil, "comments") # with comments
api.bid("btc", 30760, 0.0001, 30780, "comments") # with limit and comments
api.cancel(12345678)
api.withdraw("btc", "InputAddress", 0.0001)
api.withdraw_history("btc")
api.deposit_history("btc")
```

#### Futures Public API
```ruby
```

#### Leverage Trade API
```ruby
```

#### Public Stream API
```ruby
```

## Contributing

1. Fork it ( https://github.com/palon7/zaif-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
