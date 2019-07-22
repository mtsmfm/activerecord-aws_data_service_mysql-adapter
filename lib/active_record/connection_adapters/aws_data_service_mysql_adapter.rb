require 'active_record/connection_adapters/abstract_mysql_adapter'
require 'active_record/connection_adapters/mysql/database_statements'

require 'active_record/connection_adapters/aws_data_service_mysql/connection.rb'

module ActiveRecord
  module ConnectionHandling
    def aws_data_service_mysql_connection(config)
      ConnectionAdapters::AwsDataServiceMysqlAdapter.new(ConnectionAdapters::AwsDataServiceMysql::Connection.new(config), logger, nil, config)
    end
  end

  module ConnectionAdapters
    class AwsDataServiceMysqlAdapter < AbstractMysqlAdapter
      ADAPTER_NAME = 'AwsDataServiceMysql'.freeze

      include MySQL::DatabaseStatements

      private

      def full_version
        @full_version ||= @connection.server_info[:version]
      end
    end
  end
end
