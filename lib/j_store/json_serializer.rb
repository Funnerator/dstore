require 'json'

module JStore
  module JSONSerializer
    def self.load(source)
      JStore::Helper.deep_symbolize_keys!(JSON.parse(source || '{}'))
    end

    def self.dump(source)
      JSON.fast_generate(source || {})
    end
  end
end
