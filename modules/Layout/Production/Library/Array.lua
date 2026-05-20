local array = {};

-- This function makes a unique duplicate in stead of a reference to an array including its nested tables.
-- The resulting "deep" copy contains no references to the original table or its nested tables.
-- For copying elements in the table that are functions this does NOT work be aware.
-- In Lua, you cannot directly create a copy of a function.
-- You can use the loadstring function to create a new function with the same body as the original function.
-- Only functions with upvalues (external local variables) using this method will not preserve the upvalues in the copied function. 
-- If your array has functions that rely on upvalues, you may need a more advanced approach to deep copy the array.
function array.copy( original )
    local original_type = type( original );
    local copy;
    if original_type == 'table' then
        copy = {};
        -- We use this function recursively for all the elements in the table to get as deep as needed for nested tables.
        for original_key, original_value in next, original, nil do
            copy[ array.copy( original_key ) ] = array.copy( original_value );
        end
        -- A metatable is a table that can be associated with another table to provide additional behavior,
        -- like customizing how the table handles arithmetic operations or indexing.
        -- Also the metatable must have a "deep" copy.
        setmetatable( copy, array.copy( getmetatable( original ) ) );
    else -- number, string, boolean, etc
    	-- No worries for referencing in stead of copying
        copy = original;
    end
    return copy;
end

-- The array.slice function takes a table (slice_table), 
-- along with optional first, last, and step arguments, 
-- and returns a new table containing a slice of the original table.
-- This function allows negative indexing, counting from the end of the table.
function array.slice( slice_table, first, last, step )
-- Initializes an empty table called sliced which will store the elements of the slice.
  local sliced = {};
  -- Handle a negative start
  if first ~= nil and first < 0 then first = first + #slice_table + 1; end
  -- Handle a negative end
  if last ~= nil and last < 0 then last = last + #slice_table + 1; end
  for i = first or 1, last or #slice_table, step or 1 do
    sliced[ #sliced + 1 ] = slice_table[ i ];
  end
  return sliced;
end

-- This function searches for a value in a certain table and returns the key if the value is found
function array.search( search_table, search_value, case_insensitive ) -- : integer 
    -- If case_insensitive is not set explicively to true, use case-sensitive search.
    case_insensitive = case_insensitive or false;

    -- Iterate through each key-value pair in the table.
    for key, value in pairs(search_table) do
        -- Check if the value matches the search value, using a case-sensitive or case-insensitive comparison as requested.
        if ( not case_insensitive and value == search_value ) or ( case_insensitive and string.lower( value ) == string.lower( search_value ) ) then
            -- If the search value is found, return the corresponding key.
            return key;
        end
    end
    
    -- If the search value is not found, return false to indicate failure.
    return false;
end

return array;
