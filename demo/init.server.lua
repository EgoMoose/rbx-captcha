local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ServerScriptService = game:GetService("ServerScriptService")

local Captcha = require(ServerScriptService.ServerPackages.RbxCaptcha) :: any
local CaptchaApp = script:WaitForChild("CaptchaApp")
local CaptchaUI = script:WaitForChild("CaptchaUI")

Captcha.setup()

CaptchaApp.Parent = CaptchaUI
CaptchaUI.Parent = StarterGui

Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Wait()
	task.wait(1)

	while true do
		local success = Captcha.request(player, 6)
		print("Server", success)
	end
end)