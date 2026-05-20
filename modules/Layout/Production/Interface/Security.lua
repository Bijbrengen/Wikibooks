-- Security validates the input passed to Module:Layout before rendering starts.
-- It records user-facing mistakes and sets call.pass to false when rendering
-- should be blocked.
local security = {};
local frisk = {};
local report = {};

-- Check whether this environment was invoked through its configured template.
function security.authentication( call )
	call.add_new_debug( call.message.DEBUG.INVOKER, tostring( call.invoker ), report.debugging( call ) );
	if ( call.invoker ~= call.template ) then
        call.add_new_mistake ( call.message.MISTAKE.NO_INTERFACE_TEMPLATE );
        call.add_debug( call.message.DEBUG.NO_INTERFACE_TEMPLATE );
	end
    return call;
end

-- Check internal #invoke parameter names before translated template names are handled.
function security.declaration( call )
	-- Array search is used to compare against the configured parameter whitelist.
	local array  = call.include( "array" );

    -- Named #invoke parameters must be listed in hook.PARAMETER.
    for key, value in pairs( call.named ) do
        if not array.search( call.hook.PARAMETER, key ) then 
        	call.add_new_mistake ( call.message.MISTAKE.WRONG.INVOKE_PARAMETER, key, key, value );
        end
    end
	return call;
end

-- Validate all configured parameter values after names have been accepted.
function security.frisk( call )
	-- Each parameter has an optional frisk function with its own value rules.
	local array, frisk  = call.include( "array", "frisk" );

    local mistakes_before_value_check = #call.mistake;
	for _, parameter in ipairs( call.hook.PARAMETER ) do
		-- Frisk functions must inspect a clone and return a message, not mutate the call.
		local call_clone = array.copy( call );
        if frisk[ parameter ]( call_clone ) then
        	call.add_new_mistake( frisk[ parameter ]( call_clone ) );
        end
	end
	local value_mistake = #call.mistake - mistakes_before_value_check;

    if value_mistake == 0 then call.add_debug( call.message.DEBUG.VALUES_OK ); end
	if value_mistake == 1 then call.add_mistake( call.message.DEBUG.VALUE_MISTAKE ); end
    if value_mistake > 1  then call.add_mistake( call.message.DEBUG.VALUE_MISTAKES, value_mistake ); end
    return call;
end

-- Scan the original page wikitext for translated template parameter names.
-- A page may contain multiple template calls, so every matching call is checked.
function security.scan( call ) -- returns call object with security information
	-- Extract parses template calls; array checks localized parameter names.
	local extract, array  = call.include( "extract", "array" );

 	-- Module documentation can expose source text containing template definitions,
 	-- which would produce false positives if scanned as normal page content.
-- 	if call.caller:inNamespace( "Module" ) and call.caller.subpageText ~= "doc" then return call; end
 	
    call.add_new_debug( call.message.DEBUG.CALLER,  tostring( call.invoker), tostring( call.caller ) );

    local caller_content =  call.caller:getContent();
    local calling_templates = extract.template( caller_content, call.message.TEMPLATENAME, call );
    local parameter_mistake = {};
    for index, value in ipairs( calling_templates ) do
     	for key, v in pairs( value ) do
     		-- Unnamed parameters remain free-form; named parameters must be localized hooks.
            if not tonumber( key ) and not array.search( call.message.HOOK.PARAMETER, key, true ) then
            	parameter_mistake[ #parameter_mistake + 1 ] = key;
		    	call.add_new_mistake( call.message.MISTAKE.WRONG.TEMPLATE_PARAMETER, key, key, v, table.concat( call.message.HOOK.PARAMETER, ", ") );
            end
        end
    end
    -- The mistakes are already stored. The debug reports only the number of mistakes found.
    if #parameter_mistake == 0 then call.add_debug( call.message.DEBUG.PARAMETERS_OK ); end
    if #parameter_mistake == 1 then call.add_debug( call.message.DEBUG.PARAMETER_MISTAKE, parameter_mistake[1] ); end
    if #parameter_mistake > 1  then call.add_debug( call.message.DEBUG.PARAMETER_MISTAKES, #parameter_mistake, table.concat( parameter_mistake, ", ") ); end
    return call;
end

-- Reconstruct the #invoke call for debug feedback.
function report.debugging( call )
	local call_string = "{{#invoke:Layout|main";
    -- Add named parameters.
    for key, value in pairs( call.named ) do
        call_string = call_string .. "|" .. key .. "=" .. value;
    end

    -- Add unnamed parameters.
    for _, value in ipairs( call.unnamed ) do
        call_string = call_string .. "|" .. value;
    end
    return call_string .. "}}";
end

return security;
