local STYLE = {};
local blue = {
	hex    = "#846dab",
	rgb    = { R = "132", G = "109", B = "171" },
	shades = { "#766299", "#695788", "#5c4c77", "#4f4166", "#423655", "#342b44", "#272033", "#1a1522", "#0d0a11", "#000000" },
	tints  = { "#907bb3", "#9c8abb", "#a898c4", "#b5a7cc", "#c1b6d5", "#cdc4dd", "#dad3e5", "#e6e1ee", "#f2f0f6", "#ffffff" }
};
local orange = {
	hex    = "#f26522",
    rgb    = { R = "242", G = "101", B = "34" },
    shades = { "#d95a1e", "#c1501b", "#a94617", "#913c14", "#793211", "#60280d", "#481e0a", "#301406", "#180a03", "#000000" },
    tints  = { "#f37438", "#f4834e", "#f59364", "#f7a27a", "#f8b290", "#f9c1a6", "#fbd0bc", "#fce0d2", "#fdefe8", "#ffffff" }
};
local purple = { 
	hex    = "#bd1a8d", 
	rgb    = { R = "189", G = "26", B = "141" }, 
	shades = { "#aa177e", "#971470", "#841262", "#710f54", "#5e0d46", "#4b0a38", "#38072a", "#25051c", "#12020e", "#000000" },
	tints  = { "#c33098", "#ca47a3", "#d05eaf", "#d775ba", "#de8cc6", "#e4a3d1", "#ebbadc", "#f1d1e8", "#f8e8f3", "#ffffff" }
}; 

local CHESS = {};
CHESS.COLOR_BLACK          = orange.shades[3];
CHESS.COLOR_WHITE          = orange.tints[3];

STYLE.BLACK  = "#000000"
STYLE.WHITE  = "#FFFFFF"
STYLE.BLUE   = blue.hex;
STYLE.ORANGE = orange.hex;
STYLE.PURPLE = purple.hex;
STYLE.CHESS  = CHESS;

STYLE.TEST   = "Module:Layout/Style/Test";

return STYLE;
