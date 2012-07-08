require 'active_support/core_ext/string/inflections'
require 'active_support/inflector'
require 'j_store/extensions'
require 'j_store/integrations'

module JStore
  autoload :Document,           'j_store/document'
  autoload :MethodBuilder,      'j_store/method_builder'
  autoload :Helper,             'j_store/helper'
  autoload :DocumentSerializer, 'j_store/document_serializer'
  autoload :JSONSerializer,     'j_store/json_serializer'
  autoload :VERSION,            'j_store/version'
end
