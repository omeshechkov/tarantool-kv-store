local store = {}

local json = require('json')

box.cfg {
    listen = 3313
}

box.once("bootstrap", function()
    local space = box.schema.space.create('kv')

    space:format({
        { name = 'key', type = 'string' },
        { name = 'value', type = 'string' }
    })

    space:create_index('primary', { type='hash', parts={ 'key' } })
end)

local kvSpace = box.space.kv

function store.get(key)
    local tuple = kvSpace:get(key)
    if tuple == nil then
        return { success = false }
    end

    return {
        success = true,
        json = json.decode(tuple.value)
    }
end

function store.insert(key, body)
    if key == nil or body == nil or type(key) ~= 'string' then
        return { success = false };
    end

    local value = json.encode(body)

    local tuple = kvSpace:get{key}
    if tuple ~= nil then
        return false
    end

    kvSpace:insert{key, value}
    return true
end

function store.upsert(key, body)
    local value = json.encode(body)

    kvSpace:upsert({key, value}, {{'=', 2, value}})

    return true
end

function store.delete(key)
    local tuple = kvSpace:delete{key}

    return tuple ~= nil
end

return store;