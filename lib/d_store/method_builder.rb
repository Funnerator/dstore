module DStore
  class MethodBuilder
    attr_reader :target_class, :storage_attr

    def initialize(target_class, storage_attr = :dstore)
      @target_class = target_class
      @storage_attr = storage_attr
    end

    def define_attribute(attr_name, options = {})
      storage_attr = @storage_attr
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
          if send(storage_attr)[relationship_name] &&
             !send(storage_attr)[relationship_name].empty? &&
             !instance_variable_defined?(ivar)
            instance_variable_set(ivar,
              DStore::Helper.class_name_from_column(
                :namespace  => self.class.name,
                :class_name => options[:class_name],
                :column     => relationship_name
              ).constantize.new(send(storage_attr)[relationship_name]) )
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
              :namespace  => self.class.name,
              :class_name => options[:class_name],
              :column     => relationship_name
            ).constantize.new(relationship_object) )
          else
            instance_variable_set("@#{relationship_name}", relationship_object)
            send(storage_attr)[relationship_name] = relationship_object.dstore
          end
        end
      end
    end

    # Options:
    # * :class_name - specify which class to use for the relationship
    def define_collection_document_accessor(relationship_name, options = {})
      storage_attr = @storage_attr
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
          if send(storage_attr)[relationship_name] &&
             !send(storage_attr)[relationship_name].empty? &&
             !instance_variable_defined?(ivar)
            acc = []
            instance_variable_set(ivar, acc)
            send(storage_attr)[relationship_name].each do |relation_attrs|
              acc << DStore::Helper.class_name_from_column(
                :namespace  => self.class.name,
                :class_name => options[:class_name],
                :column     => relationship_name
              ).constantize.new(relation_attrs)
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
                :namespace  => self.class.name,
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
    end

  end
end
