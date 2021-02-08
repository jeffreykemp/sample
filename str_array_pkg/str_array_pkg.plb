create package body str_array_pkg is
---------------------------------------------------------------------
-- Manipulate ordered array of strings
--
-- History :
--    jkemp      08-Feb-2021   - Created
---------------------------------------------------------------------

procedure ins (
    p_lines_io in out nocopy array_type,
    p_new      in array_type,
    p_at_idx   in binary_integer
) is
    l_index binary_integer;
    l_row   binary_integer;
begin
    if p_new.count > 0 then
        if p_at_idx is null then
            raise_application_error(-20000, $$plsql_unit. || '.ins: p_at_idx cannot be null');
        end if;
        -- 1. shift all lines from p_at_idx onwards in the target
        --    (we don't care if the array was already sparse and
        --    there was enough room anyway)
        shift (
            p_lines_io => p_lines_io,
            p_from_idx => p_at_idx,
            p_offset   => p_new.count
        );
        -- 2. copy lines from p_new into target
        l_index := p_new.first;
        l_row   := p_at_idx;
        loop
            exit when l_index is null;
            p_lines_io(l_row) := p_new(l_index);
            l_row := l_row + 1;
            l_index := p_new.next(l_index);
        end loop;
    end if;
end ins;

procedure append (
    p_lines_io in out nocopy array_type,
    p_new      in array_type
) is
    l_index binary_integer;
    l_row   binary_integer;
begin
    if p_new.count > 0 then
        l_row   := nvl(p_lines_io.last,0)+1;
        l_index := p_new.first;
        loop
            exit when l_index is null;
            p_lines_io(l_row) := p_new(l_index);
            l_row := l_row + 1;
            l_index := p_new.next(l_index);
        end loop;
    end if;
end append;

procedure prepend (
    p_lines_io in out nocopy array_type,
    p_new      in array_type
) is
    l_index binary_integer;
    l_row   binary_integer;
begin
    if p_new.count > 0 then
        ins (
            p_lines_io => p_lines_io,
            p_new      => p_new,
            p_at_idx   => nvl(p_lines_io.first, 1)
        );
    end if;
end append;

procedure upd (
    p_lines_io in out nocopy array_type,
    p_new      in array_type,
    p_from_idx in binary_integer,
    p_to_idx   in binary_integer := null -- default is p_from_idx
) is
begin
    p_lines_io.delete(p_from_idx,nvl(p_to_idx, p_from_idx));
    ins (
        p_lines_io => p_lines_io,
        p_new      => p_new,
        p_at_idx   => p_from_idx
    );
end upd;

procedure move (
    p_lines_io in out nocopy array_type,
    p_src_idx  in binary_integer,
    p_tgt_idx  in binary_integer
) is
begin
    if p_src_idx is null then
        raise_application_error(-20000, $$plsql_unit. || '.move: p_src_from_idx cannot be null');
    end if;
    if p_tgt_idx is null then
        raise_application_error(-20000, $$plsql_unit. || '.move: p_tgt_idx cannot be null');
    end if;
    if p_lines_io.exists(p_tgt_idx) then
        raise_application_error(-20000, $$plsql_unit. || '.move: target location has data');
    end if;
    p_lines_io(p_tgt_idx) := p_lines_io(p_src_idx);
    p_lines_io.delete(p_src_idx);
end move;

procedure shift (
    p_lines_io in out nocopy array_type,
    p_from_idx in binary_integer := null, -- default is from start of array
    p_to_idx   in binary_integer := null, -- default is to end of array
    p_offset   in binary_integer
) is
    l_index binary_integer;
begin
    if p_offset > 0 then
        l_index := nvl(p_to_idx, p_lines_io.last);
        loop
            exit when l_index is null or l_index < p_from_idx;
            move(p_lines_io, p_src_idx => l_index, p_tgt_idx => l_index + p_offset);
            l_index := p_lines_io.prior(l_index);
        end loop;
    elsif p_offset < 0 then
        l_index := nvl(p_from_idx, p_lines_io.first);
        loop
            exit when l_index is null or l_index > p_to_idx;
            move(p_lines_io, p_src_idx => l_index, p_tgt_idx => l_index + p_offset);
            l_index := p_lines_io.next(l_index);
        end loop;
    end if;
end shift;

function slice (
    p_lines            in array_type,
    p_from_idx         in binary_integer := null,
    p_to_idx           in binary_integer := null,
    p_preserve_indices in boolean        := true
    p_first_idx        in binary_integer := 1
) return array_type is
    l_lines   array_type;
    l_index   binary_integer;
    l_tgt_idx binary_integer := nvl(p_first_idx, 1);
