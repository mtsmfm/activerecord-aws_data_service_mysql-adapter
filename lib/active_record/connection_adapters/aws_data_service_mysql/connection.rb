require 'aws-sdk-rdsdataservice'

module ActiveRecord
  module ConnectionAdapters
    module AwsDataServiceMysql
      class Connection
        attr_reader :query_options

        def initialize(secret_arn:, resource_arn:, **config)
          @client = ::Aws::RDSDataService::Client.new
          @secret_arn = secret_arn
          @resource_arn = resource_arn

          @query_options = {}
        end

        def query(sql)
          _query(sql)
        end

        def ping
          query('SELECT 1')
        end

        def close
          # nop
        end

        def server_info
          {
            version: _query('SHOW VARIABLES LIKE "version";').first.last
          }
        end

        private

        attr_reader :client, :secret_arn, :resource_arn

        def _query(sql)
          result = client.execute_statement(secret_arn: secret_arn, resource_arn: resource_arn, sql: sql)
          return nil if result.records.nil?
          result.flat_map {|page| page.records.map {|row| row.map {|c| c.values.compact.first } } }
        end
      end
    end
  end
end
