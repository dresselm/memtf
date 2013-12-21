# Memtf

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'memtf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install memtf

## Usage
    
    $ bundle exec irb
    > require 'memtf'
    > Memtf.start
    > # ... do some stuff ...
    > Memtf.finish 
    > # or, wrap around a block
    > Memtf.around { ... }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
