#!/bin/bash

SCHEMA_DIFF='openlmis-to-elmis-db-upgrade.sql'

new_tables=0
new_views=0
new_foreign_keys=0
new_columns=0
dropped_columns=0
altered_columns=0

new_tables=`egrep -i 'create table' $SCHEMA_DIFF | wc -l | tr -d ' '`
new_views=`egrep -i 'create view' $SCHEMA_DIFF | wc -l | tr -d ' '`
new_foreign_keys=`egrep -i 'foreign key' $SCHEMA_DIFF | wc -l | tr -d ' '`

new_columns=`egrep -i 'add column' $SCHEMA_DIFF`
dropped_columns=`egrep -i 'drop column' $SCHEMA_DIFF`
altered_columns=`sed -e '/ALTER TABLE/,/\;/!d' $SCHEMA_DIFF | grep -i 'alter column'`

new_col_count=`echo "$new_columns" | wc -l | tr -d ' '`
dropped_col_count=`echo "$dropped_columns" | wc -l | tr -d ' '`
altered_col_count=`echo "$altered_columns" | wc -l | tr -d ' '`



echo "FILE: $SCHEMA_DIFF"
echo "**********************************************************************"
echo -e "NEW TABLES:\t\t $new_tables"
echo -e "NEW VIEWS:\t\t $new_views"
echo -e "NEW FOREIGN KEYS:\t $new_foreign_keys"
echo -e "DROPPED_COLUMNS:\t $dropped_col_count"
echo -e "ALTERED COLUMNS:\t $altered_col_count"
echo -e "NEW COLUMNS:\t\t $new_col_count"
echo "**********************************************************************"
echo "DROPPED COLUMNS:"
echo "$dropped_columns"
echo "**********************************************************************"
echo "ALTERED COLUMNS:"
echo "$altered_columns"
echo "**********************************************************************"
echo "NEW COLUMNS:"
echo "$new_columns"
echo "**********************************************************************"


