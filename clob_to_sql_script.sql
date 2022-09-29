function clob_to_sql_script (
    p_clob           in varchar2,
    p_procedure_name in varchar2,
    p_chunk_size     in integer := 8191
) return clob is

-- Takes a CLOB, returns a SQL script that will call the given procedure
-- with that clob as its parameter.

    l_strings apex_t_varchar2;
    l_chunk   varchar2(32767);
    l_offset  integer;        

begin

    apex_string.push(
        l_strings,
        q'[
declare
l_strings apex_t_varchar2;
procedure p (p_string in varchar2) is
begin
    apex_string.push(l_strings, p_string);
end p;
begin
]');
    
    while apex_string.next_chunk (
        p_str    => p_clob,
        p_chunk  => l_chunk,
        p_offset => l_offset,
        p_amount => p_chunk_size )
    loop
        apex_string.push(
            l_strings,
            q'[p(q'~]'
            || l_chunk
            || q'[~');]');
    end loop;    

    apex_string.push(
        l_strings,
        replace(q'[
    #PROC#(apex_string.join_clob(l_strings));
end;
]',
            '#PROC#', p_procedure_name)
        || '/');

    return apex_string.join_clob(l_strings);
end clob_to_sql_script;