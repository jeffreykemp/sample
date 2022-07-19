# Example SQL Object Types

How to use SQL object types to build a hierarchical data type system purpose-built for a custom purpose.

This is just for illustrative / educational purposes.

## Base (prototype) type for our object type hierarchy

    create or replace type base_t force as object (

        ---------------------------------------------------------------------------
        -- common data element used by any subtype
        data_type varchar2(128),


        ---------------------------------------------------------------------------
        -- Return this value as a string.
        -- Not instantiable - i.e. behaviour is not defined by base type;
        -- every subtype (that is instantiable) MUST define this function
        not instantiable member function to_string
            return varchar2,


        ---------------------------------------------------------------------------
        -- Return true if this value is null.
        not instantiable member function is_null
            return boolean,


        ---------------------------------------------------------------------------
        -- Return a description of the value as a string, e.g. for debug log.
        -- (may optionally be overridden by a subtype)
        member function object_info
            return varchar2,


        ---------------------------------------------------------------------------
        -- ORDER function defines how two values may be compared
        --
        -- Should return 0 if they are "equal"
        -- Should return 1 if this value is "greater than" the p_other value
        -- Should return -1 if this value is "less than" the p_other value
        --
        -- (note: alternative simpler+faster system is to use a MAP member
        -- function, but the map function cannot handle all scenarios)
        --
        order member function compare (
            p_other in base_t
        ) return integer,


        ---------------------------------------------------------------------------
        -- function to implement the comparison - MUST be defined by every subtype
        not instantiable member function compare_implementation (
            p_other in base_t
        ) return integer,


        ---------------------------------------------------------------------------
        -- function to "add" something to something
        not instantiable member procedure add_ (
            p_value in base_t
        )

    )
    -- we are allowed to create subtypes of this type
    not final                
    -- we can NOT create base_t objects directly (we have to use a subtype)
    not instantiable
    /

## Generic "String" type

UNDER: inherits everything from base_t

    create or replace type string_t force under base_t (

        ---------------------------------------------------------------------------
        -- data element specific to this type
        string_value varchar2(32767),


        ---------------------------------------------------------------------------
        -- constructor to build a value of this type
        --
        -- Since the parameter is optional, we can create "empty" values of this type
        --
        -- Example:
        --
        --     l_value := string_t('Hello world');
        --
        constructor function string_t (
            p_string in varchar2 := null
        ) return self as result,


        ---------------------------------------------------------------------------
        overriding member function to_string
            return varchar2,


        ---------------------------------------------------------------------------
        -- Return true if this value is null.
        overriding member function is_null
            return boolean,


        ---------------------------------------------------------------------------
        overriding member function compare_implementation (
            p_other in base_t
        ) return integer,


        ---------------------------------------------------------------------------
        -- concatenate something to the string
        --
        -- Example:
        --
        --     l_value.add_( string_t('xyz') );
        --
        overriding member procedure add_ (
            p_value in base_t
        )

    )
    -- give us room to define subtypes of this later on if we need to
    not final
    /

## Generic "Number" type

    create or replace type number_t force under base_t (

        ---------------------------------------------------------------------------
        number_value number,


        ---------------------------------------------------------------------------
        constructor function number_t (
            p_number in number := null
        ) return self as result,


        ---------------------------------------------------------------------------
        overriding member function to_string
            return varchar2,


        ---------------------------------------------------------------------------
        -- Return true if this value is null.
        overriding member function is_null
            return boolean,


        ---------------------------------------------------------------------------
        overriding member function compare_implementation (
            p_other in base_t
        ) return integer,


        ---------------------------------------------------------------------------
        -- modify the number by adding the given value
        --
        -- Example:
        --
        --     l_value.add_( number_t( 1000 ) );
        --
        overriding member procedure add_ (
            p_value in base_t
        )

    )
    -- give us room to define subtypes of this later on if we need to
    not final
    /

