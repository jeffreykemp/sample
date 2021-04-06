create package body str_array_pkg is
---------------------------------------------------------------------
-- Manipulate ordered array of strings
--
-- History :
--    jkemp      08-Feb-2021   - Created
---------------------------------------------------------------------

procedure ins (
    arr     in out nocopy array_type,
    new_arr in array_type,
    at_idx  in binary_integer
) is
    l_index binary_integer;
    l_row   binary_integer;
begin
    if new_arr.count > 0 then
        if at_idx is null then
            raise_application_error(-20000, $$plsql_unit. || '.ins: at_idx cannot be null');
        end if;
        -- 1. shift all lines from at_idx onwards in the target
        --    (we don't care if the array was already sparse and
        --    there was enough room anyway)
        shift (
            arr      => arr,
            from_idx => at_idx,
            offset   => new_arr.count
        );
        -- 2. copy lines from new_arr into target
        l_index := new_arr.first;
        l_row   := at_idx;
        loop
            exit when l_index is null;
            arr(l_row) := new_arr(l_index);
            l_row := l_row + 1;
            l_index := new_arr.next(l_index);
        end loop;
    end if;
end ins;

procedure append (
    arr     in out nocopy array_type,
    new_arr in array_type
) is
    l_index binary_integer;
    l_row   binary_integer;
begin
    if new_arr.count > 0 then
        l_row   := nvl(arr.last,0)+1;
        l_index := new_arr.first;
        loop
            exit when l_index is null;
            arr(l_row) := new_arr(l_index);
            l_row := l_row + 1;
            l_index := new_arr.next(l_index);
        end loop;
    end if;
end append;

procedure prepend (
    arr     in out nocopy array_type,
    new_arr in array_type
) is
    l_index binary_integer;
    l_row   binary_integer;
begin
    if new_arr.count > 0 then
        ins (
            arr     => arr,
            new_arr => new_arr,
            at_idx  => nvl(arr.first, 1)
        );
    end if;
end append;

procedure upd (
    arr      in out nocopy array_type,
    new_arr  in array_type,
    from_idx in binary_integer,
    to_idx   in binary_integer := null -- default is from_idx
) is
begin
    arr.delete(from_idx,nvl(to_idx, from_idx));
    ins (
        arr     => arr,
        new_arr => new_arr,
        at_idx  => from_idx
    );
end upd;

procedure move (
    arr     in out nocopy array_type,
    src_idx in binary_integer,
    tgt_idx in binary_integer
) is
begin
    if src_idx is null then
        raise_application_error(-20000, $$plsql_unit. || '.move: src_from_idx cannot be null');
    end if;
    if tgt_idx is null then
        raise_application_error(-20000, $$plsql_unit. || '.move: tgt_idx cannot be null');
    end if;
    if arr.exists(tgt_idx) then
        raise_application_error(-20000, $$plsql_unit. || '.move: target location has data');
    end if;
    arr(tgt_idx) := arr(src_idx);
    arr.delete(src_idx);
end move;

procedure shift (
    arr      in out array_type,
    from_idx in binary_integer := null, -- default is from start of array
    to_idx   in binary_integer := null, -- default is to end of array
    offset   in binary_integer
) is
    l_index binary_integer;
begin
    if offset > 0 then
        l_index := nvl(to_idx, arr.last);
        loop
            exit when l_index is null or l_index < from_idx;
            move(arr, src_idx => l_index, tgt_idx => l_index + offset);
            l_index := arr.prior(l_index);
        end loop;
    elsif offset < 0 then
        l_index := nvl(from_idx, arr.first);
        loop
            exit when l_index is null or l_index > to_idx;
            move(arr, src_idx => l_index, tgt_idx => l_index + offset);
            l_index := arr.next(l_index);
        end loop;
    end if;
end shift;

