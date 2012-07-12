module DStore
  module Integrations
    module ActiveRecord
      def dstore(column, options = {})
        if storage_column = options.delete(:in)
          if !self.serialized_attributes.has_key?(storage_column)
            serialize storage_column, ::DStore::JSONSerializer
          end

          ::DStore::MethodBuilder.new(self, storage_column).
            define_document_accessor(column, options)
        else
          serialize column, ::DStore::DocumentSerializer.new(
            column, {:namespace => self.name}.merge(options) )
        end
      end
    end
  end
end
