require_relative '../test_helper'

describe 'DStore::Helper' do
  describe '::deep_symbolize_keys!' do
    it 'recursively symbolizes keys in a hash' do
      DStore::Helper.
        deep_symbolize_keys!('a' => {'b' => 'c'}, 'd' => 'e').
        must_equal(:a => {:b => 'c'}, :d => 'e')
    end
  end
end
