create table fonticons (
    library                        varchar2(100) not null,
    class                          varchar2(10) not null,
    icon                           varchar2(100) not null,
    constraint fonticons_pk primary key (library, class, icon)
);