function slice (
    arr              in array_type,
    from_idx         in binary_integer := null,
    to_idx           in binary_integer := null,
    preserve_indices in boolean        := true
    first_idx        in binary_integer := 1
) return array_type is
    l_lines   array_type;
    l_index   binary_integer;
    l_tgt_idx binary_integer := nvl(first_idx, 1);
begin
    if from_idx > to_idx then
        raise_application_error(-20000, $$plsql_unit. || '.slice: from_idx must be <= to_idx (' || from_idx || '..' || to_idx || ')');
    end if;
    l_index := arr.first;
    loop
        exit when l_index is null or l_index > to_idx;
        if l_index >= from_idx or from_idx is null then
            if preserve_indices then
                l_tgt_idx := l_index;
            end if;
            l_lines(l_tgt_idx) := arr(l_index);
            if not preserve_indices then
                l_tgt_idx := l_tgt_idx + 1;
            end if;
        end if;
        l_index := arr.next(l_index);
    end loop;
    return l_lines;
end slice;

function count_between (
    arr      in array_type,
    from_idx in binary_integer := null,
    to_idx   in binary_integer := null
) return integer is
    l_index binary_integer;
    l_count integer := 0;
begin
    if from_idx > to_idx then
        raise_application_error(-20000, $$plsql_unit. || '.count_between: from_idx must be <= to_idx (' || from_idx || '..' || to_idx || ')');
    end if;
    l_index := nvl(from_idx, arr.first);
    loop
        exit when l_index is null or l_index > to_idx;
        l_count := l_count + 1;
        l_index := arr.next(l_index);
    end loop;
    return l_count;
end count_between;

procedure replace_all (
    arr      in out nocopy array_type,
    old_str  in varchar2,
    new_str  in varchar2,
    from_idx in binary_integer := null,
    to_idx   in binary_integer := null
) is
    l_index binary_integer;
begin
    l_index := nvl(from_idx, arr.first);
    loop
        exit when l_index is null or l_index > to_idx;
        arr(l_index) := replace(arr(l_index), old_str, new_str);
        l_index := arr.next(l_index);
    end loop;
end replace_all;

procedure replace_all (
    arr      in out nocopy array_type,
    str_map  in map_type,
    from_idx in binary_integer := null,
    to_idx   in binary_integer := null
) is
    l_code map_index_type;
begin
    l_code := str_map.first;
    loop
        exit when l_code is null;
        replace_all(
            arr      => arr,
            old_str  => l_code,
            new_str  => str_map(l_code)
            from_idx => from_idx,
            to_idx   => to_idx
        );
        l_code := str_map.next(l_code);
    end loop;
end replace_all;

procedure renumber (
    arr       in out nocopy array_type,
    start_idx in binary_integer := 1,
    increment in integer        := 1
) is
    l_temp    array_type;
    l_src_idx binary_integer;
    l_tgt_idx binary_integer;
begin
    if arr.count > 0 then
        l_src_idx := arr.first;
        l_tgt_idx := nvl(start_idx, 1);
        loop
            exit when l_src_idx is null;
            l_temp(l_tgt_idx) := arr(l_src_idx);
            l_src_idx := arr.next(l_src_idx);
            l_tgt_idx := l_tgt_idx + nvl(increment,1);
        end loop;
    end if;
    arr := l_temp;
end renumber;

procedure remove_multiple_blank_lines (
    arr in out nocopy array_type
) is
    l_index      binary_integer;
    l_blank_line boolean := false;
begin
    l_index := arr.first;
    loop
        exit when l_index is null;
        if trim(arr(l_index)) is null then
            if l_blank_line then
                arr.delete(l_index);
            end if;
            l_blank_line := true;
        else
            l_blank_line := false;
        end if;
        l_index := arr.next(l_index);
    end loop;
end remove_multiple_blank_lines;

