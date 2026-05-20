local user = {};
local CFG = require("Module:Layout/Configuration");
local library = CFG.LOAD.LIBRARY();

function user.main( call )
	local frame = call.frame;
    return frame.args[ "part" ];
end

return user;
