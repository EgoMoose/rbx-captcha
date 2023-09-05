--!strict

-- This is just an example of how you might use the captcha client
-- The request is made from the server, the client sends back their response

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CaptchaClient = require(ReplicatedStorage:WaitForChild("CaptchaClient")) :: any

local screen = script.Parent
local content = screen:WaitForChild("Body"):WaitForChild("Content")
local input = content:WaitForChild("Bottom"):WaitForChild("Input"):WaitForChild("TextBox")
local submit = content:WaitForChild("Bottom"):WaitForChild("Submit"):WaitForChild("TextButton")

local vpf = content:WaitForChild("Captcha"):WaitForChild("ViewportFrame")
local stroke = content:WaitForChild("Captcha"):WaitForChild("UIStroke")
local strokeColor = stroke.Color

local camera = Instance.new("Camera")
camera.FieldOfView = 1
camera.Parent = vpf
vpf.CurrentCamera = camera

local currentModel: Model? = nil

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
	
	CaptchaClient.fit(copy, vpf, camera)
	
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