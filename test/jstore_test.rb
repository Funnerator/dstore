require 'minitest/spec'
require 'minitest/autorun'
require 'pry'

$:.unshift File.expand_path("lib")
require 'jstore'

class Blog
  include JStore::Document
  attr_accessor :jstore

  jstore do
    attribute :title

    one :author
    many :posts
    many :tags

    one :secondary_author, :class_name => 'Author'
    many :archived_posts, :class_name => 'Post'
  end

  class Author
    include JStore::Entity

    attribute :name
  end

  class Tag
    include JStore::Entity

    attribute :name
  end

  class Post
    include JStore::Entity

    attribute :title
    attribute :body

    many :tags

    class Tag < Blog::Tag
    end
  end
end

describe 'JStore::Document' do
  let(:blog) { Blog.new }

  it 'reads attibutes from the jstore hash' do
    blog.jstore[:title] = 'Cats cats cats'
    blog.title.must_equal('Cats cats cats')
  end

  it 'writes attributes to the jstore hash' do
    blog.title = 'Cats cats cats'
    blog.jstore.must_equal({:title => 'Cats cats cats'})
  end

  it 'modifies attributes in the jstore hash' do
    blog.jstore[:title] = 'Cats cats cats'
    blog.title = 'Cats cats cats cats cats'
    blog.title.must_equal('Cats cats cats cats cats')
  end

  describe 'one-relationships' do
    it "reads attributes from the documents' jstore hash" do
      blog.jstore[:author] = {:name => 'Mr. Myowgi'}
      blog.author.name.must_equal 'Mr. Myowgi'
    end

    it "writes new relationships to the documents' jstore hash" do
      blog.author = Blog::Author.new(:name => 'Mr Myowgi')
      blog.jstore[:author].must_equal(:name => 'Mr Myowgi')
    end

    it "modifies attributes from the documents' jstore hash" do
      blog.jstore[:author] = {:name => 'Mr. Myowgi'}
      blog.author.name = 'Mr. Snuggles'
      blog.jstore[:author][:name].must_equal 'Mr. Snuggles'
    end

    it 'accepts a hash, and creates an object' do
      blog.author = {:name => 'Mr Myowgi'}
      blog.author.class.must_equal Blog::Author
      blog.author.name.must_equal 'Mr Myowgi'
    end
  end

  describe 'many-relationships' do
    it "reads attributes from the documents' jstore hash" do
      blog.jstore[:posts] = [{:title => 'Ninja cat pounces!'}]
      blog.posts.first.title.must_equal 'Ninja cat pounces!'
    end

    it "writes attributes to the documents' jstore hash" do
      blog.posts = [Blog::Post.new(:title => 'Ninja cat pounces!')]
      blog.jstore[:posts].must_equal [{:title => 'Ninja cat pounces!'}]
    end

    it "modifies attributes from the documents' jstore hash" do
      blog.jstore[:posts] = [{:title => 'Ninja cat pounces!'}]
      blog.posts.first.title = 'Ninja cat sleeps...'
      blog.jstore[:posts].must_equal [{:title => 'Ninja cat sleeps...'}]
    end

    it 'accepts an array of hashes, and creates an array of objects' do
      blog.posts = [{:title => 'Cats and boxes'}]
      blog.posts.first.class.must_equal Blog::Post
      blog.posts.first.title.must_equal 'Cats and boxes'
    end
  end

  describe 'nested relations' do
    it 'reads nested relationships' do
      blog.jstore = {
        :posts => [
          { :title => 'Cats and boxes',
            :tags => [{:name=>'boxes'}] }
        ],
        :tags => [{:name=>'cat'}] }

      blog.posts.first.title.must_equal 'Cats and boxes'
      blog.posts.first.tags.first.name.must_equal 'boxes'
      blog.tags.first.name.must_equal 'cat'
    end

    it 'writes nested relationships' do
      blog.posts = [Blog::Post.new(:name => 'Cats and boxes')]
      blog.tags  = [Blog::Tag.new(:name => 'cat')]
      blog.posts.first.tags = [Blog::Tag.new(:name => 'boxes')]

      blog.jstore.must_equal(
        :posts => [
          { :name => "Cats and boxes",
            :tags => [{:name=>"boxes"}] }
        ],
        :tags=>[{:name=>"cat"}]
      )
    end

    it 'modifies nested relationships' do
      blog.jstore = {
        :posts => [
          { :title => 'Cats, boxes, and birds',
            :tags => [{:name=>'boxes'}] }
        ],
        :tags => [{:name=>'cat'}] }

      blog.posts.first.tags.first.name = 'birds'

      blog.jstore.must_equal(
        :posts => [
          { :title => "Cats, boxes, and birds",
            :tags => [{:name=>"birds"}] }
        ],
        :tags=>[{:name=>"cat"}]
      )
    end
  end

  describe '#attribute :class_name option' do
    it 'specifies which class to initialize for one-relationships' do
      blog.jstore[:secondary_author] = {:name => 'Mr. Sniggles'}
      blog.secondary_author.class.must_equal Blog::Author
      blog.secondary_author.name.must_equal 'Mr. Sniggles'
    end

    it 'specifies which class to initialize for many-relationships' do
      blog.jstore[:archived_posts] = [{:title => 'Dogs are OK I guess'}]
      blog.archived_posts.first.class.must_equal Blog::Post
      blog.archived_posts.first.title.must_equal 'Dogs are OK I guess'
    end
  end
end
