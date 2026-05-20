local talk = {};
local CFG = require("Module:Layout/Configuration");
local library = CFG.LOAD.LIBRARY();

function talk.main( call )
	local frame = call.frame;
    return frame.args[ "part" ];
end

return talk;