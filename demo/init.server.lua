local ServerScriptService = game:GetService("ServerScriptService")
local Captcha = require(ServerScriptService.ServerPackages.RbxCaptcha)

local answer, model = Captcha.generate(nil, 10)
model.Parent = workspace

print(answer)
