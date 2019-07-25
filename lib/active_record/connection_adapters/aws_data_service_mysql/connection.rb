require 'aws-sdk-rdsdataservice'

module ActiveRecord
  module ConnectionAdapters
    module AwsDataServiceMysql
      class Result
        include Enumerable

        def initialize(result, as:, symbolize_keys:, database_timezone:)
          @result = result
          @as = as
          @symbolize_keys = symbolize_keys
          @database_timezone = database_timezone
        end

        def each(as: @as, symbolize_keys: @symbolize_keys)
          return unless @result.records || @result.generated_fields
          raise if @result.records && @result.generated_fields

          @result.lazy.flat_map {|page|
            (page.records || [page.generated_fields]).map {|row|
              row.map {|c| c.is_null ? nil : c.values.compact.first }
            }
          }.each do |row|
            if as == :array
              yield row
            else
              if symbolize_keys
                yield fields.map(&:to_sym).zip(row).to_h
              else
                yield fields.zip(row).to_h
              end
            end
          end
        end

        def fields
          @fields ||= @result.column_metadata ? @result.column_metadata.map(&:label) : []
        end
      end

      class Connection
        attr_reader :query_options

        def initialize(secret_arn:, resource_arn:, database:, **config)
          @client = ::Aws::RDSDataService::Client.new
          @secret_arn = secret_arn
          @resource_arn = resource_arn
          @database = database
          @query_options = {
            database_timezone: :local,
            as: :array, # Mysql2 default is hash
            symbolize_keys: false
          }
        end

        def query(sql, **query_options)
          _query(sql, **@query_options.merge(query_options))
        end

        def ping
          query('SELECT 1')
        end

        def close
          # nop
        end

        def abandon_results!
          # nop
        end

        def affected_rows
          @last_result.number_of_records_updated
        end

        def last_id
          @last_result.generated_fields.first.values.compact.first
        end

        def server_info
          {
            version: query('SHOW VARIABLES LIKE "version";', as: :array).first.last
          }
        end

        def begin_db_transaction
          @current_transaction = client.begin_transaction(secret_arn: secret_arn, resource_arn: resource_arn, database: database)
        end

        def commit_db_transaction
          client.commit_transaction(secret_arn: secret_arn, resource_arn: resource_arn, transaction_id: @current_transaction.transaction_id)
          @current_transaction = nil
        end

        def exec_rollback_db_transaction
          client.rollback_transaction(secret_arn: secret_arn, resource_arn: resource_arn, transaction_id: @current_transaction.transaction_id)
          @current_transaction = nil
        end

        private

        attr_reader :client, :secret_arn, :resource_arn, :database

        def _query(sql, **options)
          @last_result = client.execute_statement(
            secret_arn: secret_arn, resource_arn: resource_arn, sql: sql, database: database, include_result_metadata: true, transaction_id: @current_transaction&.transaction_id
          )
          Result.new(@last_result, **options)
        rescue Aws::RDSDataService::Errors::BadRequestException => error
          if error.message.include?("No database selected")
            raise ActiveRecord::NoDatabaseError
          else
            raise
          end
        end
      end
    end
  end
end
