module JStore
  module ActiveRecordHook
    def jstore(column, options = {})
      if storage_column = options.delete(:in)
        JStore::MethodBuilder.new(self, storage_column).
          define_document_accessor(column, options)
      else
        serialize column, JStore::DocumentSerializer.new(
          column, options.merge(:namespace => self.name) )
      end
    end
  end
end

ActiveRecord::Base.extend(JStore::ActiveRecordHook)
