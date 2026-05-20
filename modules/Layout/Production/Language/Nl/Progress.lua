local PROGRESS = {};

PROGRESS.NAME         = "Voortgang";
PROGRESS.DEVELOPMENT  = "";
local postfix    = " Revisiedatum: Volgens infobox]]";
PROGRESS.NOTHING =  " [[Afbeelding:00 percent.svg|%spx|link=|Nog vrijwel niets." .. postfix;
PROGRESS.IO      =  " [[Afbeelding:25 percent.svg|%spx|link=|In ontwikkeling." .. postfix;
PROGRESS.RO      =  " [[Afbeelding:50 percent.svg|%spx|link=|Redelijk ontwikkeld." .. postfix;
PROGRESS.GO      =  " [[Afbeelding:75 percent.svg|%spx|link=|Goed ontwikkeld." .. postfix;
PROGRESS.ZO      = " [[Afbeelding:100 percent.svg|%spx|link=|Zeer goed ontwikkeld." .. postfix;

return PROGRESS;
