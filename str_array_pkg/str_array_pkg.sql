create package str_array_pkg is
---------------------------------------------------------------------
-- Manipulate ordered array of strings
--
-- History :
--    jkemp      08-Feb-2021   - Created
---------------------------------------------------------------------

type array_type is table of varchar2(32767) index by binary_integer;
type map_type   is table of varchar2(32767) index by varchar2(255);

c_crlf constant varchar2(2) := chr(13) || chr(10);

-------------------------------------------------------------------
-- Insert an array into another array at a particular position
-------------------------------------------------------------------
procedure ins (
    p_lines_io in out nocopy array_type,
    p_new      in array_type,
    p_at_idx   in binary_integer
);

-------------------------------------------------------------------
-- Insert all elements of the array on the end of the first
-------------------------------------------------------------------
procedure append (
    p_lines_io in out nocopy array_type,
    p_new      in array_type
);

-------------------------------------------------------------------
-- Insert all elements of the array at the start of the first
-------------------------------------------------------------------
procedure prepend (
    p_lines_io in out nocopy array_type,
    p_new      in array_type
);

-------------------------------------------------------------------
-- Insert an array into another array, replacing the lines at the
-- given range
-------------------------------------------------------------------
procedure upd (
    p_lines_io in out nocopy array_type,
    p_new      in array_type,
    p_from_idx in binary_integer,
    p_to_idx   in binary_integer := null -- default is p_from_idx
);

-------------------------------------------------------------------
-- Move one line from one location to another.
-- Raises exception if the target location already has data.
-------------------------------------------------------------------
procedure move (
    p_lines_io in out nocopy array_type,
    p_src_idx  in binary_integer,
    p_tgt_idx  in binary_integer
);

-------------------------------------------------------------------
-- Shift all strings between the given range by the given offset
-- Does nothing if p_offset is null or zero
-------------------------------------------------------------------
procedure shift (
    p_lines_io in out nocopy array_type,
    p_from_idx in binary_integer := null, -- default is from start of array
    p_to_idx   in binary_integer := null, -- default is to end of array
    p_offset   in binary_integer
);

-------------------------------------------------------------------
-- Get a range of strings from within an array
-- If p_preserve_indices = true, the array indices are preserved
-- If p_preserve_indices = false, the array indices will start from
-- 1 (or p_first_idx) up to number of lines.
-------------------------------------------------------------------
function slice (
    p_lines            in array_type,
    p_from_idx         in binary_integer := null,
    p_to_idx           in binary_integer := null,
    p_preserve_indices in boolean        := true
    p_first_idx        in binary_integer := 1
) return array_type;

-------------------------------------------------------------------
-- Count the number of lines between the given indices (inclusive)
-------------------------------------------------------------------
function count_between (
    p_lines    in array_type,
    p_from_idx in binary_integer := null,
    p_to_idx   in binary_integer := null
) return integer;

-------------------------------------------------------------------
-- Perform the substitution on all the lines in the array
-------------------------------------------------------------------
procedure replace_all (
    p_lines_io in out nocopy array_type,
    p_old      in varchar2,
    p_new      in varchar2,
    p_from_idx in binary_integer := null,
    p_to_idx   in binary_integer := null
);

-------------------------------------------------------------------
-- Perform the substitutions on all the lines in the array
-------------------------------------------------------------------
procedure replace_all (
    p_lines_io in out nocopy array_type,
    p_str_map  in map_type,
    p_from_idx in binary_integer := null,
    p_to_idx   in binary_integer := null
);

-------------------------------------------------------------------
-- Move the array indices according to the new starting index
-- and increment. May be used to remove gaps.
-------------------------------------------------------------------
procedure renumber (
    p_lines_io  in out nocopy array_type,
    p_start_idx in binary_integer := 1,
    p_increment in integer        := 1
);

-------------------------------------------------------------------
-- Compress consecutive blank lines
-------------------------------------------------------------------
procedure remove_multiple_blank_lines (
    p_lines_io in out nocopy array_type
);

-------------------------------------------------------------------
-- Find the next occurrence of a token in the given array.
-- Returns the index into the array.
-- Search can be for a single token, any token in a list of tokens,
-- or an expression.
-------------------------------------------------------------------
function find_next (
    p_lines     in array_type,
    p_token     in varchar2        := null,
    p_tokens    in apex_t_varchar2 := apex_t_varchar2(),
    p_like      in varchar2        := null,
    p_regexp    in varchar2        := null,
    p_after_idx in binary_integer  := null
) return binary_integer;

-------------------------------------------------------------------
-- Combine the array of lines into a clob
-------------------------------------------------------------------
function to_clob (
    p_lines       in array_type,
    p_line_ending in varchar2 := c_crlf
) return clob;

-------------------------------------------------------------------
-- Split the clob into lines
-- Similar to apex_string.split(2)
-- Maximum line length is p_max_length (<=32767); if a
-- line is longer than the max, it will be split up.
-- If p_line_ending is null, splits the clob into fixed-length
-- lines.
-------------------------------------------------------------------
function from_clob (
    p_clob        in clob,
    p_line_ending in varchar2 := c_crlf,
    p_max_length  in integer := 32767
) return array_type;

end str_array_pkg;
/
