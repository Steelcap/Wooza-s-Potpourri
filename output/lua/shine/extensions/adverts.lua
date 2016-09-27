--[[
	Shine adverts system.
]]

Shared.Message("The adverts of Las!")

local Shine = Shine

local TableQuickCopy = table.QuickCopy
local TableQuickShuffle = table.QuickShuffle
local TableRemove = table.remove
local type = type

local Plugin = {}
Plugin.Version = "1.1"
Plugin.PrintName = "Adverts"

Plugin.HasConfig = true
Plugin.CheckConfigTypes = true
Plugin.ConfigName = "Adverts.json"
Plugin.DefaultConfig = {
	Adverts = {
		{
			Message = "WELCOME TO HELL",
			Type = "chat",
			R = 255,
			G = 255,
			B = 255
		},
		{
			Message = "This server is currently installing virii on your PC!",
			Type = "chat",
			R = 255,
			G = 255,
			B = 255
		}
	},
	Interval = 60,
	RandomiseOrder = false
}

Plugin.TimerName = "Adverts"

function Plugin:Initialise()
	self.AdvertsList = TableQuickCopy( self.Config.Adverts )
	self:SetupTimer()
	self.Enabled = true

	return true
end

local IsType = Shine.IsType

function Plugin:ParseAdvert( ID, Advert )
	if IsType( Advert, "string" ) then
		Shine:NotifyColour( nil, 255, 255, 255, Advert )

		return true
	end

	if not IsType( Advert, "table" ) then
		self:Print( "Misconfigured advert #%i, neither a table nor a string.", true, ID )

		TableRemove( self.AdvertsList, ID )

		return false
	end

	local Message = Advert.Message
	if not Message then
		self:Print( "Misconfigured advert #%i, missing \"Message\" value.",
			true, ID )

		TableRemove( self.AdvertsList, ID )

		return false
	end

	local R = Advert.R or Advert.r or 255
	local G = Advert.G or Advert.g or 255
	local B = Advert.B or Advert.b or 255

	local Type = Advert.Type

	if not Type or Type == "chat" then
		Shine:NotifyColour( nil, R, G, B, Message )
	else
		local Position = ( Advert.Position or "top" ):lower()

		local X, Y = 0.5, 0.2
		local Align = 1

		if Position == "bottom" then
			X, Y = 0.5, 0.8
		end

		Shine.ScreenText.Add( 20, {
			X = X, Y = Y,
			Text = Message,
			Duration = 7,
			R = R, G = G, B = B,
			Alignment = Align,
			Size = 2, FadeIn = 1
		} )
	end

	return true
end

function Plugin:SetupTimer()
	if self:TimerExists( self.TimerName ) then
		self:DestroyTimer( self.TimerName )
	end

	if #self.AdvertsList == 0 then return end

	local Message = 1

	self:CreateTimer( self.TimerName, self.Config.Interval, -1, function()
		-- Back to the start, randomise the order again.
		if Message == 1 and self.Config.RandomiseOrder then
			TableQuickShuffle( self.AdvertsList )
		end

		if self:ParseAdvert( Message, self.AdvertsList[ Message ] ) then
			Message = ( Message % #self.AdvertsList ) + 1
		elseif #self.AdvertList == 0 then
			self:DestroyTimer( self.TimerName )
		end
	end )
end

Shine:RegisterExtension("adverts", Plugin )
