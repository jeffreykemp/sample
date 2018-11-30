set serverout on
-- explain an MV
declare
  arr sys.explainmvarraytype;
begin
  dbms_mview.explain_mview(:mview_name, msg_array => arr);
  for i in 1..arr.count loop
    dbms_output.put_line(
      arr(i).capability_name
      || ': '
      || case arr(i).possible when 'T' then 'Yes' when 'F' then 'No' end
      || '. '
      || arr(i).msgtxt || ' [QSM-' || to_char(arr(i).msgno,'fm00000') || ']'
      || ' (' || trim(arr(i).related_text || ' ' || arr(i).related_num) || ') '
      );
  end loop;
end;
/
