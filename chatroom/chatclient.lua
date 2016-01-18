package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;chatroom/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local chatproto = require "chatproto"

local cmdkv = chatproto.cmd;
local proto = sproto.new(chatpro.proto);


local fd = assert(socket.connect("127.0.0.1", 8881))

-- send message
local session = 0
local function send_msg(name, dt)
	session = session + 1;
	local msg = proto.pencode(name, dt);
	local t = {session = session, userId = 0, data = msg};
	local package = string.pack(">s2", proto.pencode(cmdkv[6], t))
	socket.send(fd, package)
end

function split(str, delimiter)
	if str == nil or str == '' or delimiter == nil then
		return nil;
	end
	local result = {}
	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end

-- receive message
local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end


local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end

		local rt = proto.decode("msg", v);
		local command = cmdkv[rt.cmd];

		print("command:", command);

		if (command == 'say') then
		elseif (command == 'login') then
		elseif (command == 'quit') then
		elseif (command == 'handshake') then
		elseif (command == 'heartbeat') then
		end
		print("can't find cmd:", rt.cmd);
	end
end


send_msg("handshake", {msg='t'});

while true do
	dispatch_package()
	local line = socket.readstdin()
	if line then
		local cmds = split(line, " ");
		local cmd = cmds[1]
		if cmd == "quit" then
			send_msg("quit", {});
		elseif (cmd == 'login') then
			send_msg("login", {name=cmds[2]});
		elseif (cmd == 'say') then
			send_msg("say", {name=cmds[2]});
		end
	else
		socket.usleep(100)
	end
end
