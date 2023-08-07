--!strict

local HttpService = game:GetService("HttpService")
local FontsJSON = script.Parent:WaitForChild("FontsJSON")

export type Glyph = {
	size: Vector3,
	vertices: {Vector3},
	faces: {{number}},
}

export type Font = {
	glyphs: {[string]: Glyph},
	characters: {[string]: boolean},
}

local function toVector3(arr: {number}): Vector3
	return Vector3.new(arr[1], arr[2], 0)
end

local function getFonts(parent: Instance): {[string]: Font}
	local fonts: {[string]: Font} = {}

	for _, fontFolder in parent:GetChildren() do
		local partitions: {string} = {}
		for _, jsonStringValue in fontFolder:GetChildren() do
			local index = tonumber(jsonStringValue.Name)
			if index and jsonStringValue:IsA("StringValue") then
				partitions[index] = jsonStringValue.Value
			end
		end

		local glyphs: {[string]: Glyph} = {}
		local characters: {[string]: boolean} = {}

		local decoded = HttpService:JSONDecode(table.concat(partitions))

		for character, unconvertedGlyph in decoded do
			local glyph = {}

			glyph.faces = unconvertedGlyph.faces
			glyph.size = toVector3(unconvertedGlyph.size)
			glyph.vertices = {}

			for i, unconvertedVertex in unconvertedGlyph.vertices do
				glyph.vertices[i] = toVector3(unconvertedVertex)
			end

			glyphs[character] = glyph
			characters[character] = true
		end

		fonts[fontFolder.Name] = {
			glyphs = glyphs,
			characters = characters,
		}
	end

	return fonts
end

local fonts = getFonts(FontsJSON)
FontsJSON:Destroy()
return fonts