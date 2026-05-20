local flight = {};

function flight.feedback( call )
	local response = "";
	if not call.pass then call.support = "help"; end
	if call.support == "ignore" then return response; end

    local mistake, debugging, help = "", "", "";

    if #call.mistake > 0 then 
    	mistake = "<br><pre>" .. 
        string.upper( call.message.MISTAKE.HEADER ) .. ":\n\n* " .. 
        table.concat( call.mistake, "\n\n* ") .. "\n\n" .. 
        call.message.MISTAKE.EXPLANATION .. "</pre><br>";
        mw.addWarning( mistake );
    end
    
    if call.support == "debug" or call.support == "help" then 
    	debugging = "<br><pre>" .. 
    	    string.upper( call.message.DEBUG.HEADER ) .. ":\n\n# " .. 
    	    table.concat( call.debugging, "\n# ") .. "\n\n" .. 
    	    call.message.DEBUG.EXPLANATION .. "</pre><br>";
    end

    local help = "";
    if call.support == "help" then 
    	help = "<br><pre>" .. 
    	    string.upper( call.message.HELP.HEADER ) .. ":\n\n# " .. 
    	    table.concat( call.help, "\n# ") .. "\n\n" .. 
    	    call.message.HELP.EXPLANATION .. "</pre><br>";
    end

    return mistake .. debugging .. help;
end

-- This function handles any internal errors that the system recognized itself. 
-- This is possible because each submodule in the system and the library checks it's input again.
-- Errors should never occur if the call has no mistakes.
-- The problem can be bugs in the security checks, the bagagge handling or the system itself. 
function flight.landed( call )
    return "";
end

function flight.takeoff( call ) -- returns a string as a result from a call to the system.
	local response = "";
	if #call.mistake ~= 0 then return response; end
	local script = call.include( call.object );
	if script ~= "" and type(script) == "table" and script.main then response = tostring( script.main( call ) ); end 
	return response;
end



return flight;
