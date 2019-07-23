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

      def initialize(*)
        super
        @prepared_statements = false
      end

      def each_hash(result)
        if block_given?
          result.each(as: :hash, symbolize_keys: true) do |row|
            yield row
          end
        else
          to_enum(:each_hash, result)
        end
      end

      private

      def error_number(exception)
        exception.error_number if exception.respond_to?(:error_number)
      end

      def full_version
        @full_version ||= @connection.server_info[:version]
      end
    end
  end
end