## Generic "Date" type

    create or replace type date_t force under base_t (

        ---------------------------------------------------------------------------
        date_value date,


        ---------------------------------------------------------------------------
        -- Construct a date value
        --
        -- Examples:
        --
        --     l_value := date_t();
        --
        --     l_value := date_t( date'2000-12-31' );
        --
        --     l_value := date_t( add_months(current_date, 3) );
        --
        constructor function date_t (
            p_date in date := null
        ) return self as result,


        ---------------------------------------------------------------------------
        -- Convert a string to a date value
        --
        -- Example:
        --
        --     l_value := date_t( '9-SEP-2000', 'DD-MON-YYYY' );
        --
        constructor function date_t (
            p_string in varchar2,
            p_format in varchar2 := 'YYYY-MM-DD'
        ) return self as result,


        ---------------------------------------------------------------------------
        -- A static method is somewhat like a package method, it doesn't relate to
        -- any particular instance of the object type - useful for helper methods.
        --
        -- Example:
        --
        --     l_value := date_t.today;
        --
        --     dbms_output.put_line(
        --         date_t.today().to_string
        --     );
        --
        -- Note that when you want to call a method on an object that has been
        -- returned by a type function, you must include () even if the function has
        -- no parameters.
        --
        static function today return date_t,


        ---------------------------------------------------------------------------
        overriding member function to_string
            return varchar2,


        ---------------------------------------------------------------------------
        -- Return true if this value is null.
        overriding member function is_null
            return boolean,


        ---------------------------------------------------------------------------
        member function to_date
            return date,        


        ---------------------------------------------------------------------------
        overriding member function compare_implementation (
            p_other in base_t
        ) return integer,


        ---------------------------------------------------------------------------
        -- modify the date by the given offset (in number of days)
        --
        -- Example:
        --
        --     l_value.add_( number_t( 14 ) );
        --
        overriding member procedure add_ (
            p_value in base_t
        )

    )
    -- give us room to define subtypes of this later on if we need to
    not final
    /

## Table of value type (needed by array_t)

    create or replace type base_tab_t force as table of base_t;
    /

## Generic "Array" type

Note that each element in the array is itself a base_t, which means we can have arrays of strings, arrays of numbers, arrays of dates, or arrays of any mixture of these.

We can even have arrays of arrays, which themselves can be arrays of any of these things.

    create or replace type array_t force under base_t (

        ---------------------------------------------------------------------------
        array_value base_tab_t,


        ---------------------------------------------------------------------------
        -- Construct an array value
        --
        -- Examples:
        --
        --     l_value := array_t(
        --         base_tab_t( string_t('x'), string_t('y'), string_t('z') )
        --     );
        --
        --     l_value := array_t(
        --         base_tab_t(
        --             number_t(123),
        --             date_t.today,
        --             array_t()
        --         )
        --     );
        --
        constructor function array_t (
            p_array in base_tab_t := null
        ) return self as result,


        ---------------------------------------------------------------------------
        overriding member function to_string
            return varchar2,


        ---------------------------------------------------------------------------
        -- Return true if this value is null.
        overriding member function is_null
            return boolean,


        ---------------------------------------------------------------------------
        -- Return the count of elements in this array
        member function count return integer,


        ---------------------------------------------------------------------------
        -- Return the count of all non-null elements; if any element is itself an
        -- array, count the non-null values inside that array (but don't count the
        -- array itself in the total) - recursively
        member function count_deep return integer,


        ---------------------------------------------------------------------------
        -- Get the value at the given index
        -- Raises NO_DATA_FOUND if the index doesn't exist in the array
        member function get (p_index in binary_integer) return base_t,


        ---------------------------------------------------------------------------
        overriding member function compare_implementation (
            p_other in base_t
        ) return integer,


        ---------------------------------------------------------------------------
        -- append an element to the array
        --
        -- Example:
        --
        --     l_value.add_( string_t( 'abc' ) );
        --
        overriding member procedure add_ (
            p_value in base_t
        )

    )
    -- give us room to define subtypes of this later on if we need to
    not final
    /

## Implementation for base_t

    create or replace type body base_t as

        -- We only implement methods that are instantiable; we don't implement
        -- methods that are not instantiable since they will be defined
        -- differently for each child type.

        ---------------------------------------------------------------------------
        member function object_info
            return varchar2 is
        begin

            -- We can call a function defined by the type, e.g. to_string; at
            -- runtime, the engine will "dispatch" the call to the most specific
            -- type of the variable, e.g. the string_t, the number_t, or whatever
            -- it happens to be.

            -- We can refer to any attribute that is defined in the base type.

            return to_string
                || ' ('
                || data_type
                || ')';

        end;


        ---------------------------------------------------------------------------
        -- Compare two values - any two values that are descended from base_t.
        --
        -- Note that I choose to put as much of the complexity in the base type
        -- as possible, leaving small details specific to each type in the child
        -- types.
        --
        order member function compare (
            p_other in base_t
        ) return integer is
            l_result integer;
        begin

            -- At this level, we will handle nulls generically for all types.

            if is_null and (p_other is null or p_other.is_null) then

                l_result := 0;

            elsif not is_null and (p_other is null or p_other.is_null) then

                l_result := 1;

            elsif is_null and p_other is not null and not p_other.is_null then

                l_result := -1;

            else

                -- if both values are not null, call the specific implementation
                -- to do the comparison

                l_result := compare_implementation(p_other);

                -- if the specific comparison couldn't decide, use simple
                -- string comparison

                if l_result is null then

                    declare
                        l_this  varchar2(32767) := to_string;
                        l_other varchar2(32767) := p_other.to_string;
                    begin

                        if l_this = l_other then

                            l_result := 0;

                        elsif l_this > l_other then

                            l_result := 1;

                        elsif l_this < l_other then

                            l_result := -1;

                        end if;

                    end;

                end if;

            end if;

            return l_result;
        end;

    end;
    /

