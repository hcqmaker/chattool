-- module proto as examples/proto.lua
package.path = "./chatroom/?.lua;" .. package.path

local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local proto = require "chatproto"

skynet.start(function()
	sprotoloader.save(proto.proto, 1)
	-- don't call skynet.exit() , because sproto.core may unload and the global slot become invalid
end)
