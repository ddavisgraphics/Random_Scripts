#!/usr/bin/env ruby

class GenerateAgentsSQL
  def initialize(filename, tables, column)
    @filename = filename
    @tables = tables
    @columns = column
  end

  def create_sql_file
    file = File.open(@filename, 'w')
    contents = set_boolean_true
    file.puts contents
    file.close
  end

  def set_boolean_true
    sql = ""
    sql_end = "\n\t SET #{column}=1 WHERE #{column}=0 OR #{column} IS NULL; \n\n"
    @tables.each do |table|
      sql_start = "UPDATE `#{table}`"
      sql << sql_start << sql_end
    end
    return sql
  end
end

sql = GenerateAgentsSQL.new(
  './publish_agents.sql',
  ['agent_corporate_entity', 'agent_family', 'agent_person', 'agent_software'],
  'publish'
)

sql.create_sql_file
