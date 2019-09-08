local handlers = {}

local store = require('my-store')

function handlers.get(req)
    local key = req:stash('key')
    if key == nil or type(key) ~= 'string' then
        return { status = 400 };
    end

    local result = store.get(key)

    if not result.success then
        return { status = 404 }
    end

    return req:render({
        status = 200,
        json = result.json
    })
end

function handlers.post(req)
    local body = req:json();

    local key = body.key
    local value = body.value

    if key == nil or value == nil or type(key) ~= 'string' then
        return { status = 400 };
    end

    local success = store.insert(key, value)

    if not success then
        return { status = 409 }
    end

    return { status = 200 }
end

function handlers.put(req)
    local body = req:json();

    local value = body.value;
    local key = req:stash('key')

    if key == nil or value == nil or type(key) ~= 'string' then
        return { status = 400 };
    end

    store.upsert(key, value)

    return { status = 200 }
end

function handlers.delete(req)
    local key = req:stash('key')
    if key == nil or type(key) ~= 'string' then
        return { status = 400 };
    end

    local success = store.delete(key)

    if not success then
        return { status = 404 }
    end

    return { status = 200 };
end

return handlers