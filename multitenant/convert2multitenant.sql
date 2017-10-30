create or replace procedure convert2multitenant (table_name in varchar2) is 
-- add security_group_id and related trigger to a table

  v_trigger_name         varchar2(30);
  v_fk_name              varchar2(30);

  -- suffixes to derive object names 
  trigger_suffix         constant varchar2(30) := '$TRG'; 
  fk_suffix              constant varchar2(10) := '$SECFK';

  -- template for trigger
  create_trigger         constant varchar2(4000) := q'[
create trigger #TRIGGER#
before insert or update or delete on #TABLE#
for each row
begin
  if updating or deleting then
    security_pkg.validate
      (security_group_id => :old.security_group_id);
  end if;
  if inserting then
    :new.security_group_id := sys_context('CTX','SECURITY_GROUP_ID');
  end if;
  if inserting or updating then
    security_pkg.validate
      (security_group_id => :new.security_group_id);
  end if;
end #TRIGGER#;]'; 

  procedure add_sec_column is
  begin
    execute immediate replace(
      q'[alter table #TABLE# add security_group_id
         integer default sys_context('CTX','SECURITY_GROUP_ID') not null]'
      ,'#TABLE#', table_name);
  exception
    when others then
      if sqlcode != -1430 then
        raise;
      end if;
  end add_sec_column;

  procedure add_sec_constraint (constraint_name in varchar2) is
  begin
    execute immediate replace(replace(
      q'[alter table #TABLE# add constraint #CONSTRAINT#
         foreign key (security_group_id)
         references security_groups (security_group_id)]'
      ,'#TABLE#', table_name)
      ,'#CONSTRAINT#', constraint_name);
  exception
    when others then
      if sqlcode != -2275 then
        raise;
      end if;
  end add_sec_constraint;

begin 

  if sys_context('CTX','SECURITY_GROUP_ID') is null then
    raise_application_error(-20128,'Security group ID not set');
  end if;

  v_trigger_name := substr(replace(table_name,'$B',''),1,30-length(trigger_suffix)) || trigger_suffix;
  v_fk_name := substr(replace(table_name,'$B',''),1,30-length(fk_suffix)) || fk_suffix;

  -- add security_group_id column
  add_sec_column;

  -- add fk constraint to security_groups table
  add_sec_constraint(v_fk_name);

  -- add trigger to validate/set security_group_id
  execute immediate replace(replace(create_trigger
    ,'#TABLE#', table_name)
    ,'#TRIGGER#', v_trigger_name);

end convert2multitenant;
/
show errors
