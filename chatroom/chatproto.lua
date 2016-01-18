local sprotoparser = require "sprotoparser"

local proto = {}

proto.c2s = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

handshake 1 {
	response {
		msg 0  : string
	}
}

login 2 {
	request {
		what 0 : string
		value 1 : string
	}
	response {
		from 0 : string
		result 1 : string
	}
}

say 3 {
	request {
		what 0 : string
		value 1 : string
	}
	response {
		result 0 : string
	}
}

quit 4 {}

]]

proto.s2c = sprotoparser.parse [[
.package {
	type 0 : integer
	session 1 : integer
}

heartbeat 1 {}
]]

return proto
