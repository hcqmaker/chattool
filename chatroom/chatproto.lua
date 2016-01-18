local sprotoparser = require "sprotoparser"


local proto = sprotoparser.parse  [[

.say {
	msg 0 : string
}

.login {
	name 0 : string
}

.quit {} 

.handshake {
	msg 0 : string	
}

.heartbeat {}

.msg {
	session 0 : integer
	userId 1 : integer
	cmd 2 : integer
	data 3 : string
}


]]

local cmd = {
[1] = 'say',
[2] = 'login',
[3] = 'quit',
[4] = 'handshake',
[5] = 'heartbeat',
[6] = 'msg',
say = 1,
login = 2,
quit = 3,
handshake = 4,
heartbeat = 5,
msg = 6,
}
return {proto = proto, cmd = cmd};
