prompt sync_comments_lt_to_view.sql
-- synchronize column comments from MYTABLE_LT (OWM table) to MYTABLE (view)
begin
for r in (
  select nvl(lt.column_name,vt.column_name) as column_name
        ,vt.table_name v_table_name
        ,lt.comments
        ,vt.comments v_comments
  from user_col_comments lt
  full outer join user_col_comments vt
  on lt.table_name = vt.table_name || '_LT'
  and vt.column_name = lt.column_name
  where vt.table_name = :VIEW_NAME /*name of the OWM-managed view*/
  and nvl(lt.comments,vt.comments) is not null /*no change if neither side has comments*/
) loop
  if nvl(r.comments,'~!@#$NULL%^&*()') != nvl(r.v_comments,'~!@#$NULL%^&*()') then
    execute immediate 'comment on column "'
      || r.v_table_name || '"."' || r.column_name
      || '" is ''' || replace(r.comments,'''','''''') || '''';
  end if;
end loop;
end;
/
