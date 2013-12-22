# Memtf

A simple utility to help isolate memory leaks in your ruby applications.

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

## Example
    
    > require 'memtf'
    > 
    > leaky_array = []
    > Memtf.around do
	>   500000.times { |i| leaky_array << "#{i % 2}-#{Time.now.to_i}" }
    > end
 
    +-----------------------------+---------+---------+--------+
    | Class                       | Objects | Leakage | Impact |
    +-----------------------------+---------+---------+--------+
    | Array                       | 2189    | 4.972MB | 96.85% |
    | RubyVM::InstructionSequence | 99      | 0.127MB | 2.47%  |
    | Module                      | 18      | 0.017MB | 0.33%  |
    | Class                       | 13      | 0.010MB | 0.20%  |
    | String                      | 663007  | 0.006MB | 0.12%  |
    | Regexp                      | 2       | 0.001MB | 0.02%  |
    | Hash                        | 9       | 0.001MB | 0.02%  |
    | Thread                      | 0       | 0.000MB | 0.00%  |
    +-----------------------------+---------+---------+--------+


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
