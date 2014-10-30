# Aerospike::Store
[![Gem Version](https://badge.fury.io/rb/aerospike-store.svg)](http://badge.fury.io/rb/aerospike-store)

Use Aerospike as cache store and/or session store for Rails.
Aerospike easily scales up and besides RAM it also supports SSD for persistency in a highly optimized architecture.
Find out more about [Aerospike](http://www.aerospike.com)

## Dependencies

[Aerospike Ruby Client](https://github.com/aerospike/aerospike-client-ruby)

This gem will be installed using `bundle`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aerospike-store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aerospike-store

## Usage

### Session Store

Add this line to your `config/initializers/session_store.rb`:

```ruby
YourAppName::Application.config.session_store :aerospike_store
```

It is possible to pass aerospike config options here. Defaults are:

```ruby
AppName::Application.config.session_store :aerospike_store,
		:host => "127.0.0.1",
		:port => 3000,
		:ns => "test",
		:set => "session",
		:bin => "data"
```

Or send in a custom client instance:

```ruby
YourAppName::Application.config.session_store :aerospike_store,
		:client => Aerospike::Client.new("127.0.0.1", 3000)
```

Supported data types are:
- Integer
- String
- List
- Hash

Storing other data types requires serialization.

#### Sample code

```ruby
session[:user_id] ||= 42
session[:user_id] += 1
session[:numbers] = [1, 3, 5, 6]
session[:user] = {'title' => 'Amir', 'user_group' => 'root'}
session[:map_list_mix] = [{'r' => 220, 'g' => 0, 'b' => 80}, {'r' => 100, 'g' => 255, 'b' => 25}] 
session[:instance] = Marshal.dump(myInstance)
```

### Cache Store

Add this line to your `config/application.rb`:

```ruby
config.cache_store = :aerospike_store
```

It is possible to pass aerospike config options here. Defaults are:

```ruby
config.cache_store = :aerospike_store,
		:host => "127.0.0.1",
		:port => 3000,
		:ns => "test",
		:set => "cache",
		:bin => "entry"
```

Or send in a custom client instance:

```ruby
config.cache_store = :aerospike_store,
		:client => Aerospike::Client.new("127.0.0.1", 3000)
```

#### Supported options
- :expires_in
- :raw
- :unless_exist
- Aerospike policies

#### Supported functions
- increment
- decrement

#### Sample code
```ruby
Rails.cache.read('message')   # => nil
Rails.cache.write('message', "Aerospike is great!")
@message = Rails.cache.read('message')    # => "Aerospike is great!"
```

Using fetch:
```ruby
@message = Rails.cache.fetch('LongProcess', :expires_in => 30) {
	sleep (3) # waste some time!
	"Processed in 3 seconds!"
}
```

`increment` and `decrement` functions only work with `:raw` data:
```ruby
Rails.cache.write('hits', 0, {:raw => true, :unless_exist => true})
Rails.cache.increment('hits', 10)
Rails.cache.decrement('hits')
hits = Rails.cache.read('hits', {:raw => true})
```

**Fragment caching:**

Enable in `config/environments/development.rb`:
```ruby
  config.action_controller.perform_caching = true
```

Inside a view:
```ruby
<% cache("RecentPosts", :expires_in => 30) do %>
    <% sleep(3) # waste some time! %>
    <h1> Recent Posts</h1>
    <ul>
    	<li>post 234</li>
    	<li>post 235</li>
    </ul>
<% end %>
```

It is also possible to create and use an AerospikeStore cache instance:
```ruby
cache = ActiveSupport::Cache::AerospikeStore.new
@message = cache.read('message')
```


## Single-Bin
By default an Aerospike namespace supports multiple `bins` per key. As both cache store and session store only use a single bin for stroing data, it is recommended to to enable `single-bin` option in namespace configuration for higher performance.

## Contributing

1. Fork it ( https://github.com/amirrf/aerospike-store-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The Aerospike Ruby Client is made available under the terms of the Apache License, Version 2, as stated in the file `LICENSE`.
