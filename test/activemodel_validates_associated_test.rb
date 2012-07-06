require_relative 'test_helper'
require 'active_model'
load 'lib/j_store/extensions.rb'

module ActiveModelValidationTest

  class Blog
    include JStore::Entity
    include ActiveModel::Validations

    attribute :title

    one :author
    validates_associated :author

    class Author
      include JStore::Entity
      include ActiveModel::Validations

      attribute :name
      validates :name, :presence => true
    end
  end

  describe 'activemodel #validates_associated' do
    it 'adds errors to itself from associations' do
      blog = Blog.new(:title => 'Dullest blog')
      blog.author = Blog::Author.new(:name => '')
      blog.valid?.must_equal false
      blog.errors[:author].must_equal ['is invalid']
    end
  end

end
