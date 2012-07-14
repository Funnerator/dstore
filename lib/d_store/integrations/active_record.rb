module DStore
  module Integrations
    module ActiveRecord
      def dstore(column, options = {})
        if storage_column = options.delete(:in)
          if !self.serialized_attributes.has_key?(storage_column)
            serialize storage_column, ::DStore::JSONSerializer
          end

          builder = ::DStore::MethodBuilder.new(self, storage_column)
          builder.define_document_accessor(column, options)
          builder.define_document_attributes_accessor(column, options)
        else
          serialize column, ::DStore::DocumentSerializer.new(
            column, {:namespace => self.name}.merge(options) )

          ::DStore::MethodBuilder.new(self, column).
            define_document_attributes_accessor(column, options)
        end
      end
    end
  end
end