## Implementation for string_t

    create or replace type body string_t as

        ---------------------------------------------------------------------------
        constructor function string_t (
            p_string in varchar2 := null
        ) return self as result is
        begin

            data_type    := $$plsql_unit;
            string_value := p_string;

            -- every constructor function must end with "return".
            return;
        end;


        ---------------------------------------------------------------------------
        overriding member function to_string
            return varchar2 is
        begin    
            return string_value;
        end;


        ---------------------------------------------------------------------------
        overriding member function is_null
            return boolean is
        begin
            return string_value is null;
        end;


        ---------------------------------------------------------------------------
        -- we've decided to allow the default compare function deal with string
        -- comparisons
        overriding member function compare_implementation (
            p_other in base_t
        ) return integer is
        begin
            return null;
        end;


        ---------------------------------------------------------------------------
        -- concatenate something to the string
        overriding member procedure add_ (
            p_value in base_t
        ) is
        begin
            string_value := string_value || p_value.to_string;
        end;

    end;
    /

## Implementation for number_t

    create or replace type body number_t as

        ---------------------------------------------------------------------------
        constructor function number_t (
            p_number in number := null
        ) return self as result is
        begin

            data_type    := $$plsql_unit;
            number_value := p_number;

            return;
        end;


        ---------------------------------------------------------------------------
        overriding member function to_string
            return varchar2 is
        begin

            return to_char(number_value);

        end;


        ---------------------------------------------------------------------------
        overriding member function is_null
            return boolean is
        begin
            return number_value is null;
        end;


        ---------------------------------------------------------------------------
        overriding member function compare_implementation (
            p_other in base_t
        ) return integer is
            l_result integer;
        begin

            if p_other is of (number_t) then

                if number_value = treat(p_other as number_t).number_value then

                    l_result := 0;

                elsif number_value > treat(p_other as number_t).number_value then

                    l_result := 1;

                elsif number_value < treat(p_other as number_t).number_value then

                    l_result := -1;

                end if;

            end if;

            return l_result;
        end;


        ---------------------------------------------------------------------------
        -- concatenate something to the string
        overriding member procedure add_ (
            p_value in base_t
        ) is
        begin

            if p_value is of (number_t) then

                -- since p_value is a base_t, in order to access something defined
                -- by a number_t we have to use TREAT(x as y)

                number_value := number_value
                              + treat(p_value as number_t).number_value;

            else

                number_value := number_value
                              + to_number(p_value.to_string
                                          default null on conversion error);

            end if;

        end;

    end;
    /

## Implementation for date_t

    create or replace type body date_t as

        ---------------------------------------------------------------------------
        constructor function date_t (
            p_date in date := null
        ) return self as result is
        begin

            data_type  := $$plsql_unit;
            date_value := trunc(p_date);

            return;
        end;


        ---------------------------------------------------------------------------
        constructor function date_t (
            p_string in varchar2,
            p_format in varchar2 := 'YYYY-MM-DD'
        ) return self as result is
        begin    

            data_type  := $$plsql_unit;
            date_value := trunc(standard.to_date(p_string, p_format));        

            return;
        end;


        ---------------------------------------------------------------------------
        static function today return date_t is
        begin
            return date_t( p_date => current_date );
        end;


        ---------------------------------------------------------------------------
        overriding member function to_string
            return varchar2 is
        begin
            return to_char(date_value, 'YYYY-MM-DD');
        end;


        ---------------------------------------------------------------------------
        overriding member function is_null
            return boolean is
        begin
            return date_value is null;
        end;


        ---------------------------------------------------------------------------
        member function to_date
            return date is
        begin   
            return date_value;
        end;


        ---------------------------------------------------------------------------
        overriding member function compare_implementation (
            p_other in base_t
        ) return integer is
            l_result integer;
        begin

            if p_other is of (date_t) then

                if to_date = treat(p_other as date_t).to_date then

                    l_result := 0;

                elsif to_date > treat(p_other as date_t).to_date then

                    l_result := 1;

                elsif to_date < treat(p_other as date_t).to_date then

                    l_result := -1;

                end if;

            end if;

            return l_result;
        end;


        ---------------------------------------------------------------------------
        -- concatenate something to the string
        overriding member procedure add_ (
            p_value in base_t
        ) is
        begin

            if p_value is of (number_t) then

                date_value := date_value
                            + treat(p_value as number_t).number_value;

            else

                date_value := date_value
                            + to_number(p_value.to_string
                                        default null on conversion error);

            end if;

        end;

    end;
    /

