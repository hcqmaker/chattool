local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

local max_client = 64

skynet.start(function()
	print("Server start")
	skynet.uniqueservice("chatprotoloader")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	skynet.newservice("chatroom")
	local watchdog = skynet.newservice("chatwatchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
	print("Watchdog listen on ", 8888)

	skynet.exit()
end)
