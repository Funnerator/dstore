module DStore
  module Integrations # to make autoload happy
    autoload :ActiveRecord, 'd_store/integrations/active_record'
  end
end

if defined?(ActiveRecord)
  ActiveRecord::Base.extend(DStore::Integrations::ActiveRecord)
end