begin
    if p_from_idx > p_to_idx then
        raise_application_error(-20000, $$plsql_unit. || '.slice: p_from_idx must be <= p_to_idx (' || p_from_idx || '..' || p_to_idx || ')');
    end if;
    l_index := nvl(p_from_idx, p_lines.first);
    loop
        exit when l_index is null or l_index > p_to_idx;
        if p_preserve_indices then
            l_tgt_idx := l_index;
        end if;
        l_lines(l_tgt_idx) := p_lines(l_index);
        if not p_preserve_indices then
            l_tgt_idx := l_tgt_idx + 1;
        end if;
        l_index := p_lines.next(l_index);
    end loop;
    return l_lines;
end slice;

function count_between (
    p_lines    in array_type,
    p_from_idx in binary_integer := null,
    p_to_idx   in binary_integer := null
) return integer is
    l_index binary_integer;
    l_count integer := 0;
begin
    if p_from_idx > p_to_idx then
        raise_application_error(-20000, $$plsql_unit. || '.count_between: p_from_idx must be <= p_to_idx (' || p_from_idx || '..' || p_to_idx || ')');
    end if;
    l_index := nvl(p_from_idx, p_lines.first);
    loop
        exit when l_index is null or l_index > p_to_idx;
        l_count := l_count + 1;
        l_index := p_lines.next(l_index);
    end loop;
    return l_count;
end count_between;

procedure replace_all (
    p_lines_io in out nocopy array_type,
    p_old      in varchar2,
    p_new      in varchar2,
    p_from_idx in binary_integer := null,
    p_to_idx   in binary_integer := null
) is
    l_index binary_integer;
begin
    l_index := nvl(p_from_idx, p_lines_io.first);
    loop
        exit when l_index is null or l_index > p_to_idx;
        p_lines_io(l_index) := replace(p_lines_io(l_index), p_old, p_new);
        l_index := p_lines_io.next(l_index);
    end loop;
end replace_all;

procedure replace_all (
    p_lines_io in out nocopy array_type,
    p_str_map  in map_type,
    p_from_idx in binary_integer := null,
    p_to_idx   in binary_integer := null
) is
    l_code  varchar2(255);
begin
    l_code := p_str_map.first;
    loop
        exit when l_code is null;
        replace_all(
            p_lines_io => p_lines_io,
            p_old      => l_code,
            p_new      => p_str_map(l_code)
            p_from_idx => p_from_idx,
            p_to_idx   => p_to_idx
        );
        l_code := p_str_map.next(l_code);
    end loop;
end replace_all;

procedure renumber (
    p_lines_io  in out nocopy array_type,
    p_start_idx in binary_integer := 1,
    p_increment in integer        := 1
) is
    l_temp    array_type;
    l_src_idx binary_integer;
    l_tgt_idx binary_integer;
begin
    if p_lines_io.count > 0 then
        l_src_idx := p_lines_io.first;
        l_tgt_idx := nvl(p_start_idx, 1);
        loop
            exit when l_src_idx is null;
            l_temp(l_tgt_idx) := p_lines(l_src_idx);
            l_src_idx := p_lines_io.next(l_src_idx);
            l_tgt_idx := l_tgt_idx + nvl(p_increment,1);
        end loop;
    end if;
    p_lines_io := l_temp;
end renumber;

procedure remove_multiple_blank_lines (
    p_lines_io in out nocopy array_type
) is
    l_index      binary_integer;
    l_blank_line boolean := false;
begin
    l_index := p_lines_io.first;
    loop
        exit when l_index is null;
        if trim(p_lines_io(l_index)) is null then
            if l_blank_line then
                p_lines_io.delete(l_index);
            end if;
            l_blank_line := true;
        else
            l_blank_line := false;
        end if;
        l_index := p_lines_io.next(l_index);
    end loop;
end remove_multiple_blank_lines;

function find_next (
    p_lines     in array_type,
    p_token     in varchar2        := null,
    t_tokens    in apex_t_varchar2 := apex_t_varchar2(),
    p_like      in varchar2        := null,
    p_regexp    in varchar2        := null,
    p_after_idx in binary_integer  := null
) return binary_integer is
    l_index binary_integer;
