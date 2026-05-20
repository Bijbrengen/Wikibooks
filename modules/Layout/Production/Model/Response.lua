-- The interface forms a response object which will contain valid outputdata for the invoker of the module
local response = {}

function response.init()
    local instance = {
        wikitext = ""
    }
    
    function instance.add(result)
        instance.wikitext = instance.wikitext .. result
    end
    
    function instance.get()
        return instance.wikitext
    end
    
    return instance
end

return response;

