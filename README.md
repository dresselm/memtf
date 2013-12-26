[![Gem Version](https://badge.fury.io/rb/memtf.png)](http://badge.fury.io/rb/memtf)
[![Build Status](https://secure.travis-ci.org/dresselm/memtf.png)](http://travis-ci.org/dresselm/memtf)

# Memtf

A simple utility to help isolate memory leaks in your ruby applications.

## Why do we need another 'memory profiler'?

## Installation

Add this line to your application's Gemfile:

    gem 'memtf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install memtf

## Prerequisites

The APIs used by the gem require ruby 1.9.3+.

## Usage

    $ bundle exec irb

    > require 'memtf'

    > Memtf.start
    > # ... do some stuff ...
    > Memtf.stop

    > # or, wrap around a block
    > Memtf.around { ... }

## Example

    > require 'memtf'
    >
    > leaky_array = []
    > Memtf.around do
	>   500000.times { |i| leaky_array << "#{i % 2}-#{Time.now.to_i}" }
    > end

    +-----------------------------+--------+---------+---------+---------+---------+
    | Class                       | Impact | Leakage | Change  | Objects | Change  |
    +-----------------------------+--------+---------+---------+---------+---------+
    | Array                       | 96.85% | 4.972MB | 4.972MB | 2189    | 1985    |
    | RubyVM::InstructionSequence | 2.47%  | 0.127MB | 0.000MB | 99      | 0       |
    | Module                      | 0.33%  | 0.017MB | 0.002MB | 18      | 0       |
    | Class                       | 0.20%  | 0.010MB | 0.001MB | 13      | 0       |
    | String                      | 0.12%  | 0.006MB | 0.001MB | 663007  | 123650  |
    | Regexp                      | 0.02%  | 0.001MB | 0.000MB | 2       | 0       |
    | Hash                        | 0.02%  | 0.001MB | 0.001MB | 9       | 2       |
    | Thread                      | 0.00%  | 0.000MB | 0.000MB | 0       | 0       |
    +-----------------------------+--------+---------+---------+---------+---------+

## What should I do with these results?

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
