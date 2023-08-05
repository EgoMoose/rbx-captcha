local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Instance = roblox.Instance

local MAX_STR_LENGTH = 50_000
 
local fileName = process.args[1]
local filePath = "lune/fonts/" .. fileName .. ".json"
local fileExists = fs.isFile(filePath)
local fontJSON = fileExists and fs.readFile(filePath)

if not fontJSON then
	stdio.write(stdio.color("red"))
	print(filePath, "could not be found/loaded.")
	stdio.write(stdio.style("reset"))
	return
end

local nSplits = math.ceil(#fontJSON / MAX_STR_LENGTH)

local folder = Instance.new("Folder")
folder.Name = fileName

for i = 0, nSplits - 1 do
	local si = (i * MAX_STR_LENGTH) + 1
	local sj = (i + 1) * MAX_STR_LENGTH

	local jsonSplit = Instance.new("StringValue")
	jsonSplit.Name = tostring(i + 1)
	jsonSplit.Value = fontJSON:sub(si, sj)
	jsonSplit.Parent = folder
end

file = roblox.serializeModel({ folder })
fs.writeFile("lune/exported/" .. folder.Name .. ".rbxm", file)