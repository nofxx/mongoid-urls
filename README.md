Mongoid::Urls
=============

[![Gem Version](https://badge.fury.io/rb/mongoid-urls.svg)](http://badge.fury.io/rb/mongoid-urls)
[![Dependency Status](https://gemnasium.com/nofxx/mongoid-urls.svg)](https://gemnasium.com/nofxx/mongoid-urls)
[![Build Status](https://secure.travis-ci.org/nofxx/mongoid-urls.svg)](http://travis-ci.org/nofxx/mongoid-urls)
[![Code Climate](https://codeclimate.com/github/nofxx/mongoid-urls.svg)](https://codeclimate.com/github/nofxx/mongoid-urls)
[![Coverage Status](https://coveralls.io/repos/nofxx/mongoid-urls/badge.svg)](https://coveralls.io/r/nofxx/mongoid-urls)

## Mongoid::Urls

Simple slugs for mongoid models!
Set the fields you want to try to make an URL out of,
when impossible, use your logic or set the url directly.


## Nice URLs for Mongoid Documents

This library is a quick and simple way to generate URLs (slugs)
for your Mongoid documents.

Mongoid::Urls can help turn this:

    http://bestappever.com/video/4dcfbb3c6a4f1d4c4a000012

Into something like this:

    http://bestappever.com/video/kittens-playing-with-puppies


## Getting started

In your gemfile, add:

    gem 'mongoid-urls'

In your Mongoid documents, just add `include Mongoid::Urls`
and use the `url` method to setup, like so:

```ruby
class Company
  include Mongoid::Document
  include Mongoid::Urls

  field :nickname
  field :fullname
  ...

  url :nickname, :fullname, ...
end

```

And that's it! There's some configuration options too - which are all
listed [below](#configuration).


## Finders

`Mongoid::Urls` will **never** override `find`!

```ruby
Video.find_by_url("the-nice-url")
```

Or just:

```ruby
Account.find_url("acc-123456")
```

## Configuration

You may choose between two different systems for how your urls are stored:

Simple: `#url` String only.

Default to simple + `#urls` Array for history (find when page moved).


#### Reserved

Defaults to `%w(new edit)`.
Have in mind: It's an overwrite, not a merge.


# Notes

If you're looking for conflict resolution, check out `mongoid-slugs`.
This gem intended to be used for manual conflict resolution (duplicates):
Use your own logic and/or return conflict error to the user.
