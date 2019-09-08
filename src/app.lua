local log = require('log')
local middleware = require('middleware')
local handlers = require('handlers')

log.info('Starting HTTP server')

local logger = middleware.logger
local compose = middleware.compose

-- use if there no nginx behind
-- local throttle = middleware.throttle(50)

local httpd = require('http.server').new('0.0.0.0', 8000)
httpd:route({ path = '/kv/:key', method = 'GET' }, compose(logger, handlers.get))
httpd:route({ path = '/kv', method = 'POST' }, compose(logger, handlers.post))
httpd:route({ path = '/kv/:key', method = 'PUT' }, compose(logger, handlers.put))
httpd:route({ path = '/kv/:key', method = 'DELETE' }, compose(logger, handlers.delete))
httpd:start()

log.info('HTTP server has been successfully started')