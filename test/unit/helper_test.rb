require_relative '../test_helper'

describe 'DStore::Helper' do
  describe '::deep_symbolize_keys!' do
    it 'recursively symbolizes keys in a hash' do
      DStore::Helper.
        deep_symbolize_keys!('a' => {'b' => 'c'}, 'd' => 'e').
        must_equal(:a => {:b => 'c'}, :d => 'e')
    end
  end

  describe '::class_name_from_column' do
    it 'camelcases a basic string' do
      DStore::Helper.class_name_from_column(:column => :blog).
        must_equal 'Blog'
    end

    it 'singularizes plural column names' do
      DStore::Helper.class_name_from_column(:column => :blogs).
        must_equal 'Blog'
    end

    it 'Favors the :class_name argument over inferring from column name' do
      DStore::Helper.class_name_from_column(
        :column => :blogs, :class_name => 'Cat').
        must_equal 'Cat'
    end

    it 'Adds a namespace to the class name via :namespace argument' do
      DStore::Helper.class_name_from_column(
        :column => :post, :namespace => 'Blog').
        must_equal '::Blog::Post'
    end
  end
end
