require 'json'

module DStore
  class DocumentSerializer
    attr_reader :collection, :key, :class_name

    def initialize(column, options = {})
      @class_name = DStore::Helper.class_name_from_column(
        :column     => column,
        :class_name => options[:class_name],
        :namespace  => options[:namespace])
      @collection = DStore::Helper.collection?(column, options)
    end

    def load(source)
      if collection
        load_collection(source)
      else
        load_singular(source)
      end
    end

    def load_collection(source)
      return nil if source.nil?

      JSON.parse(source).map {|hash| load_singular(hash)}
    end

    def load_singular(source)
      return nil if source.nil?

      if source.is_a?(String)
        source = JSON.parse(source)
      end

      @class_name.constantize.new(
        DStore::Helper.deep_symbolize_keys!(source))
    end

    def dump(document)
      if collection
        dump_collection(document)
      else
        dump_singular(document)
      end
    end

    def dump_collection(documents)
      return [] if documents.nil?

      JSON.fast_generate(documents.map(&:as_json))
    end

    def dump_singular(document)
      JSON.fast_generate(document.as_json)
    end
  end
end
