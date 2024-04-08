-- this file is only necessary because lune currently does not cache modules properly
-- see: https://github.com/lune-org/lune/issues/138
if _G._modulestate == nil then
    _G._modulestate = {}
end

local modulestate = {}

-- if the state has not been initialized yet, we will use init to set values
function modulestate.get_state(s: string, init: { [any]: any }?): { [any]: any }
    if _G._modulestate[s] == nil then
        _G._modulestate[s] = {}
        if init ~= nil then
            for k, v in pairs(init) do
                _G._modulestate[s][k] = v
            end
        end
    end
    return _G._modulestate[s]
end

return modulestate
