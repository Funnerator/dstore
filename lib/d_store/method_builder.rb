module DStore
  class MethodBuilder
    attr_reader :target_class, :storage_attr

    def initialize(target_class, storage_attr = :dstore)
      @target_class = target_class
      @storage_attr = storage_attr
    end

    def define_attribute(attr_name, options = {})
      storage_attr = @storage_attr
      attr_name = attr_name.to_s
      target_class.instance_eval do
        # def title
        #   dstore[:title]
        # end
        define_method attr_name do
          send(storage_attr)[attr_name]
        end

        # def title=(val)
        #   dstore[:title] = val
        # end
        define_method "#{attr_name}=" do |value|
          send(storage_attr)[attr_name] = value
        end
      end
    end

    def define_document_accessor(relationship_name, options = {})
      if DStore::Helper.collection?(relationship_name, options)
        define_collection_document_accessor(relationship_name, options)
      else
        define_singular_document_accessor(relationship_name, options)
      end
    end

    # Options:
    # * :class_name - specify which class to use for the relationship
    def define_singular_document_accessor(relationship_name, options = {})
      storage_attr = @storage_attr
      relationship_name = relationship_name.to_s
      target_class.instance_eval do
        # def author
        #   if dstore[:author].any? && !instance_variable_defined?('@author')
        #     @author = Blog::Author.new(dstore[:author])
        #   end
        #
        #   @author
        # end
        define_method relationship_name do
          ivar = "@#{relationship_name}"
          if !instance_variable_defined?(ivar)
            instance_variable_set(ivar,
              DStore::Helper.class_name_from_column(
                :namespace  => options[:namespace] || self.class.name,
                :class_name => options[:class_name],
                :column     => relationship_name
              ).constantize.new(send(storage_attr)[relationship_name] || {}) )
          end

          instance_variable_get(ivar)
        end

        # def author=(author)
        #   @author = author
        #   dstore[:author] = @author.dstore
        # end
        define_method "#{relationship_name}=" do |relationship_object|
          if relationship_object.is_a?(Hash)
            send("#{relationship_name}=", DStore::Helper.class_name_from_column(
              :namespace  => options[:namespace] || self.class.name,
              :class_name => options[:class_name],
              :column     => relationship_name
            ).constantize.new(relationship_object) )
          else
            instance_variable_set("@#{relationship_name}", relationship_object)
            send(storage_attr)[relationship_name] = relationship_object.dstore
          end
        end
      end

      define_singular_document_attributes_accessor(relationship_name)
    end

    # Options:
    # * :class_name - specify which class to use for the relationship
    def define_collection_document_accessor(relationship_name, options = {})
      storage_attr = @storage_attr
      relationship_name = relationship_name.to_s
      target_class.instance_eval do
        # def posts
        #   if dstore[:posts].any? && !instance_variable_defined?('@posts')
        #     @posts = []
        #     dstore[:posts].each do |post_attrs|
        #       @posts << Blog::Post.new(post_attrs)
        #     end
        #   end
        #
        #   @posts
        # end
        define_method relationship_name do
          ivar = "@#{relationship_name}"
          if !instance_variable_defined?(ivar)
            acc = []
            instance_variable_set(ivar, acc)
            (send(storage_attr)[relationship_name] || []).each do |attrs|
              acc << DStore::Helper.class_name_from_column(
                :namespace  => options[:namespace] || self.class.name,
                :class_name => options[:class_name],
                :column     => relationship_name
              ).constantize.new(attrs)
            end
          end

          instance_variable_get(ivar)
        end

        # def posts=(posts)
        #   @posts = posts
        #   dstore[:posts] = @posts.map(&:dstore)
        # end
        define_method "#{relationship_name}=" do |relationship_objects|
          if relationship_objects.first.is_a?(Hash)
            send("#{relationship_name}=", relationship_objects.map do |relationship_object|
              DStore::Helper.class_name_from_column(
                :namespace  => options[:namespace] || self.class.name,
                :class_name => options[:class_name],
                :column     => relationship_name
              ).constantize.new(relationship_object)
            end )
          else
            instance_variable_set("@#{relationship_name}", relationship_objects)
            send(storage_attr)[relationship_name] = relationship_objects.map(&:dstore)
          end
        end
      end

      define_collection_document_attributes_accessor(relationship_name)
    end

    def define_singular_document_attributes_accessor(relationship_name)
      storage_attr = @storage_attr
      relationship_name = relationship_name.to_s
      target_class.instance_eval do
        define_method("#{relationship_name}_attributes") do
          send(storage_attr)[relationship_name]
        end

        define_method("#{relationship_name}_attributes=") do |hash|
          send("#{relationship_name}=",
               DStore::MethodBuilder.deep_handle_attributes_from_params!(hash))
        end
      end
    end

    def define_collection_document_attributes_accessor(relationship_name)
      storage_attr = @storage_attr
      relationship_name = relationship_name.to_s
      target_class.instance_eval do
        define_method("#{relationship_name}_attributes") do
          send(storage_attr)[relationship_name]
        end

        define_method("#{relationship_name}_attributes=") do |hash|
          send("#{relationship_name}=",
               hash.values.map {|attrs|
                 DStore::MethodBuilder.deep_handle_attributes_from_params!(attrs)
               })
        end
      end
    end

    def self.deep_handle_attributes_from_params!(hash)
      hash.keys.each do |key|
        val = hash.delete(key)
        short_key = key.to_s.gsub(/_attributes$/, '')
        if val.is_a?(Hash) && (Integer(val.keys.first) rescue false)
          # a hash of the form {'0' => {'attr' => 'value'},...}
          hash[short_key] = val.values.map do |attrs|
            deep_handle_attributes_from_params!(attrs)
          end
        elsif val.is_a?(Hash) # a non-collection hash value
          hash[short_key] = deep_handle_attributes_from_params!(val)
        else # a simple value
          hash[short_key] = val
        end
      end

      hash
    end
  end
end
