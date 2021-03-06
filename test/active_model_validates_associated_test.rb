require_relative 'test_helper'
require 'active_model'
load 'lib/d_store/extensions.rb'

module ActiveModelValidationTest

  class Blog
    include DStore::Document
    include ActiveModel::Validations

    dstore :author
    validates_associated :author

    class Author
      include DStore::Document
      include ActiveModel::Validations

      attribute :name
      validates :name, :presence => true
    end
  end

  describe 'activemodel #validates_associated' do
    let(:blog) { Blog.new }

    it 'adds errors to itself from associations' do
      blog.author = Blog::Author.new(:name => '')
      blog.valid?.must_equal false
      blog.errors[:author].must_equal ['is invalid']
    end
  end

end
