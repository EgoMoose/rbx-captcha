--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CaptchaClient = require(ReplicatedStorage:WaitForChild("CaptchaClient"))

local screen = script.Parent
local content = screen:WaitForChild("Body"):WaitForChild("Content")
local input = content:WaitForChild("Bottom"):WaitForChild("Input"):WaitForChild("TextBox")
local submit = content:WaitForChild("Bottom"):WaitForChild("Submit"):WaitForChild("TextButton")

local vpf = content:WaitForChild("Captcha"):WaitForChild("ViewportFrame")
local stroke = content:WaitForChild("Captcha"):WaitForChild("UIStroke")
local strokeColor = stroke.Color

local camera = Instance.new("Camera")
camera.FieldOfView = 5
camera.Parent = vpf
vpf.CurrentCamera = camera

local currentModel: Model? = nil

local function getFitDistance(vpf: ViewportFrame, camera: Camera, model: Model): number
	local aabb = model:FindFirstChild("AABB") :: BasePart
	local radius = aabb.Size.Magnitude / 2
	
	local vpfSize = vpf.AbsoluteSize
	local aspect = vpfSize.X / vpfSize.Y
	
	local yFov2 = math.rad(camera.FieldOfView / 2)
	local tanyFov2 = math.tan(yFov2)
	
	local cFov2 = math.atan(tanyFov2 * math.max(1, aspect))
	local sincFov2 = math.sin(cFov2)
	
	return radius / sincFov2
end

local function hide()
	stroke.Color = strokeColor
	screen.Enabled = false
	input.Text = ""
	
	if currentModel then
		currentModel:Destroy()
		currentModel = nil
	end
end

local function show(unique: string, model: Model)
	hide()
	screen.Enabled = true
	
	local copy = model:Clone()
	copy.Name = unique
	copy.Parent = vpf
	
	local distance = getFitDistance(vpf, camera, copy)
	
	camera.Focus = CFrame.identity
	camera.CFrame = CFrame.new(0, 0, -distance) * CFrame.fromEulerAnglesXYZ(0, math.pi, 0)
	
	model:Destroy()
	currentModel = copy
end

local function trySubmit()
	if screen.Enabled and currentModel then
		local success = CaptchaClient.respond(currentModel.Name, input.Text)
		--stroke.Color = success and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
		print("Client", success)
	end
end

input.FocusLost:Connect(function(enterPressed: boolean)
	if enterPressed then
		trySubmit()
	end
end)

submit.Activated:Connect(function()
	trySubmit()
end)

CaptchaClient.onRequest:Connect(function(unique: string, model: Model)
	show(unique, model)
end)

hide()