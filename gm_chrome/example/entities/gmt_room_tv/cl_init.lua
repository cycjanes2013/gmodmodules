include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

hook.Add("CanMousePress", "DisableTelevision", function()
	
	for _, v in pairs( ents.FindByClass( "gmt_room_tv" ) ) do
		if v.Browser && v.MouseRayInteresct && v:MouseRayInteresct() then
			return false
		end
	end
	
end )

SetupBrowserMat(ENT, "chrome/tele", 720, 480, 0.1)

function ENT:Initialize()
	self:SharedInit()
end

function ENT:CalculateEarShot()
	local tvloc = GTowerLocation:FindPlacePos(self:GetPos())
	local plyloc = GTowerLocation:FindPlacePos(LocalPlayer():GetPos())
	self.InEarShot = (plyloc == tvloc)
end

function ENT:Powered( name, old, new )	self:CalculateEarShot()
	if !self.InEarShot || !chrome then return end

	if new && !old then
		self:StartTV()
	elseif !new && old then
		self:StopTV()
	end
end

function ENT:StopTV()
	print("tv off")
	self:RemoveBrowser()
end

function ENT:StartTV()
	print("tv on")
	self:InitBrowser(self:GetTable())
	self.Browser:LoadURL("http://www.gmodtower.org/gmtonline/television/")
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:GetPosBrowser()
	return self:GetPos() + (self:GetForward() * 18)
end

function ENT:DrawTranslucent()
	if !self.Browser then return end

	self:BaseBrowserDraw()
end

function ENT:Think()
	if self.Browser then
		self:MouseThink()
	end
end

hook.Add("Location", "PlayerLeaveRoomTV", function(ply, location)
	if ply != LocalPlayer() || !chrome then return end
	
	for k, v in ipairs(ents.FindByClass("gmt_room_tv")) do
		local tvloc = GTowerLocation:FindPlacePos(v:GetPos())

		v.InEarShot = (location == tvloc)

		if !v.InEarShot && v.Browser then
			v:StopTV()
		elseif v.InEarShot && v.Power && !v.Browser then
			v:StartTV()
		end
	end
end)
 