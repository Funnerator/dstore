module DStore
  module Helper
    class << self
      def class_name_from_column(args)
        class_name = args[:class_name] ||
                     args[:column].to_s.singularize.camelize

        if args[:namespace]
          class_name = "::#{args[:namespace]}::#{class_name}"
        end

        class_name
      end

      # this should be a hash extension, but let's not add stuff to the
      # core lib.
      # Taken from Rails' head.
      def deep_symbolize_keys!(hash)
        hash.keys.each do |key|
          val = hash.delete(key)
          hash[key.to_sym] = val.is_a?(Hash) ? deep_symbolize_keys!(val) : val
        end
        hash
      end

      # Generic method that determines to one or many from an attribute name,
      # ex. 'posts', or options that may include a specific :collection bool
      def collection?(attr_name, options = {})
        if (options.has_key?(:collection) &&
            options[:collection]) ||
          (!options.has_key?(:collection) &&
           DStore::Helper.plural?(attr_name))

          options.delete(:collection)

          true
        else # singular
          false
        end
      end

      def plural?(string)
        string = string.to_s
        string.pluralize == string && string.singularize != string
      end
    end
  end
end
