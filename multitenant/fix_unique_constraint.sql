create or replace procedure fix_unique_constraint
  (table_name in varchar2
  ,constraint_name in varchar2 := null) is
-- Modify unique constraint(s) to include security_group_id
  l_ddl varchar2(32767);
begin
  for r in (
    select c.table_name, c.constraint_name
          ,decode(c.constraint_type
                 ,'U','unique'
                 ,'P','primary key') as constraint_type
          ,(select listagg('"'||cc.column_name||'"',',')
                   within group (order by position)
            from   user_cons_columns cc
            where  cc.constraint_name = c.constraint_name
            and    cc.table_name = c.table_name
            and    cc.column_name != 'SECURITY_GROUP_ID'
           ) as column_list
    from user_constraints c
    where c.table_name = fix_unique_constraint.table_name
    and ((fix_unique_constraint.constraint_name is null
           and c.constraint_type = 'U')
         or c.constraint_name = fix_unique_constraint.constraint_name)
    ) loop
    l_ddl := 'alter table "' || r.table_name
      || '" drop constraint "' || r.constraint_name || '"';
    dbms_output.put_line(l_ddl);
    execute immediate l_ddl;
    l_ddl := 'alter table "' || r.table_name
      || '" add constraint "' || r.constraint_name
      || '" ' || r.constraint_type
      || ' (security_group_id,' || r.column_list || ')';
    dbms_output.put_line(l_ddl);
    execute immediate l_ddl;
  end loop;
end fix_unique_constraint;
/
show err
