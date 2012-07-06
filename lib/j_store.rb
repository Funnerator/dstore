require 'active_support/core_ext/string/inflections'
require 'active_support/inflector'
require 'j_store/extensions'

module JStore
  autoload :Document, 'j_store/document'
  autoload :API,      'j_store/api'
  autoload :Entity,   'j_store/entity'
  autoload :VERSION,  'j_store/version'
end
