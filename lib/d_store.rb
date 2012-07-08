require 'active_support/core_ext/string/inflections'
require 'active_support/inflector'
require 'd_store/extensions'
require 'd_store/integrations'

module DStore
  autoload :Document,           'd_store/document'
  autoload :MethodBuilder,      'd_store/method_builder'
  autoload :Helper,             'd_store/helper'
  autoload :DocumentSerializer, 'd_store/document_serializer'
  autoload :JSONSerializer,     'd_store/json_serializer'
  autoload :VERSION,            'd_store/version'
end
