create or replace package mv_util_pkg as

-- refresh a list of materialized views
-- e.g. refresh_mview_list('EMP_MV,SALES_MV')
procedure refresh_mview_list (list in varchar2);

-- refresh materialized views selected from the APEX report
procedure refresh_selected_mviews;

-- refresh all the materialized views
procedure refresh_all_mviews;

end mv_util_pkg;
/
show err

create or replace package body mv_util_pkg as

-- refresh a list of materialized views
-- e.g. refresh_mview_list('EMP_MV,SALES_MV')
procedure refresh_mview_list (list in varchar2) is
  no_failures number;
  l_list varchar2(32767);
begin
  apex_debug.message($$plsql_unit||'.refresh_mview_list: ' || list);

  if list is not null then

    -- list must include the owner for each object
    l_list := $$plsql_unit_owner || '.'
           || replace(list, ',', ',' || $$plsql_unit_owner || '.');

    apex_debug.message('dbms_mview.refresh: ' || l_list);

    dbms_mview.refresh
      (list   => l_list
      ,nested => true);

    apex_debug.message('dbms_mview.refresh_dependent: ' || l_list);

    dbms_mview.refresh_dependent
      (number_of_failures => no_failures
      ,list               => l_list
      ,nested             => true);

    apex_debug.message('failures: ' || no_failures);

  end if;

end refresh_mview_list;


-- refresh materialized views selected from the APEX report
procedure refresh_selected_mviews is
  no_failures number;
  list varchar2(32767);
begin
  apex_debug.message($$plsql_unit||'.refresh_selected_mviews: '
    || apex_application.g_f01.count);

  for i in 1..apex_application.g_f01.count loop

    apex_debug.message('add to list: '
      || apex_application.g_f01(i)
      || ' (' || i || ')');
    if list is not null then list := list || ','; end if;
    list := list || apex_application.g_f01(i);

  end loop;

  refresh_mview_list(list);

end refresh_selected_mviews;

-- refresh all the materialized views
procedure refresh_all_mviews is
  no_failures number;
begin
  apex_debug.message($$plsql_unit||'.dbms_mview.refresh_all_mviews');

  dbms_mview.refresh_all_mviews
    (number_of_failures => no_failures);

  apex_debug.message('failures: ' || no_failures);
end refresh_all_mviews;

end mv_util_pkg;
/
show err
