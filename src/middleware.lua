local middleware = {}

function LoggingMiddleware(req, next)
    next(req)
end

return middleware