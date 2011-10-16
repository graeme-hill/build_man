require 'rubygems' if RUBY_VERSION < '1.9'
require 'tiny_migration_lib'
require 'sql_wrangler'
require 'uuidtools'

class BuildMan
  
  class DataContext
    
    @@default_connection_string = "build_man.sqlite3"
    
    def initialize(connection_string = @@default_connection_string)
      @connection_string = connection_string
    end
    
    def with_connection
      conn = SqlWrangler::SqLiteConnection.new(@connection_string)
      begin
        yield conn
      ensure
        conn.close()
      end
    end
    
    def migrations
      [Migration1.new]
    end
    
    def migrate_database!
      TinyMigrator::run_migrations(migrations)
    end
    
    def get_projects
      with_connection do |conn|
        return conn.query("select * from projects").execute
      end
    end
    
    def get_projects_with_most_recent_result
      with_connection do |conn|
        return conn.query("
          select 
            p.id, p.name, r.is_success, r.build_date, r.message, r.data
          from projects p
            left join (
              select 
                pbr.is_success, pbr.build_date, pbr.message, pbr.data
              from project_build_results pbr
              join (
                select project_id, max(build_date) as build_date
                from project_build_results 
                group by project_id, build_date) maxes 
                  on maxes.build_date = pbr.build_date) r on r.project_id = p.id
          ").execute
      end
    end
    
    def insert_project(name)
      id = UUIDTools::UUID::random_create.to_s
      with_connection do |c|
        c.command("insert into projects values (:id, :name)", 
          :id => id, 
          :name => name)
      end
      return id
    end
    
    def insert_project_build_result(project_id, is_success, build_date, message, data)
      id = UUIDTools::UUID::random_create.to_s
      with_connection do |c|
        c.command("
          insert into projects_build_results 
            (id, project_id, is_success, message, data, build_Date)
          values 
            (:id, :project_id, :is_success, :message, :data)", 
          :id => id, 
          :project_id => project_id,
          :is_success => is_success,
          :build_date => build_date,
          :message => message,
          :data => data)
      end
      return id      
    end
    
    class Migration1 < Migration
      
      def version
        return 1
      end
      
      def sql
        "
        create table projects
        (
          id text not null primary key,
          name text not null
        );
        
        create table project_build_results
        (
          id text not null primary key,
          project_id text not null,
          is_success int not null,
          message text not null,
          data text not null,
          build_date text not null
        );
        "
      end
      
    end
    
  end
  
end