util = require('./util')

init = (plv8)->
  plv8.execute """
    CREATE TABLE resource (
      version_id text,
      logical_id text,
      resource_type text,
      updated TIMESTAMP WITH TIME ZONE,
      published  TIMESTAMP WITH TIME ZONE,
      content jsonb
    )
    """

  plv8.execute """
    CREATE TABLE resource_history (
      version_id text,
      logical_id text,
      resource_type text,
      updated TIMESTAMP WITH TIME ZONE,
      published  TIMESTAMP WITH TIME ZONE,
      content jsonb
    )
    """
exports.init  = init

drop_table = (plv8, resource_type)->
  table_name = util.table_name(resource_type)
  plv8.execute("""drop table if exists #{table_name}""")
  plv8.execute("""drop table if exists #{table_name}_history""")

exports.drop_table  = drop_table

generate_table = (plv8, resource_type)->
  table_name = util.table_name(resource_type)
  plv8.execute """CREATE TABLE "#{table_name}" () INHERITS (resource)"""
  plv8.execute """
    ALTER TABLE "#{table_name}"
      ADD PRIMARY KEY (logical_id),
      ALTER COLUMN updated SET NOT NULL,
      ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP,
      ALTER COLUMN published SET NOT NULL,
      ALTER COLUMN published SET DEFAULT CURRENT_TIMESTAMP,
      ALTER COLUMN content SET NOT NULL,
      ALTER COLUMN resource_type SET DEFAULT '#{resource_type}'
    """
  plv8.execute """CREATE UNIQUE INDEX #{table_name}_version_id_idx ON "#{table_name}" (version_id)"""
  plv8.execute """CREATE TABLE "#{table_name}_history" () INHERITS (resource_history)"""

  plv8.execute """
    ALTER TABLE "#{table_name}_history"
      ADD PRIMARY KEY (version_id),
      ALTER COLUMN updated SET NOT NULL,
      ALTER COLUMN updated SET DEFAULT CURRENT_TIMESTAMP,
      ALTER COLUMN published SET NOT NULL,
      ALTER COLUMN published SET DEFAULT CURRENT_TIMESTAMP,
      ALTER COLUMN content SET NOT NULL,
      ALTER COLUMN resource_type SET DEFAULT '#{resource_type}';
    """

exports.generate_table = generate_table
