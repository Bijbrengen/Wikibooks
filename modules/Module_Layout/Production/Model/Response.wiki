-- The interface forms a response object which will contain valid outputdata for the invoker of the module
local response = {}

function response.init()
    local instance = {
        fragments = {}
    }
    
    function instance.add(result)
        if result and result ~= "" then
            table.insert(instance.fragments, tostring(result))
        end
    end
    
    function instance.get()
        return table.concat(instance.fragments)
    end
    
    return instance
end

return response;