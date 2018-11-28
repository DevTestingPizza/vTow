--[[
        
        vTow
        A simple vehicle tow script for FiveM servers.
        Including trailers support.
        
        Copyright © Vespura 2018
        https://www.vespura.com
        
        Example video:
        https://streamable.com/wpk3s
        
]]

function ShowNotification(text1, text2, text3)
    SetNotificationTextEntry("THREESTRINGS")
    AddTextComponentSubstringPlayerName(text1)
    AddTextComponentSubstringPlayerName(text2)
    AddTextComponentSubstringPlayerName(text3)
    DrawNotification(true, true)
end

local currentSelection = nil
local towtruck = nil
local target = nil
local helpstate = 1
local towSetupMode = false
local towing = false

RegisterCommand("tow", function(source, args)
    ClearAllHelpMessages()
    ClearHelp(true)
    ClearDrawOrigin()
    if towing then
        towing = false
        DetachEntity(target, true, true)
        local coords = GetOffsetFromEntityInWorldCoords(towtruck, 0.0, -10.0, 0.0)
        
        SetEntityCoords(target, coords, false, false, false, false)
        SetVehicleOnGroundProperly(target)
        towtruck = nil
        target = nil
    else
        if target ~= nil and towtruck ~= nil then
            local towPos = GetOffsetFromEntityInWorldCoords(towtruck, 0.0, -1.9, 3.5)
            SetEntityCoords(target, towPos, false, false, false, false)
            Citizen.Wait(2000)
            local targetPos = GetEntityCoords(target, true)
            local attachPos = GetOffsetFromEntityGivenWorldCoords(towtruck, targetPos.x, targetPos.y, targetPos.z)
            AttachEntityToEntity(target, towtruck, -1, attachPos.x, attachPos.y, attachPos.z, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
            towSetupMode = false
            helpstate = 0
            towing = true
        elseif not towSetupMode then
            ShowNotification("Go to your ~r~towtruck ~s~and when you see the", "~y~yellow ~s~marker, press ~r~~h~HOME~h~", "~s~to select the vehicle.")
            towSetupMode = true
            towtruck = nil
            target = nil
            helpstate = 1
        else
            towSetupMode = false
            towtruck = nil
            target = nil
            helpstate = 3
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        if towSetupMode then
            local veh = nil
            if helpstate == 3 then
                helpstate = 0
            end
            if helpstate ~= 0 then
                local pos = GetEntityCoords(PlayerPedId(), true)
                local targetPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, -1.0)
                local rayCast = StartShapeTestCapsule(pos.x, pos.y, pos.z, targetPos.x, targetPos.y, targetPos.z, 2, 10, PlayerPedId(), 7)
                local _,hit,_,_,veh = GetShapeTestResult(rayCast)
                if hit and DoesEntityExist(veh) and IsEntityAVehicle(veh) then
                    currentSelection = veh
                    if (IsControlJustPressed(0, 213)) then
                        if helpstate == 1 then
                            ShowNotification("Go to your ~o~target vehicle~s~ and when you see the", "~y~yellow ~s~marker, press ~r~~h~HOME~h~", "~s~to confirm the vehicle to tow.")
                            towtruck = veh
                            helpstate = 2
                        elseif helpstate == 2 and veh ~= towtruck then
                            ShowNotification("Vehicles have been confirmed.", "~r~/tow ~s~to start towing, or press", "~r~~h~HOME~h~~s~ to cancel.")
                            target = veh
                            helpstate = 3
                        end
                    end
                else
                    currentSelection = nil
                end
            elseif helpstate == 0 and IsControlJustPressed(0, 213) and towtruck ~= nil and target ~= nil then
                towtruck = nil
                target = nil
                helpstate = 1
            end
            
            DisableControlAction(0, 44)
        else
            currentSelection = nil
        end
        Citizen.Wait(0)
        
    end
end)

local markerType = 0
local scale = 0.3
local alpha = 255
local bounce = true
local faceCam = false
local iUnk = 0
local rotate = false
local textureDict = nil
local textureName = nil
local drawOnents = false

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/tow', 'Start/stop the towing setup or attach/detach a towed vehicle.')
    while true do
        Citizen.Wait(0)
        if towSetupMode then
            if (currentSelection ~= nil and currentSelection ~= towtruck) then
                local pos = GetEntityCoords(currentSelection, true)
                local red = 255
                local green = 255
                local blue = 0
                DrawMarker(markerType, pos.x, pos.y, pos.z + 2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale, scale, scale - 0.1, red, green, blue, alpha, bounce, faceCam, iUnk, rotate, textureDict, textureName, drawOnents)
            end
            if (towtruck ~= nil) then
                local pos = GetEntityCoords(towtruck, true)
                local red = 255
                local green = 50
                local blue = 0
                DrawMarker(markerType, pos.x, pos.y, pos.z + 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale, scale, scale - 0.1, red, green, blue, alpha, bounce, faceCam, iUnk, rotate, textureDict, textureName, drawOnents)
            end
            if (target ~= nil) then
                local pos = GetEntityCoords(target, true)
                local red = 255
                local green = 0
                local blue = 50
                DrawMarker(markerType, pos.x, pos.y, pos.z + 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale, scale, scale - 0.1, red, green, blue, alpha, bounce, faceCam, iUnk, rotate, textureDict, textureName, drawOnents)
            end
        end
    end
end)
