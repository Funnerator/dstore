module JStore
  class API
    attr_reader :target_class

    def initialize(target_class)
      @target_class = target_class
    end

    def attribute(attr_name)
      target_class.instance_eval do
        # def title
        #   jstore[:title]
        # end
        define_method attr_name do
          jstore[attr_name]
        end

        # def title=(val)
        #   jstore[:title] = val
        # end
        define_method "#{attr_name}=" do |value|
          jstore[attr_name] = value
        end
      end
    end

    # Options:
    # * :class_name - specify which class to use for the relationship
    def one(relationship_name, options = {})
      target_class.instance_eval do
        # def author
        #   if jstore[:author].any? && !instance_variable_defined?('@author')
        #     @author = Blog::Author.new(jstore[:author])
        #   end
        #
        #   @author
        # end
        define_method relationship_name do
          ivar = "@#{relationship_name}"
          if jstore[relationship_name] &&
             !jstore[relationship_name].empty? &&
             !instance_variable_defined?(ivar)
            instance_variable_set(ivar,
              "#{self.class.name}::"\
              "#{options[:class_name] || relationship_name.to_s.camelize}".constantize.
              new(jstore[relationship_name]) )
          end

          instance_variable_get(ivar)
        end

        # def author=(author)
        #   @author = author
        #   jstore[:author] = @author.jstore
        # end
        define_method "#{relationship_name}=" do |relationship_object|
          if relationship_object.is_a?(Hash)
            send("#{relationship_name}=", "#{self.class.name}::"\
              "#{options[:class_name] || relationship_name.to_s.camelize}".constantize.
              new(relationship_object) )
          else
            instance_variable_set("@#{relationship_name}", relationship_object)
            jstore[relationship_name] = relationship_object.jstore
          end
        end
      end
    end

    # Options:
    # * :class_name - specify which class to use for the relationship
    def many(relationship_name, options = {})
      target_class.instance_eval do
        # def posts
        #   if jstore[:posts].any? && !instance_variable_defined?('@posts')
        #     @posts = []
        #     jstore[:posts].each do |post_attrs|
        #       @posts << Blog::Post.new(post_attrs)
        #     end
        #   end
        #
        #   @posts
        # end
        define_method relationship_name do
          ivar = "@#{relationship_name}"
          if jstore[relationship_name] &&
             !jstore[relationship_name].empty? &&
             !instance_variable_defined?(ivar)
            acc = []
            instance_variable_set(ivar, acc)
            jstore[relationship_name].each do |relation_attrs|
              acc << "#{self.class.name}::"\
                "#{options[:class_name] || relationship_name.to_s.singularize.camelize}".constantize.
                new(relation_attrs)
            end
          end

          instance_variable_get(ivar)
        end

        # def posts=(posts)
        #   @posts = posts
        #   jstore[:posts] = @posts.map(&:jstore)
        # end
        define_method "#{relationship_name}=" do |relationship_objects|
          if relationship_objects.first.is_a?(Hash)
            send("#{relationship_name}=", relationship_objects.map do |relationship_object|
              "#{self.class.name}::"\
              "#{options[:class_name] || relationship_name.to_s.singularize.camelize}".constantize.
              new(relationship_object)
            end )
          else
            instance_variable_set("@#{relationship_name}", relationship_objects)
            jstore[relationship_name] = relationship_objects.map(&:jstore)
          end
        end
      end
    end
  end
end
