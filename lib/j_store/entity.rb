module JStore
  module Entity
    def self.included(base)
      base.instance_variable_set('@jstore_api', JStore::API.new(base))
      base.send(:attr_reader, :jstore)
      base.extend ClassMethods
    end

    def initialize(jstore_attrs)
      @jstore = jstore_attrs
    end

    module ClassMethods
      def method_missing(sym, *args, &block)
        if @jstore_api.respond_to?(sym)
          @jstore_api.send(sym, *args, &block)
        else
          super
        end
      end
    end
  end
end
