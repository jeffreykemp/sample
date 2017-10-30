create or replace package security_pkg is

C_CTX constant varchar2(30) := 'CTX';

procedure init
  (app_user          in varchar2 := null
  ,security_group_id in security_groups.security_group_id%type := null
  ,apex              in boolean := true
  );

function user_has_role (role_code in security_roles.role_code%type) return boolean;

procedure validate (security_group_id in security_groups.security_group_id%type);

procedure reset;

end security_pkg;
/
show err

create or replace package body security_pkg is

C_APP_USER          constant varchar2(30) := 'APP_USER';
C_SECURITY_GROUP_ID constant varchar2(30) := 'SECURITY_GROUP_ID';
C_ADMIN             constant varchar2(30) := 'ADMIN';

procedure sctx
  (attr in varchar2
  ,val  in varchar2
  ,apex in boolean) is
begin
  if apex then
    dbms_session.set_context
      (namespace => C_CTX
      ,attribute => attr
      ,value     => val
      ,client_id => v('APP_USER') || ':' || v('SESSION'));
  else
    dbms_session.set_context
      (namespace => C_CTX
      ,attribute => attr
      ,value     => val
      ,username  => user);
  end if;
end sctx;

--============================================================
--                       PUBLIC METHODS
--============================================================

-- called after authentication to set up a session
procedure init
  (app_user          in varchar2 := null
  ,security_group_id in security_groups.security_group_id%type := null
  ,apex              in boolean := true
  ) is
  cursor c
    (security_group_id in security_groups.security_group_id%type
    ,app_user          in security_group_members.app_user%type
    ) is
    select x.*
    from   security_group_members x
    join   security_groups g
    on     g.security_group_id = x.security_group_id
    where  x.app_user = c.app_user
    and    (x.security_group_id = c.security_group_id
            or c.security_group_id is null)
    and    x.active_ind = 'Y'
    and    g.active_ind = 'Y'
    order by x.last_login desc nulls last;
  r c%rowtype;
begin
  open c
    (security_group_id => security_group_id
    ,app_user          => coalesce(app_user, v('APP_USER'))
    );
  fetch c into r;
  close c;

  sctx(C_APP_USER, r.app_user, apex);
  sctx(C_SECURITY_GROUP_ID, r.security_group_id, apex);

  if apex
  and r.app_user is not null
  and r.security_group_id is not null then
    update security_group_members m
    set    last_login = sysdate
    where  m.security_group_id = r.security_group_id
    and    m.app_user = r.app_user;
  end if;

end init;

-- used by authorization schemes
function user_has_role (role_code in security_roles.role_code%type) return boolean is
  dummy number;
begin
  select 1 into dummy
  from   security_group_roles r
  join   security_roles sr on sr.role_code = r.role_code
  where  r.security_group_id = sys_context(C_CTX,C_SECURITY_GROUP_ID)
  and    r.app_user = sys_context(C_CTX,C_APP_USER)
  and    r.role_code in (user_has_role.role_code,C_ADMIN)
  and    r.active_ind = 'Y'
  and    sr.active_ind = 'Y'
  and rownum = 1;
  return true;
exception
  when no_data_found then
    return false;
end user_has_role;

-- used by table triggers to stop unauthorised modifications
procedure validate (security_group_id in security_groups.security_group_id%type) is
begin
  if sys_context(C_CTX,C_SECURITY_GROUP_ID) is null then
    raise_application_error(-20128,
      'Security group ID not initialised');
  end if;
  if security_group_id is null
  or security_group_id != sys_context(C_CTX,C_SECURITY_GROUP_ID) then
    raise_application_error(-20129,
      'Invalid security group ID');
  end if;
end validate;

-- clear the session; useful for running test cases
procedure reset is
begin
  dbms_session.clear_all_context(C_CTX);
end reset;

end security_pkg;
/
show err
