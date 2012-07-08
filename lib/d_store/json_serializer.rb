require 'json'

module DStore
  module JSONSerializer
    def self.load(source)
      DStore::Helper.deep_symbolize_keys!(JSON.parse(source || '{}'))
    end

    def self.dump(source)
      JSON.fast_generate(source || {})
    end
  end
end
