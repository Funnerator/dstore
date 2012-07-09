module DStore
  module Integrations
    module ActiveRecord
      def dstore(column, options = {})
        if storage_column = options.delete(:in)
          ::DStore::MethodBuilder.new(self, storage_column).
            define_document_accessor(column, options)
        else
          serialize column, ::DStore::DocumentSerializer.new(
            column, options.merge(:namespace => self.name) )
        end
      end
    end
  end
end
