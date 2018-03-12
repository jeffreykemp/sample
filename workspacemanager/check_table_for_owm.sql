prompt check_table_for_owm.sql

prompt Report any table or column names that are too long
select table_name, column_name
from user_tab_columns
where table_name = :TABLE_NAME
and (length(column_name) > 28 or length(table_name) > 25);

prompt Report any index names that are too long (to support workspace manager table alters)
select table_name, index_name
from user_indexes
where table_name = :TABLE_NAME
and length(index_name) > 26;

prompt Report any constraint names that are too long (to support workspace manager table alters)
select table_name, constraint_name
from user_constraints
where table_name = :TABLE_NAME
and length(constraint_name) > 26;
