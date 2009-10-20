module MultiDb
  module ActionControllerExtensions
    def self.included(base)
      base.send :include, InstanceMethods
      base.alias_method_chain :redirect_to, :master
      base.prepend_around_filter :multi_db_connect_to_master
    end

    module InstanceMethods
      protected

      def redirect_to_with_master(*args)
        logger.info "[MULTIDB] redirect to with master"

        flash[:multi_db_connect_to_master] = true
        redirect_to_without_master(*args)
      end

      private

      def multi_db_connect_to_master
        if flash[:multi_db_connect_to_master] and ActiveRecord::Base.respond_to?(:connection_proxy) and ActiveRecord::Base.connection_proxy.respond_to?(:with_master)
          ActiveRecord::Base.connection_proxy.with_master do
            logger.info "[MULTIDB] connect to master"
            yield
          end
        else
          yield
        end
      end
    end
  end
end
