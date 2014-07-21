local os = require('os')

-- format - format of a string ('default', 'short' or 'dev')
-- available options:
--  `stream` - output stream, defaults to stdout
--  `immediate` - write log line on request instead of response, defaults to false

function logger (format, options)
	options = options or {}

	format = format or 'default'
	local stream = options.stream or process.stdout
	local immediate = options or false

	return function (req, res, follow)
		local startTime = os.clock()
		local dateTime = os.date()

		local function logRequest ()
			local output
			local httpVersion = req.version_major .. '.' .. req.version_minor
			local function duration (seconds)
				local shift = 10 ^ 2
				local result = math.floor(seconds * 1000 * shift + 0.5) / shift
				return result
			end

			res:removeListener('end', logRequest)

			if format == 'dev' then
				output = req.method .. ' ' .. res.code .. ' ' .. req.url .. ' ' .. duration(os.clock() - startTime) .. 'ms'
			elseif format == 'short' then
				output = dateTime .. ' - ' .. req.method .. ' ' .. req.url .. ' HTTP/' .. httpVersion .. ' ' .. res.code .. ' ' .. duration(os.clock() - startTime) .. 'ms'
			else
				output = dateTime .. ' - ' .. req.method .. ' ' .. req.url .. ' HTTP/' .. httpVersion .. ' ' .. res.code .. ' ' .. duration(os.clock() - startTime) .. 'ms ' .. req.headers['user-agent']
			end

			stream:write(output .. '\n')
		end

		if immediate then
			logRequest()
		else
			res:on('end', logRequest)
		end

		follow()
	end
end

return logger