require_relative 'test_helper'
module ActiveRecordInOptionTest

  if !defined?(ActiveRecord)

    require 'active_record'
    load 'lib/d_store/integrations.rb'

    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => ':memory:' )

  end

  silence_stream(STDOUT) do
    ActiveRecord::Schema.define(:version => Time.now.to_i) do
      create_table :arin_blogs, :force => true do |t|
        t.string :name
        t.text :dstore
      end
    end
  end

  class Blog < ActiveRecord::Base
    self.table_name = 'arin_blogs'

    dstore :author, :in => :dstore
    dstore :posts, :in => :dstore

    class Author
      include DStore::Document

      attribute :name
    end

    class Post
      include DStore::Document

      attribute :title
    end
  end

  describe 'DStore' do
    let(:blog) { Blog.new }

    describe 'one-relationships' do
      it "reads attributes from the documents' dstore hash" do
        blog.dstore = {'author' => {'name' => 'Mr. Myowgi'}}
        blog.author.name.must_equal 'Mr. Myowgi'
      end

      it "writes new relationships to the documents' dstore hash" do
        blog.author = Blog::Author.new('name' => 'Mr Myowgi')
        blog.dstore.must_equal('author' => {'name' => 'Mr Myowgi'})
      end
    end

    describe 'many-relationships' do
      it "reads attributes from the documents' dstore hash" do
        blog.dstore = {'posts' => [{'title' => 'Ninja cat pounces!'}]}
        blog.posts.first.title.must_equal 'Ninja cat pounces!'
      end

      it "writes attributes to the documents' dstore hash" do
        blog.posts = [Blog::Post.new('title' => 'Ninja cat pounces!')]
        blog.dstore.must_equal('posts' => [{'title' => 'Ninja cat pounces!'}])
      end
    end
  end

end
