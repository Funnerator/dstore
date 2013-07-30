# DStore

Turn any field (esp. text fields) into object-oriented,
rails-view-friendly nested document stores.

Good use cases tend to be storing chunks of data that have a clear
sub-structure, typically needing to be shared between a few different
field types (ex. an address object) but typically not needing to be
searched on.

The real-world example that birthed DStore is representing applications
to kids camps. This data is sometimes structured and repetitious, in that
it can contain multiple addresses, emergency contacts, etc. Yet, it is
also subject to structure change and customization, and has a sometimes
deeply nested nature, but is never searched on. In short, it's a
read-only chunk of historical semi-structured data.

Seeing something like this, it might be tempting to use a document
store, but that's likely overkill. DStore is meant to serve as an
intermediate solution by allowing object-oriented storage of
semi-structured data in an otherwise relational data model.

It is interesting to note another use case that came later was temporary
storage of some session data in memcache. Since DStore doesn't actually
care how it's serialized so long as the `#dstore` method returns a hash,
you can have a lightweight document mapper over any type of storage, so
long as you implement `#save` and `::find`.

## Usage

Simple but demonstrative case:

    require 'active_model'
    require 'dstore'

    class User
      include DStore::Document
      include ActiveModel::Validations

      # will use this to keep itself and any subdocuments
      attr_accessor :dstore

      attribute :first_name
      attribute :last_name
      one :address

      validates :first_name, presence: true
      validates_associated :address

      class Address
        include DStore::Document
        include ActiveModel::Validations

        attribute :street_1
        attribute :street_2
        attribute :city
        attribute :state
        attribute :zip
        attribute :country

        validates_presence_of :street_1, :city, :state, :zip, :country
      end
    end

    user = User.new(first_name: 'Foo', last_name: 'Bar')
    user.address = User::Address.new(street_1: 'Foo Rd',
                                     city:     'Seattle',
                                     state:    'WA',
                                     zip:      98103 )

    user.valid? # false
    user.errors.to_hash # {address: ['is invalid']}
    user.address.errors.to_hash # {country: ["can't be blank"]}

    user.address.country = 'USA'
    user.valid? # true

    user.dstore
    # {"first_name" => "Foo",
    #  "last_name"  => "Bar",
    #  "address" =>
    #   {"street_1" => "Foo Rd",
    #    "city"     => "Seattle",
    #    "state"    => "WA",
    #    "zip"      => 98103,
    #    "country"  => "USA"}}

### ActiveRecord:

Here, Blog has `author` and `posts` text fields:

    class Blog < ActiveRecord::Base
      dstore :author
      dstore :posts # auto one-to-many based on name

      class Author
        include DStore::Document
        attribute :name
      end

      class Post
        include DStore::Document
        attribute :title
      end
    end

DStore also supports many documents in one field via the `in` option.
Here, Blog just has a `dstore` text field:

    class Blog < ActiveRecord::Base
      with_options(in: :dstore) do |opts|
        opts.dstore :author
        opts.dstore :posts
      end

      class Author
        include DStore::Document
        attribute :name
      end

      class Post
        include DStore::Document
        attribute :title
      end
    end

### Feature Overview

* Supports `one` and `many` simple nested documents, ex:

    class Blog
      include DStore::Document

      one :author
      many :books

      # ...
    end

* ORM agnostic, with ActiveRecord support built in. Configure document
  fields via `ActiveRecord::Base::dstore`

* Supports one or multiple storage fields per ActiveRecord model via `in`, ex:

    class Blog < ActiveRecord::Base
      dstore :author # stored in #author field
      dstore :books, in: :foostore # stored in #foostore field
      dstore :morefoo, in: :foostore # also stored in #foostore field

      # ...
    end

* Can namespace documents for sharing, (contrived) ex:

    class Blog
      include DStore::Document

      one :author, namespace: 'Documents'
    end

    module Documents
      class Author
        include DStore::Document
        attribute :name
      end
    end

# Can specify the class name:

    class Blog
      include DStore::Document

      one :author, class_name: 'Foobar'

      class Foobar
        include DStore::Document
        attribute :name
      end
    end

## Installation

Add this line to your application's Gemfile:

    gem 'dstore'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dstore

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
