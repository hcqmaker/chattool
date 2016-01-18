local skynet = require "skynet"
require "skynet.manager"	-- import skynet.register
local user_list = {}
local command = {}


function command.LOGIN(conf)
	local agent = conf.agent;
	local name = conf.name;
	print("user:", name, "login ===>");
	table.insert(user_list, {agent=agent,name=name});
	return {value="login ok"}
end

function command.LOGOUT(agent)
	local idx = -1;
	for k, v in ipairs(user_list) do
		if (v.agent == agent) then
			idx = k;
			break;
		end
	end
	if (idx ~= -1) then
		table.remove(user_list, idx);
	end
end


function command.SAY(agent, name, msg)
	print("say==>", agent, name, msg);
	local found = false;
	for k, v in ipairs(user_list) do
		if (v.agent == agent) then
			found = true;
			break;
		end
	end
	if (not found) then
		return nil;
	end

	local dt = name..":"..msg;

	for k, v in ipairs(user_list) do
		if (v.agent  ~= agent) then
			skynet.send(v.agent, "lua", "sayback", dt);
		end
	end
	return dt;
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