## Implementation for array_t

    create or replace type body array_t as

        ---------------------------------------------------------------------------
        constructor function array_t (
            p_array in base_tab_t := null
        ) return self as result is
        begin    

            data_type   := $$plsql_unit;
            array_value := nvl(p_array, base_tab_t());

            return;
        end;


        ---------------------------------------------------------------------------
        overriding member function to_string
            return varchar2 is
            l_result varchar2(32767);
        begin

            if not is_null then

                for i in 1..array_value.count loop

                    if i > 1 then                
                        l_result := l_result || ', ';                
                    end if;

                    l_result := l_result || array_value(i).to_string;

                end loop;           

            end if;

            return l_result;
        end;


        ---------------------------------------------------------------------------
        overriding member function is_null
            return boolean is
        begin
            return array_value.count = 0;
        end;


        ---------------------------------------------------------------------------
        -- Return the count of elements in this array
        member function count return integer is
        begin
            return array_value.count;
        end;


        ---------------------------------------------------------------------------
        -- Return the count of all non-null elements; if any element is itself an
        -- array, count the non-null values inside that array (but don't count the
        -- array itself in the total) - recursively
        member function count_deep return integer is
            l_result integer := 0;
        begin

            for i in 1..array_value.count loop

                if array_value(i) is not null then

                    if array_value(i) is of (array_t) then
                        l_result := l_result + treat(array_value(i) as array_t).count_deep;
                    else
                        l_result := l_result + 1;
                    end if;

                end if;

            end loop;

            return l_result;
        end;


        ---------------------------------------------------------------------------
        -- Get the value at the given index
        member function get (p_index in binary_integer) return base_t is
        begin
            return array_value(p_index);
        end;


        ---------------------------------------------------------------------------
        overriding member function compare_implementation (
            p_other in base_t
        ) return integer is
            l_index  binary_integer;
            l_result integer;
        begin

            if p_other is of (array_t) then

                -- perform a value-by-value comparison until a difference is found
                -- in corresponding values in the two arrays

                l_index := 1;
                <<compare_loop>>
                loop

                    declare
                        l_value1 base_t;
                        l_value2 base_t;
                    begin

                        if array_value.exists(l_index) then
                            l_value1 := array_value(l_index);
                        end if;

                        if treat(p_other as array_t).array_value.exists(l_index) then
                            l_value2 := treat(p_other as array_t).array_value(l_index);
                        end if;

                        if l_value1 is null and l_value2 is null then

                            -- we've come to the end of the arrays and found no difference
                            l_result := 0;

                        elsif l_value1 is not null and l_value2 is null then

                            -- we've come to the end of the other array
                            l_result := 1;

                        elsif l_value1 is null and l_value2 is not null then

                            -- we've come to the end of this array
                            l_result := -1;

                        elsif l_value1 > l_value2 then

                            -- the value here is greater than the value in the other array
                            l_result := 1;

                        elsif l_value1 < l_value2 then

                            -- the value in the other array is greater than this value
                            l_result := -1;

                        else

                            -- the values are identical up to this point; continue looping
                            null;

                        end if;

                        exit compare_loop when l_result is not null;

                    end;

                    l_index := l_index + 1;
                end loop compare_loop;

            end if;

            return l_result;
        end;


        ---------------------------------------------------------------------------
        -- append something to the array
        overriding member procedure add_ (
            p_value in base_t
        ) is
        begin
            array_value.extend(1);
            array_value(array_value.last) := p_value;
        end;

    end;
    /

