module DStore
  module Document
    def self.included(base)
      base.send(:attr_reader, :dstore)
      base.extend ClassMethods
      base.instance_variable_set('@dstore_api', DStore::MethodBuilder.new(base))
    end

    def initialize(hash = {})
      @dstore = DStore::Helper.deep_symbolize_keys!(hash)
    end

    def ==(other)
      if other.is_a?(DStore::Document)
        self.class.name == other.class.name &&
          self.as_json == other.as_json
      else
        super
      end
    end

    def as_json(*args)
      @dstore
    end

    module ClassMethods
      def attribute(attr_name, options = {})
        @dstore_api.define_attribute(attr_name, options)
      end

      def dstore(relationship_name, options = {})
        @dstore_api.define_document_accessor(relationship_name, options)
      end

      def one(relationship_name, options = {})
        @dstore_api.define_singular_document_accessor(relationship_name, options)
      end

      # Options:
      # * :class_name - specify which class to use for the relationship
      def many(relationship_name, options = {})
        @dstore_api.define_collection_document_accessor(relationship_name, options)
      end

      def inherited(base)
        base.instance_variable_set('@dstore_api', DStore::MethodBuilder.new(base))
      end
    end
  end
end

