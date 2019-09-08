local log = require('log')

local middleware = {}

function middleware.compose(...)
    local args = {...}
    local result = nil

    for i = #args, 1, -1 do
        local current = args[i]

        if result == nil then
            result = current
        else
            local next = result
            result = function(req)
                return current(req, next)
            end
        end
    end

    return result
end

function middleware.logger(req, next)
    log.info('Received request '..req.method..' '..req.path)

    local result = next(req)

    log.info('Request '..req.method..' '..req.path..' is finished')

    return result
end

function middleware.throttle(maxParallelRequests)
    local requestCounter = 0;
    local timestamp = 0;

    return function (req, next)

        local now = os.time();
        if timestamp ~= now then
            timestamp = now
            requestCounter = 0
        end

        requestCounter = requestCounter + 1

        if (requestCounter >= maxParallelRequests) then
            return { status = 429 }
        end

        return next(req)
    end
end

return middleware