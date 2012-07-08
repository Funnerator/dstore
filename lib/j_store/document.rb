module JStore
  module Document
    def self.included(base)
      base.send(:attr_reader, :jstore)
      base.extend ClassMethods
      base.instance_variable_set('@jstore_api', JStore::MethodBuilder.new(base))
    end

    def initialize(hash = {})
      @jstore = JStore::Helper.deep_symbolize_keys!(hash)
    end

    def ==(other)
      if other.is_a?(JStore::Document)
        self.class.name == other.class.name &&
          self.as_json == other.as_json
      else
        super
      end
    end

    def as_json
      @jstore
    end

    module ClassMethods
      def attribute(attr_name, options = {})
        @jstore_api.define_attribute(attr_name, options)
      end

      def jstore(relationship_name, options = {})
        @jstore_api.define_document_accessor(relationship_name, options)
      end

      def one(relationship_name, options = {})
        @jstore_api.define_singular_document_accessor(relationship_name, options)
      end

      # Options:
      # * :class_name - specify which class to use for the relationship
      def many(relationship_name, options = {})
        @jstore_api.define_collection_document_accessor(relationship_name, options)
      end
    end
  end
end

