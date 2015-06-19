# minitest-doc-reporter

[![Gem Version](https://badge.fury.io/rb/minitest-doc_reporter.png)]

A more detailed reporter for minitest inspired by the documentation output of
Rspec.

## Install

### Requirements

This gem has not yet been tested with ruby versions previous 2.0.0-p247.

### Installation

```
gem install minitest-doc_reporter
```

Or in your gem file:

```ruby
gem "minitest-doc_reporter"
```

## Usage

Add the following to the top of your minitest file or you spec_helper file:

```require 'minitest/doc_reporter'```

This will replace Minitest's default reports with minitest-doc_reporter's.
