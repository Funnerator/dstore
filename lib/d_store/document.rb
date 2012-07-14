module DStore
  module Document
    def self.included(base)
      base.send(:attr_reader, :dstore)
      base.extend ClassMethods
      base.instance_variable_set('@dstore_api', DStore::MethodBuilder.new(base))
    end

    def initialize(hash = {})
      # note: this destructively modifies the incoming hash;
      # this is intentional, as we rely on pass by reference
      @dstore = DStore::Helper.deep_stringify_keys!(hash)

      # for many attrs this will be a no-op, but provides an
      # opportunity to override the attribute setter,
      # plus raises when it sees something it doesn't know about.
      #
      # Most importantly, though, for [relation]_attributes this will
      # trigger necessary (recursive) document instantiation.
      @dstore.keys.each do |key|
        send("#{key}=", @dstore[key])
        @dstore.delete(key) if key =~ /_attributes$/
      end
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

    # It would be great to do this in the integrations folder, but autoload
    # is a pita...
    if defined?(Rails)
      # to let us use it in a form
      include ActiveModel::Conversion
      extend  ActiveModel::Naming
      def persisted?; false; end
    end
  end
end

