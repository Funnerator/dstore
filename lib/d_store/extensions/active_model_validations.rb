module ActiveModel::Validations::ClassMethods
  def self.extended(base)
    super
    unless base.respond_to?(:validates_associated)
      base.extend JStoreExtension
    end
  end

  module JStoreExtension
    def validates_associated(*associations)
      class_eval do
        validates_each(associations) do |record, associate_name, value|
          (value.respond_to?(:each) ? value : [value]).each do |rec|
            if rec && !rec.valid?
              rec.errors.each do |key, value|
                record.errors.add(associate_name, 'is invalid')
              end
            end
          end
        end
      end
    end
  end
end
