[![Gem Version](https://badge.fury.io/rb/memtf.png)](http://badge.fury.io/rb/memtf)
[![Build Status](https://secure.travis-ci.org/dresselm/memtf.png)](http://travis-ci.org/dresselm/memtf)

# Memtf

A simple utility to help isolate memory leaks in your ruby applications.

## Why do we need another 'memory profiler'?

Simplicity and focus.  This utility is limited in its features, but should help you quickly isolate the
class that is causing the bloat.  This alone may be enough.  No patches to ruby, no complicated setup and
no confusing output.

Future releases will support a second pass to drill into a given class.  Hopefully this 2-stroke approach
will be sufficient for most memory leaks.

In the meantime, here are some other memory utilities that may help:

* [perftools](https://github.com/tmm1/perftools.rb) - Aman Gupta, enough said - low-level sampling profiler
* [memprof](https://github.com/ice799/memprof) - Joe Damato, not sure which versions of ruby are supported
* [rubymass](https://github.com/archan937/ruby-mass) - pure ruby and easy to use
* [memlog](https://rubygems.org/gems/memlog) - pure ruby and extremely limited, but may help you get started

Let me know if there are others that I should add to the above list.

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

    +-----------------------------+--------+-------------+------------+
    | Class                       | Impact | LeakageSize | NumObjects |
    +-----------------------------+--------+-------------+------------+
    | Array                       | 96.85% | 4.972MB     | 2189       |
    | RubyVM::InstructionSequence | 2.47%  | 0.127MB     | 99         |
    | Module                      | 0.33%  | 0.017MB     | 18         |
    | Class                       | 0.20%  | 0.010MB     | 13         |
    | String                      | 0.12%  | 0.006MB     | 663007     |
    | Regexp                      | 0.02%  | 0.001MB     | 2          |
    | Hash                        | 0.02%  | 0.001MB     | 9          |
    | Thread                      | 0.00%  | 0.000MB     | 0          |
    +-----------------------------+--------+-------------+------------+

## What should I do with these results?

If there is an obvious Class that is impacting the overall memory footprint asymmetrically, then
you should focus further efforts on that and identifying where it is referenced and what it
references.

If there is no obvious Class, then either you need to better reproduce the leak (more iterations,
execute different paths, etc), or multiple Classes are leaking.  If the latter, then try to create
a focused test that narrows down the leak.

If the highlighted Class is a generic container, like Array or Hash, the leak is probably one or more
Classes referenced within the container. I am working on additional functionality to expose the most
likely candidates.  While I build out this and other additional functionality, please use the tools
mentioned above to help isolate the leak.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
