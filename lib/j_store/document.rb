module JStore
  module Document
    def self.included(base)
      base.extend ClassMethods
    end

    def initialize(*args)
      super
      self.jstore ||= {}
    end

    module ClassMethods
      # takes a block
      def jstore(&block)
        JStore::API.new(self).instance_eval(&block)
      end
    end
  end
end

