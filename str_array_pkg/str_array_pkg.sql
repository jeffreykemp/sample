create package str_array_pkg is
---------------------------------------------------------------------
-- Manipulate ordered array of strings
--
-- History :
--    jkemp      08-Feb-2021   - Created
---------------------------------------------------------------------

subtype string_max_type is varchar2(32767);
subtype map_index_type is varchar2(255);
type array_type is table of string_max_type index by binary_integer;
type map_type   is table of string_max_type index by map_index_type;

crlf constant varchar2(2) := chr(13) || chr(10);

-------------------------------------------------------------------
-- Insert an array into another array at a particular position
-------------------------------------------------------------------
procedure ins (
    arr     in out nocopy array_type,
    new_arr in array_type,
    at_idx  in binary_integer
);

-------------------------------------------------------------------
-- Insert all elements of the array on the end of the first
-------------------------------------------------------------------
procedure append (
    arr     in out nocopy array_type,
    new_arr in array_type
);

-------------------------------------------------------------------
-- Insert all elements of the array at the start of the first
-------------------------------------------------------------------
procedure prepend (
    arr     in out nocopy array_type,
    new_arr in array_type
);

-------------------------------------------------------------------
-- Insert an array into another array, replacing the lines at the
-- given range
-------------------------------------------------------------------
procedure upd (
    arr      in out nocopy array_type,
    new_arr  in array_type,
    from_idx in binary_integer,
    to_idx   in binary_integer := null -- default is from_idx
);

-------------------------------------------------------------------
-- Move one line from one location to another.
-- Raises exception if the target location already has data.
-------------------------------------------------------------------
procedure move (
    arr     in out nocopy array_type,
    src_idx in binary_integer,
    tgt_idx in binary_integer
);

-------------------------------------------------------------------
-- Shift all strings between the given range by the given offset
-- Does nothing if offset is null or zero
-------------------------------------------------------------------
procedure shift (
    arr      in out nocopy array_type,
    from_idx in binary_integer := null, -- default is from start of array
    to_idx   in binary_integer := null, -- default is to end of array
    offset   in binary_integer
);

-------------------------------------------------------------------
-- Get a range of strings from within an array
-- If preserve_indices = true, the array indices are preserved
-- If preserve_indices = false, the array indices will start from
-- 1 (or first_idx) up to number of lines.
-------------------------------------------------------------------
function slice (
    arr              in array_type,
    from_idx         in binary_integer := null,
    to_idx           in binary_integer := null,
    preserve_indices in boolean        := true
    first_idx        in binary_integer := 1
) return array_type;

-------------------------------------------------------------------
-- Count the number of lines between the given indices (inclusive)
-------------------------------------------------------------------
function count_between (
    arr      in array_type,
    from_idx in binary_integer := null,
    to_idx   in binary_integer := null
) return integer;

-------------------------------------------------------------------
-- Perform the substitution on all the lines in the array
-------------------------------------------------------------------
procedure replace_all (
    arr      in out nocopy array_type,
    old_str  in varchar2,
    new_str  in varchar2,
    from_idx in binary_integer := null,
    to_idx   in binary_integer := null
);

-------------------------------------------------------------------
-- Perform the substitutions on all the lines in the array
-------------------------------------------------------------------
procedure replace_all (
    arr      in out nocopy array_type,
    str_map  in map_type,
    from_idx in binary_integer := null,
    to_idx   in binary_integer := null
);

-------------------------------------------------------------------
-- Move the array indices according to the new starting index
-- and increment. May be used to remove gaps.
-------------------------------------------------------------------
procedure renumber (
    arr       in out nocopy array_type,
    start_idx in binary_integer := 1,
    increment in integer        := 1
);

-------------------------------------------------------------------
-- Compress consecutive blank lines
-------------------------------------------------------------------
procedure remove_multiple_blank_lines (
    arr in out nocopy array_type
);

-------------------------------------------------------------------
-- Find the next occurrence of something in the given array.
-- Returns the index into the array.
-- Search can be for a single string, any string in a list of
-- strings, or an expression.
-------------------------------------------------------------------
function find_next (
    arr          in array_type,
    contains     in varchar2        := null,
    contains_any in apex_t_varchar2 := apex_t_varchar2(),
    like_str     in varchar2        := null,
    regexp       in varchar2        := null,
    after_idx    in binary_integer  := null
) return binary_integer;

-------------------------------------------------------------------
-- Combine the array of lines into a clob
-------------------------------------------------------------------
function to_clob (
    arr         in array_type,
    line_ending in varchar2 := crlf
) return clob;

-------------------------------------------------------------------
-- Split the clob into lines
-- Similar to apex_string.split(2)
-- Maximum line length is max_length (<=32767); if a
-- line is longer than the max, it will be split up.
-- If line_ending is null, splits the clob into fixed-length
-- lines.
-------------------------------------------------------------------
function from_clob (
    content     in clob,
    line_ending in varchar2 := crlf,
    max_length  in integer := 32767
) return array_type;

end str_array_pkg;
/
