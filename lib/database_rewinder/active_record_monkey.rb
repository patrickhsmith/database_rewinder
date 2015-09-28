module DatabaseRewinder
  module InsertRecorder
    extend ActiveSupport::Concern

    def execute_with_rewinder(sql, *)
      DatabaseRewinder.record_inserted_table self, sql
      execute_without_rewinder sql
    end

    def exec_query_with_rewinder(sql, *)
      DatabaseRewinder.record_inserted_table self, sql
      exec_query_without_rewinder sql
    end

    included do
      alias_method :execute_without_rewinder, :execute
      alias_method :execute, :execute_with_rewinder

      alias_method :exec_query_without_rewinder, :exec_query
      alias_method :exec_query, :exec_query_with_rewinder
    end
  end
end

begin
  require 'active_record/connection_adapters/sqlite3_adapter'
  ::ActiveRecord::ConnectionAdapters::SQLite3Adapter.send :include, DatabaseRewinder::InsertRecorder
rescue LoadError
end
begin
  require 'active_record/connection_adapters/postgresql_adapter'
  ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send :include, DatabaseRewinder::InsertRecorder
rescue LoadError
end
begin
  require 'active_record/connection_adapters/abstract_mysql_adapter'
  ::ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.send :include, DatabaseRewinder::InsertRecorder
rescue LoadError
end
