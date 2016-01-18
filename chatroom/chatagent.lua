local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sprotoloader = require "sprotoloader"

local chatproto = require "chatproto"

local cmdkv = chatproto.cmd;
local proto

local WATCHDOG

local CMD = {}
local client_fd

local session = 0
local function send_msg(name, dt)
	session = session + 1;
	local msg = proto.pencode(name, dt);
	local t = {session = session, userId = 0, data = msg};
	local package = string.pack(">s2", proto.pencode(cmdkv[6], t))
	socket.send(client_fd, package)
end


local function unpack_msg(msg, sz)
	local t = proto.decode("msg", msg);
	local cmd = cmdkv[t.cmd];
	return cmd, proto.decode(cmd, t.data);
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return unpack_msg(msg, sz);
	end,
	dispatch = function (_, _, command, dt, ...)
		if (command == 'say') then
			print("agent: say", self.what, self.value)
			local msg = skynet.call("ROOM", "lua", "say", skynet.self(), self.what, self.value)
			if (not msg) then
				return {result = 'login first !!'; }
			end
			send_msg("say", {result=msg});
		elseif (command == 'login') then
			local what = self.what;
			local r = skynet.call("ROOM", "lua", "login", {agent=skynet.self(), name=self.value})
			send_msg("login", {result = r.value});
		elseif (command == 'quit') then
			skynet.call(WATCHDOG, "lua", "close", client_fd)
		elseif (command == 'handshake') then
			send_msg("handshake", { msg = "Welcome to skynet, I will send heartbeat every 5 sec." });
		elseif (command == 'heartbeat') then
			print("todo");
		else
			skynet.error("can't find comman:", command);
		end
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	proto = sprotoloader.load(1);
	skynet.fork(function()
		while true do
			send_package(send_request "heartbeat")
			skynet.sleep(500)
		end
	end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.send("ROOM", "lua", "logout", skynet.self());
	skynet.exit()
end

function CMD.sayback(msg)
	print(" ==> ", msg);
	send_msg("say", {result = msg});
end


skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		local ret = f(...);
		if (ret ~= nil) then
			skynet.ret(skynet.pack(ret))
		end
	end)
end)
