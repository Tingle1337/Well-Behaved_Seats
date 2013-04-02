if( CLIENT ) then

end

if( SERVER ) then
	local aLastDirectionPressed = {}
	function KeyPressedHook( pl, key )
		if( key == IN_BACK or key == IN_MOVERIGHT or key == IN_MOVELEFT or key == IN_FORWARD ) then
			aLastDirectionPressed[pl] = key	
		end
	end 
	hook.Add( "KeyPress", "KeyPressedHook", KeyPressedHook )

	local function SetControlledPosOnExit( pl, vehicle)	
		local pos = vehicle:GetPos()
		local dist = 40

		if( aLastDirectionPressed[pl] == IN_BACK ) then
			pos = pos + vehicle:GetAngles():Right() * dist
		elseif( aLastDirectionPressed[pl] == IN_MOVERIGHT ) then
			pos = pos + vehicle:GetAngles():Forward() * dist
		elseif( aLastDirectionPressed[pl] == IN_MOVELEFT ) then
			pos = pos + vehicle:GetAngles():Forward() * dist * -1
		else
			pos = pos + vehicle:GetAngles():Right() * dist * -1
		end	
		
		pl:SetPos( pos )
	end

	local function VehicleExit(pl, vehicle)
		if( vehicle:GetClass() ~= "prop_vehicle_prisoner_pod" ) then return end
		
		local es = constraint.GetAllConstrainedEntities( vehicle )
		local bExternal = false
		if( es and GravHull ) then
			for i, c in pairs( es ) do
				if( IsValid( c ) ) then
					for ent, data in pairs( GravHull.SHIPS ) do
						if IsValid(ent) and IsValid(data.MainGhost) then
							if( ent == c ) then
								bExternal = true
								
								local vec = vehicle:GetRealAngles():Right() * -1
								local ang = pl:AlignAngles( pl:GetRealAngles(), vec:Angle() )
								pl:SetAngles( ang )
								pl:SetEyeAngles( ang )
								
								GravHull.ShipEat(ent,pl)
								SetControlledPosOnExit( pl, vehicle )
							end
						end
					end
				end
			end
		end
		if( not bExternal ) then
			SetControlledPosOnExit( pl, vehicle )
			
			if( GravHull ) then	
				local vec = vehicle:GetRealAngles():Right() * -1
				local ang = pl:AlignAngles( pl:GetRealAngles(), vec:Angle() )
				pl:SetAngles( ang )
				pl:SetEyeAngles( ang )
			else
				local vec = vehicle:GetAngles():Right() * -1
				local ang = pl:AlignAngles( pl:GetAngles(), vec:Angle() )
				pl:SetAngles( ang )
				pl:SetEyeAngles( ang )			
			end
		end
	end
	hook.Add("PlayerLeaveVehicle", "VehicleExit", VehicleExit)
	
	local function VehicleEntered( pl, vehicle )
		if( vehicle:GetClass() ~= "prop_vehicle_prisoner_pod" ) then return end
		if( not vehicle.InShip ) then
			pl:SetEyeAngles( Angle(0,90,0) )
		end
	end	
	hook.Add("PlayerEnteredVehicle", "VehicleEntered", VehicleEntered)
end