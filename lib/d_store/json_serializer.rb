require 'json'

module DStore
  module JSONSerializer
    def self.load(source)
      JSON.parse(source || '{}')
    end

    def self.dump(source)
      JSON.fast_generate(source || {})
    end
  end
end