## SAMPLE CODE

    set serverout on
    declare
        l_value1 base_t;
        l_value2 base_t;
        l_value3 base_t;
    begin

        -- create a "number" variable
        l_value1 := number_t( 123 );

        -- create a "string" variable
        l_value2 := string_t( '456' );

        -- we can define any number of overloaded constructors
        -- for each type, e.g. to handle conversion from
        -- various other data types

        l_value3 := number_t( '456' );

        -- create a "date" variable

        l_value1 := date_t( date'2000-12-31' );

        -- create another "date" variable

        l_value2 := date_t.today;

        dbms_output.put_line('l_value1 = ' || l_value1.object_info);
    --
    -- EXPECTED OUTPUT:
    --     l_value1 = 2000-12-31 (DATE_T)
    --

        dbms_output.put_line('l_value2 = ' || l_value2.object_info);
    --
    -- EXPECTED OUTPUT:
    --     l_value2 = 2022-07-19 (DATE_T)
    --

        dbms_output.put_line('l_value3 = ' || l_value3.object_info);
    --
    -- EXPECTED OUTPUT:
    --     l_value3 = 456 (NUMBER_T)
    --

        -- we can compare any objects that share a common
        -- base class; each object can define custom
        -- logic for how to compare itself to any other
        -- type

        if l_value1 = l_value2 then
            dbms_output.put_line('l_value1 = l_value2');
        else
            dbms_output.put_line('l_value1 != l_value2');
        end if;
    --
    -- EXPECTED OUTPUT:
    --     l_value1 != l_value2
    --

        if l_value3 > l_value2 then
            dbms_output.put_line('l_value3 > l_value2');
        else
            dbms_output.put_line('l_value3 <= l_value2');
        end if;
    --
    -- EXPECTED OUTPUT:
    --     l_value3 > l_value2
    --

        -- We can inspect each variable to determine what
        -- type it is, using "x IS OF (t)""

        if l_value1 is of (date_t) then
            -- This means that l_value1 is either a date_t,
            -- OR
            -- it is of a child type of date_t
            dbms_output.put_line('l_value1 is of date_t');
        else
            dbms_output.put_line('l_value1 is not of date_t');
        end if;
    --
    -- EXPECTED OUTPUT:
    --     l_value1 is of date_t
    --

        -- What if a subclass defines a method not
        -- supported by its parent class?

        -- Convert it using "TREAT(x AS y)"

        declare
            l_date date_t;
        begin

            l_date := treat(l_value1 as date_t);

            l_date.add_( number_t( 14 ) );

            dbms_output.put_line('l_date = ' || l_date.object_info);
    --
    -- EXPECTED OUTPUT:
    --     l_date = 2001-01-14 (DATE_T)
    --

        end;

        -- Types can be defined that refer back to the
        -- same base type.

        -- They can store any data type under that base

        -- e.g. arrays of arrays,
        --      arrays of other objects,
        --      arrays of objects with
        --          more arrays as values,
        --      etc.

        declare
            l_array array_t := array_t();
            l_value base_t;
        begin

            l_array.add_( l_value1 );
            l_array.add_( l_value2 );
            l_array.add_( l_value3 );
            l_array.add_(
                array_t(
                    base_tab_t (
                        string_t('aaa'),
                        number_t(123),
                        date_t( sysdate - 5 )
                    )
                )
            );

            for i in 1..l_array.count
            loop

                l_value := l_array.get(i);

                dbms_output.put_line(
                    l_value.to_string
                );

            end loop;
    --
    -- EXPECTED OUTPUT:
    --     2000-12-31
    --     2022-07-19
    --     456
    --     aaa, 123, 2022-07-13
    --

            -- unleash the power of recursion!

            declare

                procedure process_node (p_node in base_t) is
                begin

                    -- do something
                    dbms_output.put_line(
                        p_node.object_info()
                    );

                    if p_node is of (array_t) then

                        for i in 1..treat(p_node as array_t).count
                        loop

                            process_node(
                                treat(p_node as array_t).get(i)
                            );

                        end loop;

                    end if;

                end process_node;

            begin

                process_node( l_array );

            end;
    --
    -- EXPECTED OUTPUT:
    --     2000-12-31, 2022-07-19, 456, aaa, 123, 2022-07-13 (ARRAY_T)
    --     2000-12-31 (DATE_T)
    --     2022-07-19 (DATE_T)
    --     456 (NUMBER_T)
    --     aaa, 123, 2022-07-13 (ARRAY_T)
    --     aaa (STRING_T)
    --     123 (NUMBER_T)
    --     2022-07-13 (DATE_T)
    --    
        end;

    end;
    /

=====

**[object-types.sql](object-types.sql)**
