module MultiDb
  module ObserverExtensions
    def self.included(base)
      base.alias_method_chain :update, :masterdb
    end
    
    # Send observed_method(object) if the method exists.
    def update_with_masterdb(observed_method, object) #:nodoc:
      connection = object.class.connection if object.class.respond_to?(:connection)
      connection ||= object.connection
      if connection.respond_to?(:with_master)
        connection.with_master do
          update_without_masterdb(observed_method, object)
        end
      else
        update_without_masterdb(observed_method, object)
      end
    end
  end
end
