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

#### For api key access

```ruby
require 'zaif'
api = Zaif::API.new(:api_key => ZAIF_KEY, :api_secret => ZAIF_SECRET)
```
#### [For oauth token access](http://techbureau-api-document.readthedocs.io/ja/latest/oauth/1_common.html)

```ruby
require 'zaif'
api = Zaif::API.new(:token => ZAIF_ACCESS_TOKEN)
```

### [APIs](http://techbureau-api-document.readthedocs.io/ja/latest/index.html)

#### [Public API](http://techbureau-api-document.readthedocs.io/ja/latest/public/index.html)
```ruby
api.get_currencies                   # all currencies
api.get_currencies("btc")

api.get_currency_pairs               # all currency pairs
api.get_currency_pairs("btc")        # BTC/JPY
api.get_currency_pairs("bch", "btc") # BCH/BTC

api.get_last_price("btc")            # BTC/JPY
api.get_last_price("bch", "btc")     # BCH/BTC

api.get_ticker("btc")                # BTC/JPY
api.get_ticker("bch", "btc")         # BCH/BTC

api.get_trades("btc")                # BTC/JPY
api.get_trades("bch", "btc")         # BCH/BTC

api.get_depth("btc")                 # BTC/JPY
api.get_depth("bch", "btc")          # BCH/BTC
```

#### [Trade API](http://techbureau-api-document.readthedocs.io/ja/latest/trade/index.html)
```ruby
api.get_info

api.get_info2

api.get_my_trades # all
api.get_my_trades(:from => 5) # offset
api.get_my_trades(:count => 5) # number of trades
api.get_my_trades(:order => "ASC") # sort
api.get_my_trades(:currency_pair => "mona_jpy") # MONA/JPY
api.get_my_trades(:from_id => 1000) # order_id
api.get_my_trades(:end_id => 1100)  # order_id
api.get_my_trades(:from_id => 1000, :end_id => 1100) # order_id
api.get_my_trades(:since => Time.local(2017, 11, 20).to_i) # unix_timestamp
api.get_my_trades(:end => Time.local(2017, 11, 21).to_i) # unix_timestamp
api.get_my_trades(:since => Time.local(2017, 11, 20).to_i, :end => Time.local(2017, 11, 21).to_i) # unix_timestamp

api.get_active_orders # all currency pairs
api.get_active_orders(:currency_pairs => "btc_jpy") # BTC/JPY

api.bid("btc", 30760, 0.0001)
api.ask("btc", 30320, 0.0001)
api.bid("btc", 30760, 0.0001, 30780) # with limit
api.ask("btc", 30320, 0.0001, nil, "comments") # with comments
api.bid("btc", 30760, 0.0001, 30780, "comments") # with limit and comments

api.cancel("btc", 12345678) # BTC/JPY
api.cancel("bch", 12345678) # BCH/JPY
api.cancel("bch", 12345678, "btc") # BCH/BTC

api.withdraw("btc", "InputAddress", 0.0001)
api.withdraw("btc", "InputAddress", 0.0001, :opt_fee => 0.0001) # with fee(for BTC or MONA)
api.withdraw("xem", "InputAddress", 0.0001, :message => "message") # with message(for XEM)

api.withdraw_history("btc")
api.withdraw_history("btc", :from => 5) # offset
api.withdraw_history("btc", :count => 5) # number of withdraws
api.withdraw_history("btc", :order => "ASC") # sort
api.withdraw_history("btc", :from_id => 1000) # txid
api.withdraw_history("btc", :end_id => 1100)  # txid
api.withdraw_history("btc", :from_id => 1000, :end_id => 1100) # txid
api.withdraw_history("btc", :since => Time.local(2017, 11, 20).to_i) # unix_timestamp
api.withdraw_history("btc", :end => Time.local(2017, 11, 21).to_i) # unix_timestamp
api.withdraw_history("btc", :since => Time.local(2017, 11, 20).to_i, :end => Time.local(2017, 11, 21).to_i) # unix_timestamp

api.deposit_history("btc")
api.deposit_history("btc", :from => 5) # offset
api.deposit_history("btc", :count => 5) # number of withdraws
api.deposit_history("btc", :order => "ASC") # sort
api.deposit_history("btc", :from_id => 1000) # txid
api.deposit_history("btc", :end_id => 1100)  # txid
api.deposit_history("btc", :from_id => 1000, :end_id => 1100) # txid
api.deposit_history("btc", :since => Time.local(2017, 11, 20).to_i) # unix_timestamp
api.deposit_history("btc", :end => Time.local(2017, 11, 21).to_i) # unix_timestamp
api.deposit_history("btc", :since => Time.local(2017, 11, 20).to_i, :end => Time.local(2017, 11, 21).to_i) # unix_timestamp
```

#### [Futures Public API](http://techbureau-api-document.readthedocs.io/ja/latest/public_futures/index.html)
```ruby
```

#### [Leverage Trade API](http://techbureau-api-document.readthedocs.io/ja/latest/trade_leverage/index.html)
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
