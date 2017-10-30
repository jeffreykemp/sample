create sequence security_group_id_seq;

create table security_group
( security_group_id number not null
, name varchar2(100) not null
, active_ind varchar2(1) default 'Y'
, constraint security_group_pk primary key (security_group_id)
, constraint security_group_name_uk unique (name)
, constraint security_group_active_ck check (active_ind = 'Y')
);

create table security_group_member
( security_group_id number not null
, app_user varchar2(200) not null
, last_login date
, active_ind varchar2(1) default 'Y'
, constraint security_group_member_pk primary key (security_group_id, app_user)
, constraint security_group_member_fk foreign key (security_group_id) references security_group (security_group_id)
, constraint security_group_member_active_ck check (active_ind = 'Y')
);

create table security_role
( role_code varchar2(100) not null
, name varchar2(100) not null
, active_ind varchar2(1) default 'Y'
, constraint security_role_pk primary key (role_code)
, constraint security_role_name_uk unique (name)
, constraint security_role_active_ck check (active_ind = 'Y')
);

create table security_group_role
( security_group_id number not null
, app_user varchar2(200) not null
, role_code varchar2(100) not null
, active_ind varchar2(1) default 'Y'
, constraint security_group_role_pk primary key (security_group_id, app_user, role_code)
, constraint security_group_role_fk foreign key (security_group_id, app_user) references security_group_member (security_group_id, app_user)
, constraint security_group_role_fk2 foreign key (role_code)
             references security_role (role_code)
, constraint security_group_role_activ_ck check (active_ind = 'Y')
);

insert into security_role values ('ADMIN','Admin','Y');
insert into security_role values ('EDITOR','Editor','Y');
insert into security_role values ('VIEW','View','Y');
insert into security_group values (security_group_id_seq.nextval,'jk64');
insert into security_group_member values (security_group_id_seq.currval,'JEFF',null,'Y');
insert into security_group_role values (security_group_id_seq.currval,'JEFF','ADMIN','Y');