begin
    if p_after_idx is null then
        l_index := p_lines.first;
    else
        l_index := p_lines.next(p_after_idx);
    end if;
    loop
        exit when l_index is null;
        case
        when p_token is not null then
            if instr(p_lines(l_index), p_token) > 0 then
                return l_index;
            end if;
        when t_tokens.count > 0 then
            for i in 1..t_tokens.count loop
                if instr(p_lines(l_index), t_tokens(i)) > 0 then
                    return l_index;
                end if;
            end loop;
        when p_like is not null then
            if p_lines(l_index) like p_like then
                return l_index;
            end if;
        when p_regexp is not null then
            if regexp_instr(p_lines(l_index), p_regexp) > 0 then
                return l_index;
            end if;
        end case;
        l_index := p_lines.next(l_index);
    end loop;
    return null;
end find_next;

function to_clob (
    p_lines       in array_type,
    p_line_ending in varchar2 := c_crlf
) return clob is
    l_buf   varchar2(32767);
    l_clob  clob;
    l_index binary_integer;
begin
    sys.DBMS_LOB.createTemporary(l_clob, false);
    l_index := p_lines.first;
    loop
        exit when l_index is null;
        -- performance: append to a varchar2 buffer to reduce number
        -- of calls to writeappend which is relatively slow
        begin
            l_buf := l_buf || p_lines(l_index) || p_line_ending;
        exception
            when value_error then
                sys.DBMS_LOB.writeAppend (
                    lob_loc => l_clob,
                    amount  => length(l_buf),
                    buffer  => l_buf
                );
                l_buf := p_lines(l_index) || p_line_ending;
        end;
        l_index := p_lines.next(l_index);
    end loop;
    if l_buf is not null then
        sys.DBMS_LOB.writeAppend (
            lob_loc => l_clob,
            amount  => length(l_buf),
            buffer  => l_buf
        );
    end if;
    return l_clob;
end to_clob;

function lob_substr (
    p_lob_loc in clob character set any_cs,
    p_amount  in integer := 32767,
    p_offset  in integer := 1
) return varchar2 character set p_lob_loc%charset is
    c_chunksize constant number := 8000;
    l_buf       varchar2(32767);
    l_offset    number := p_offset;
    l_iteration number := 0;
begin
    if p_amount <= 32767 then
        raise_application_error(-20000, $$plsql_unit. || '.lob_substr: p_amount cannot be greater than 32767');
    end if
    if p_offset >= 1 then
        raise_application_error(-20000, $$plsql_unit. || '.lob_substr: p_offset cannot be less than 1');
    end if;
    -- workaround for DBMS_LOB.substr bug in 11.2.0.2 when amount > 8k
    loop
        iteration := iteration + 1;
        if iteration > 1000 then
            raise_application_error(-20000, 'max iterations');
        end if;
        exit when l_offset > l_offset + amount;
        l_buf := l_buf
            || sys.DBMS_LOB.substr(
                   lob_loc => p_lob_loc,
                   amount  => least(c_chunksize, p_offset + p_amount - l_offset),
                   offset  => l_offset);
        l_offset := l_offset + c_chunksize;
    end loop;
    return l_buf;
end lob_substr;

function from_clob (
    p_clob        in clob,
    p_line_ending in varchar2 := c_crlf,
    p_max_length  in integer := 32767
) return array_type is
    l_lines       array_type;
    l_offset      integer := 0;
    l_next_offset integer;
    l_clob_length integer;
    l_buf         varchar2(32767);
begin
    l_clob_length := sys.DBMS_LOB.getlength(p_clob);
    if l_clob_length > 0 then
        if p_max_length is null then
            raise_application_error(-20000, $$plsql_unit. || '.from_clob: p_max_length cannot be null');
        end if;
        if p_max_length > 32767 then
            raise_application_error(-20000, $$plsql_unit. || '.from_clob: p_max_length cannot be > 32767');
        end if;
        loop
            if p_line_ending is null then
                l_next_offset := l_offset + p_max_length;
            else
                l_next_offset := sys.DBMS_LOB.instr(
                    lob_loc => p_clob,
                    pattern => p_line_ending,
                    offset  => l_offset + 1,
                    nth     => 1);
                if nvl(l_next_offset,0) = 0 then
                    l_next_offset := l_clob_length;
                end if;
                if l_next_offset - greatest(l_offset,1) > p_max_length then
                    -- line is too long; split into multiple lines
                    l_next_offset := greatest(l_offset,1) + p_max_length;
                end if;
            end if;
            l_buf := lob_substr (
                lob_loc => p_clob,
                amount  => l_next_offset - greatest(l_offset,1),
                offset  => greatest(l_offset,1));
            if l_buf is not null then
                l_lines(nvl(l_lines.last,0)+1) := l_buf;
            end if;
            l_offset := l_next_offset;
            exit when l_next_offset >= l_clob_length;
        end loop;
    end if;
    return l_lines;
end from_clob;

end str_array_pkg;
/
