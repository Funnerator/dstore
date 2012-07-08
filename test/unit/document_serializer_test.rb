require_relative '../test_helper'
require 'json'

describe 'JStore::DocumentSerializer' do

  class Blog
    include JStore::Document

    attribute :title
  end

  class BlogFoo
    include JStore::Document

    attribute :title
  end

  module Foo
    class Blog
      include JStore::Document

      attribute :title
    end
  end

  it 'dumps one document' do
    subject = JStore::DocumentSerializer.new(:blog)
    subject.dump(Blog.new(:title => 'HeeeloOo')).must_equal(
      {'title' => 'HeeeloOo'}.to_json )
  end

  it 'loads one document' do
    subject = JStore::DocumentSerializer.new(:blog)
    subject.load({'title' => 'HeeeloOo'}.to_json).must_equal(
      Blog.new(:title => 'HeeeloOo'))
  end

  it 'dumps many documents' do
    subject = JStore::DocumentSerializer.new(:blogs)
    subject.dump([Blog.new(:title => 'Blog 1'),
                  Blog.new(:title => 'Blog 2')]).
            must_equal(
              [{'title' => 'Blog 1'},
               {'title' => 'Blog 2'}].to_json )
  end

  it 'loads many documents' do
    subject = JStore::DocumentSerializer.new(:blogs)
    subject.load([{'title' => 'Blog 1'},
                  {'title' => 'Blog 2'}].to_json).
            must_equal(
              [Blog.new(:title => 'Blog 1'),
               Blog.new(:title => 'Blog 2')] )
  end

  it 'loads documents honoring the class_name option' do
    subject = JStore::DocumentSerializer.new(:blog, :class_name => 'BlogFoo')
    subject.load({'title' => 'HeeeloOo'}.to_json).must_equal(
      BlogFoo.new(:title => 'HeeeloOo'))
  end

  it 'loads documents honoring the namespace option' do
    subject = JStore::DocumentSerializer.new(:blog, :namespace => 'Foo')
    subject.load({'title' => 'HeeeloOo'}.to_json).must_equal(
      Foo::Blog.new(:title => 'HeeeloOo'))
  end
end
