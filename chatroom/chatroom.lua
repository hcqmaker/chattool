local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local user_list = {}
local command = {}


local WATCHDOG 

function command.ENTER(name)
	table.insert(user_list, name);
	return true;
end

function command.QUIT(name)
	local idx = -1;
	for k, v in ipairs(user_list) do
		if (v == name) then
			idx = k;
			break;
		end
	end
	if (idx ~= -1) then
		table.remove(user_list, idx);
	end
	return true;
end

function command.SAY(name, msg)
	print("room==>", name, msg);
	skynet.call(WATCHDOG, "lua", "SAY", "test_say");
	return true;
end

function command.SETUP(conf)
	WATCHDOG = conf.watchdog;
end


skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register "ROOM"
end)


