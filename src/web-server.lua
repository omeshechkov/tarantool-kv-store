local json = require('json')
local store = require('my-store')

local function GetHandler(req)
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

function PostHandler(req)
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

function PutHandler(req)
    local body = req:json();

    local value = body.value;
    local key = req:stash('key')

    if key == nil or value == nil or type(key) ~= 'string' then
        return { status = 400 };
    end

    store.upsert(key, value)

    return { status = 200 }
end

function DeleteHandler(req)
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

local httpd = require('http.server').new('0.0.0.0', 8000)
httpd:route({ path = '/kv/:key', method = 'GET' }, GetHandler)
httpd:route({ path = '/kv', method = 'POST' }, PostHandler)
httpd:route({ path = '/kv/:key', method = 'PUT' }, PutHandler)
httpd:route({ path = '/kv/:key', method = 'DELETE' }, DeleteHandler)
httpd:start()
