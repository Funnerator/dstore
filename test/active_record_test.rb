require_relative 'test_helper'
module ActiveRecordTest

  if !defined?(ActiveRecord)

    require 'active_record'
    load 'lib/d_store/integrations.rb'

    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => ':memory:' )

  end

  silence_stream(STDOUT) do
    ActiveRecord::Schema.define(:version => Time.now.to_i) do
      create_table :ar_blogs, :force => true do |t|
        t.string :name

        t.text :author
        t.text :tags
        t.text :posts
      end
    end
  end

  class Blog < ActiveRecord::Base
    self.table_name =  'ar_blogs'

    dstore :author
    dstore :tags
    dstore :posts

    class Author
      include DStore::Document

      attribute :name
    end

    class Tag
      include DStore::Document

      attribute :name
    end

    class Post
      include DStore::Document

      attribute :title
      attribute :body

      many :tags

      class Tag < Blog::Tag
      end
    end
  end

  describe 'DStore' do
    let(:blog) { Blog.new }

    describe 'one-relationships' do
      it 'deserializes a document from the relevant column' do
        blog.author = {:name => 'Mr. Myowgi'}
        blog.save; blog.reload
        blog.author.class.must_equal Blog::Author
        blog.author.name.must_equal 'Mr. Myowgi'
      end

      it 'serializes a document to the relevant column' do
        blog.author = Blog::Author.new(:name => 'Mr Myowgi')
        blog.save; blog.reload
        raw_deserialize(Blog, blog.id, :author).
          must_equal('name' => 'Mr Myowgi')
      end
    end

    describe 'many-relationships' do
      it 'deserializes many documents from the relevant column' do
        blog.posts = [{:title => 'Ninja cat pounces!'}]
        blog.save; blog.reload
        blog.posts.first.title.must_equal 'Ninja cat pounces!'
      end

      it 'serializes a document to the relevant column' do
        blog.posts = [Blog::Post.new(:title => 'Ninja cat pounces!')]
        blog.save; blog.reload
        raw_deserialize(Blog, blog.id, :posts).
          must_equal([{'title' => 'Ninja cat pounces!'}])
      end
    end

    describe 'nested relations' do
      it 'reads nested json into a document hierarchy' do
        blog.posts = [
          { :title => 'Cats and boxes',
            :tags => [{:name=>'boxes'}] } ]

        blog.save; blog.reload

        blog.posts.first.title.must_equal 'Cats and boxes'
        blog.posts.first.tags.first.name.must_equal 'boxes'
      end

      it 'writes nested documents into nested json' do
        blog.posts = [Blog::Post.new(:name => 'Cats and boxes')]
        blog.posts.first.tags = [Blog::Post::Tag.new(:name => 'boxes')]

        blog.save; blog.reload

        raw_deserialize(Blog, blog.id, :posts).
          must_equal(
            [{ "name" => "Cats and boxes",
               "tags"  => [{"name"=>"boxes"}] }]
        )
      end
    end

    def raw_deserialize(klass, id, column)
      JSON.parse(Blog.connection.execute(
        "select * from #{klass.table_name} where id = #{id}"
      ).first[column.to_s])
    end
  end

end
