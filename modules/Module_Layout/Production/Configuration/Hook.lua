local HOOK = {};

HOOK.FORMAT         = { "text", "html", "header", "footer" };
HOOK.OBJECT         = { "age", "book", "bookshelf", "category", "chapter", "chess", "concept", "definition", "description", "gradient", "infobox", "logo", "module", "person", "painting", "progress", "section", "series", "talk", "template", "toc", "user", "wikijunior", "wikipedia" };
HOOK.ORIENTATION    = { "landscape",  "portrait", "white", "black" };
HOOK.PARAMETER      = { "object", "support", "format", "orientation", "color", "title", "definition", "description", "progress", "source", "reference", "collection", "part" };
HOOK.SUPPORT        = { "ignore", "signal", "debug", "help" };

return HOOK;