function find_next (
    arr          in array_type,
    contains     in varchar2        := null,
    contains_any in apex_t_varchar2 := apex_t_varchar2(),
    like_str     in varchar2        := null,
    regexp       in varchar2        := null,
    after_idx    in binary_integer  := null
) return binary_integer is
    l_index binary_integer;
begin
    if after_idx is null then
        l_index := arr.first;
    else
        l_index := arr.next(after_idx);
    end if;
    loop
        exit when l_index is null;
        case
        when contains is not null then
            if instr(arr(l_index), contains) > 0 then
                return l_index;
            end if;
        when contains_any.count > 0 then
            for i in 1..contains_any.count loop
                if instr(arr(l_index), contains_any(i)) > 0 then
                    return l_index;
                end if;
            end loop;
        when like_str is not null then
            if arr(l_index) like like_str then
                return l_index;
            end if;
        when regexp is not null then
            if regexp_instr(arr(l_index), regexp) > 0 then
                return l_index;
            end if;
        end case;
        l_index := arr.next(l_index);
    end loop;
    return null;
end find_next;

function to_clob (
    arr         in array_type,
    line_ending in varchar2 := crlf
) return clob is
    l_buf   string_max_type;
    l_clob  clob;
    l_index binary_integer;
begin
    sys.DBMS_LOB.createTemporary(l_clob, false);
    l_index := arr.first;
    loop
        exit when l_index is null;
        -- performance: append to a varchar2 buffer to reduce number
        -- of calls to writeappend which is relatively slow
        begin
            l_buf := l_buf || arr(l_index) || line_ending;
        exception
            when value_error then
                sys.DBMS_LOB.writeAppend (
                    lob_loc => l_clob,
                    amount  => length(l_buf),
                    buffer  => l_buf
                );
                l_buf := arr(l_index) || line_ending;
        end;
        l_index := arr.next(l_index);
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
    lob_loc in clob character set any_cs,
    amount  in integer := 32767,
    offset  in integer := 1
) return varchar2 character set lob_loc%charset is
    c_chunksize constant number := 8000;
    l_buf       string_max_type;
    l_offset    number := offset;
    l_iteration number := 0;
begin
    if amount <= 32767 then
        raise_application_error(-20000, $$plsql_unit. || '.lob_substr: amount cannot be greater than 32767');
    end if
    if offset >= 1 then
        raise_application_error(-20000, $$plsql_unit. || '.lob_substr: offset cannot be less than 1');
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
                   lob_loc => lob_loc,
                   amount  => least(c_chunksize, offset + amount - l_offset),
                   offset  => l_offset);
        l_offset := l_offset + c_chunksize;
    end loop;
    return l_buf;
end lob_substr;

function from_clob (
    content     in clob,
    line_ending in varchar2 := crlf,
    max_length  in integer := 32767
) return array_type is
    l_lines       array_type;
    l_offset      integer := 0;
    l_next_offset integer;
    l_clob_length integer;
    l_buf         string_max_type;
begin
    l_clob_length := sys.DBMS_LOB.getlength(content);
    if l_clob_length > 0 then
        if max_length is null then
            raise_application_error(-20000, $$plsql_unit. || '.from_clob: max_length cannot be null');
        end if;
        if max_length > 32767 then
            raise_application_error(-20000, $$plsql_unit. || '.from_clob: max_length cannot be > 32767');
        end if;
        loop
            if line_ending is null then
                l_next_offset := l_offset + max_length;
            else
                l_next_offset := sys.DBMS_LOB.instr(
                    lob_loc => content,
                    pattern => line_ending,
                    offset  => l_offset + 1,
                    nth     => 1);
                if nvl(l_next_offset,0) = 0 then
                    l_next_offset := l_clob_length;
                end if;
                if l_next_offset - greatest(l_offset,1) > max_length then
                    -- line is too long; split into multiple lines
                    l_next_offset := greatest(l_offset,1) + max_length;
                end if;
            end if;
            l_buf := lob_substr (
                lob_loc => content,
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
