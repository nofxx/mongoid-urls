Mongoid::Urls
=============

[![Gem Version](https://badge.fury.io/rb/mongoid-urls.png)](http://badge.fury.io/rb/mongoid-urls)
[![Dependency Status](https://gemnasium.com/nofxx/mongoid-urls.svg)](https://gemnasium.com/nofxx/mongoid-urls)
[![Build Status](https://secure.travis-ci.org/nofxx/mongoid-urls.png)](http://travis-ci.org/nofxx/mongoid-urls)
[![Code Climate](https://codeclimate.com/github/nofxx/mongoid-urls.png)](https://codeclimate.com/github/nofxx/mongoid-urls)
[![Coverage Status](https://coveralls.io/repos/nofxx/mongoid-urls/badge.svg)](https://coveralls.io/r/nofxx/mongoid-urls)

## Mongoid::Urls

Simple slugs for mongoid models!


## Short snappy token ids for Mongoid documents

This library is a quick and simple way to generate slugs
for your mongoid documents.

Mongoid::Urls can help turn this:

    http://bestappever.com/video/4dcfbb3c6a4f1d4c4a000012

Into something more like this:

    http://bestappever.com/video/kittens-playing-with-puppies


## Getting started

In your gemfile, add:

    gem 'mongoid-urls'

In your Mongoid documents, just add `include Mongoid::Urls` and the
`url` method will take care of all the setup, like so:

```ruby
class Article
  include Mongoid::Document
  include Mongoid::Urls

  field :title

  url :title
end

```

And that's it! There's some configuration options too - which are all
listed [below](#configuration).


## Finders

`Mongoid::Urls` will **never** override `find`.
There's some helpers for custom fields:

```ruby
Video.find_by_url("the-nice-url")
Account.find_by_url("acc-123456")
```


## Configuration

You may choose between two different systems for how your urls are stored:

Default #urls

Simple #url


#### Reserved


# Notes
