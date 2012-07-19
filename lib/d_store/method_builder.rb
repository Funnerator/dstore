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

    def define_document_attributes_accessor(relationship_name, options = {})
      if DStore::Helper.collection?(relationship_name, options)
        define_collection_document_attributes_accessor(relationship_name, options)
      else
        define_singular_document_attributes_accessor(relationship_name, options)
      end
    end

    # Options:
    # * :class_name - specify which class to use for the relationship
    def define_singular_document_accessor(relationship_name, options = {})
      storage_attr = @storage_attr
      relationship_name = relationship_name.to_s
      target_class.instance_eval do
        # def author
        #   if !instance_variable_defined?('@author')
        #     @author = Blog::Author.new(dstore[:author] ||= {})
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
              ).constantize.new(send(storage_attr)[relationship_name] ||= {}) )
          end

          instance_variable_get(ivar)
        end

        # def author=(author)
        #   @author = author
        #   dstore[:author] = @author.dstore
        # end
        define_method "#{relationship_name}=" do |relationship_object|
          if relationship_object.is_a?(Hash)
            # got here via instantiation or a form
            send("#{relationship_name}_attributes=", relationship_object)
          else
            instance_variable_set("@#{relationship_name}", relationship_object)
            send(storage_attr)[relationship_name] = relationship_object.dstore
          end
        end
      end
    end

    def define_singular_document_attributes_accessor(relationship_name, options={})
      storage_attr = @storage_attr
      relationship_name = relationship_name.to_s
      target_class.instance_eval do
        # def author_attributes
        #   dstore['author']
        # end
        define_method("#{relationship_name}_attributes") do
          send(storage_attr)[relationship_name]
        end

        # def author_attributes=(attributes)
        #   current_attributes = author.as_json
        #   self.author = Blog::Author.new(current_attributes.merge(attributes))
        # end
        define_method "#{relationship_name}_attributes=" do |attributes|
          current_attributes = send(relationship_name).as_json
          send("#{relationship_name}=", DStore::Helper.class_name_from_column(
            :namespace  => options[:namespace] || self.class.name,
            :class_name => options[:class_name],
            :column     => relationship_name
          ).constantize.new(current_attributes.merge(attributes)) )
        end
      end
    end

    # Options:
    # * :class_name - specify which class to use for the relationship
    def define_collection_document_accessor(relationship_name, options = {})
      storage_attr = @storage_attr
      relationship_name = relationship_name.to_s
      target_class.instance_eval do
        # def posts
        #   if !instance_variable_defined?('@posts')
        #     @posts = []
        #     (dstore[:posts] || []).each do |post_attrs|
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
            # got here via instantiation or a form
            send("#{relationship_name}_attributes=", relationship_objects)
          else
            instance_variable_set("@#{relationship_name}", relationship_objects)
            send(storage_attr)[relationship_name] = relationship_objects.map(&:dstore)
          end
        end
      end
    end

    def define_collection_document_attributes_accessor(relationship_name, options={})

      storage_attr = @storage_attr
      relationship_name = relationship_name.to_s
      target_class.instance_eval do
        # def posts_attributes
        #   dstore['posts']
        # end
        define_method("#{relationship_name}_attributes") do
          send(storage_attr)[relationship_name]
        end

        # def posts_attributes=(attr_collection)
        #   acc = []
        #   if attr_collection.is_a?(Hash) # params-style 'array' as a hash
        #     attr_collection.each_pair do |index, attributes|
        #       current_attributes = posts[index].as_json
        #       acc[index.to_i] =
        #         Blog::Post.new(current_attributes.merge(attributes))
        #     end
        #   else # array of attribute hashes
        #     attr_collection.each_with_index do |attributes, index|
        #       current_attributes = posts[index].as_json
        #       acc << Blog::Post.new(current_attributes.merge(attributes))
        #     end
        #   end
        #
        #   self.posts = acc
        # end
        define_method "#{relationship_name}_attributes=" do |attr_collection|
          model_class = DStore::Helper.class_name_from_column(
            :namespace  => options[:namespace] || self.class.name,
            :class_name => options[:class_name],
            :column     => relationship_name
          ).constantize

          acc = []
          if attr_collection.is_a?(Hash) # params-style 'array' as a hash
            attr_collection.each_pair do |index, attributes|
              current_attributes =
                send(relationship_name)[index.to_i].try(:as_json) || {}
              acc[index.to_i] =
                model_class.new(current_attributes.merge(attributes))
            end
          else # array of attributes
            attr_collection.each_with_index do |attributes, index|
              current_attributes =
                send(relationship_name)[index.to_i].try(:as_json) || {}
              acc << model_class.new(current_attributes.merge(attributes))
            end
          end

          send("#{relationship_name}=", acc)
        end
      end # instance eval
    end # def
  end # class MethodBuilder
end
