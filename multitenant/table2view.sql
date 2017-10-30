create or replace procedure table2view (table_name in varchar2) is
-- Convert a table to a hidden base table + view with "poor-man's VPD" for security
  l_table_name varchar2(30);
  l_columns varchar2(32767);
begin
  l_table_name := upper(substr(table_name,1,30-length('$B')) || '$B');
  begin
    execute immediate 'alter table '||table_name||' rename to ' || l_table_name;
  exception
    when others then
      -- if the table doesn't exist, it was probably already converted; so we
      -- don't error out and recreate the view
      if sqlcode!=-942 then
        raise;
      end if;
  end;
  for r in (select column_name 
            from   user_tab_columns 
            where  table_name = table2view.l_table_name
            and    column_name != 'SECURITY_GROUP_ID'
            order by column_id) loop
    if l_columns is not null then
      l_columns := l_columns || ',';
    end if;
    l_columns := l_columns || 'x.' || lower(r.column_name); 
  end loop;
  execute immediate replace(replace(replace(q'[
    create or replace force view #VIEW#
    as select #COLUMNS#
       from #TABLE# x
       where x.security_group_id = sys_context('CTX','SECURITY_GROUP_ID')
       with check option
    ]','#VIEW#',table_name)
      ,'#COLUMNS#',l_columns)
      ,'#TABLE#',l_table_name);
end table2view;
/
show err
