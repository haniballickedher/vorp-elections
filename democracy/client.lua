--Still to do:  
---Build election cleanup scripts
---Set up election "terms"
--Add prop config for voting booth with optional flag
--cascade delete votes for people who stoprunning
local VORPcore = {} -- core object

TriggerEvent("getCore", function(core)
    VORPcore = core
end)
local VORPMenu = {}

TriggerEvent("vorp_menu:getData",function(cb)
    VORPMenu = cb
   end)

--Following Thread looks for ped in radius of voting locations the in config and offers G for menu
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        for k, v in pairs(Config.VotingLocations) do 
            local distance = GetDistanceBetweenCoords(coords, v.coords.x, v.coords.y, v.coords.z, true)
            
            if distance < 10.0 then
                DrawTxt('Press G to Vote', 0.50, 0.85, 0.7, 0.7, true, 255, 255, 255, 255, true)
                
                if IsControlJustReleased(0, 0x760A9C6F) then
                    local city = v.city 
                    local region = v.region
                    TriggerEvent('democracy:votingbooth',city, region)   
                    Citizen.Wait(1000)
                end
            end
        end
        
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('democracy:votingbooth')
AddEventHandler('democracy:votingbooth', function(city, region)
    local vcity = city
    local vregion = region
    local onBallot = false
    --Check if on ballot anywhere
    TriggerEvent("vorp:ExecuteServerCallBack", "democracy:checkonballot", function(cb)
        onBallot = cb
        print("onBallot: ",onBallot)

    -- Check if registered
    TriggerEvent("vorp:ExecuteServerCallBack", "democracy:checkRegistration", function(cb)
    
        local result = cb
       
        
        if result then
            print("Player is registered.")
            OpenStartMenu(true, vcity, vregion, onBallot)
        else
            print("Player is not registered.")
            local button = "Register to Vote in " .. vcity
            local placeholder = "y or n"

            TriggerEvent("vorpinputs:getInput", button, placeholder, function(answer)
                print("User input received:", answer)
                if answer == "y" or answer == "Y" then
                    TriggerServerEvent('registerVoter', vcity, vregion)
                    TriggerEvent("vorp:TipBottom", ("You have registered to vote in " .. vcity), 4000)
                    OpenStartMenu(true, vcity, vregion,onBallot)
                else
                    TriggerEvent("vorp:TipBottom", ("You don't want to vote?"), 4000)
                    OpenStartMenu(false,vcity,vregion,onBallot)
                end
            end)
        end
    end, { city = vcity, region = vregion })
end)
end)

function OpenStartMenu(registered, city, region, onBallot)
    VORPMenu.CloseAll()
    local menuElements = {
        { label = "Exit Menu", value = "exit_menu", desc = "Close Menu" },
    }
    local addMenuElement
    if registered then
        addMenuElement = { label = "Vote in " .. city .. " - " .. region, value = "vote", desc = "Vote" }
        table.insert(menuElements, 1, addMenuElement)
    end
    if onBallot then
        addMenuElement = { label = "Stop Running for Office", value = "stoprunning", desc = "Remove yourself from running for office" }
        table.insert(menuElements, 1, addMenuElement)
    else 
        addMenuElement = { label = "Run for Office", value = "run", desc = "Run for office" }
        table.insert(menuElements, 1, addMenuElement)
    end

    -- Open the menu using VORPMenu
    VORPMenu.Open(
        "default",
        GetCurrentResourceName(),
        "votingmenu",
        {
            title = city .. " Voting Booth",
            subtext = "Vote or Run",
            align = "top-center",
            elements = menuElements,
            itemHeight = "4vh",
        },
        function(data, menu)
            if data.current.value == "vote" then
                OpenVoteMenu(registered, city, region, onBallot)
            elseif data.current.value == "stoprunning" then 
                TriggerEvent("democracy:stoprunning")
                menu.close()
            elseif data.current.value == "run" then
                OpenRunMenu(registered, city, region, onBallot)
            elseif data.current.value == "exit_menu" then
                print("close")
                menu.close()
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function OpenRunMenu(registered, city, region, onBallot)
    VORPMenu.CloseAll()
    local vcity = city
    local vregion = region
    local menuElements = {}
    
    local addMenuElement
    for k,v in pairs(Config.Positions) do
        addMenuElement ={ label = v.name, value = v.name, desc = "Run for this"..v.jurisdiction.." office" }
        table.insert(menuElements, addMenuElement)  
    end
    addMenuElement= { label = "Main Menu", value = "back", desc = "Back to Main Menu" }
    table.insert(menuElements,addMenuElement)
    addMenuElement = { label = "Exit Menu", value = "exit_menu", desc = "Close Menu" }
    table.insert(menuElements,addMenuElement)
    
   
    -- Open the menu using VORPMenu
    VORPMenu.Open(
        "default",
        GetCurrentResourceName(),
        "runmenu",
        {
            title = "Run for Office",
            subtext = " in "..vcity..", "..vregion,
            align = "top-center",
            elements = menuElements,
            itemHeight = "4vh",
        },
        function(data, menu)
            if data.current.value == "back" then
                OpenStartMenu(registered, city, region, onBallot)
            elseif data.current.value == "exit_menu" then
                print("close")
                menu.close()
            else
                TriggerServerEvent('addballotname', vcity, vregion, data.current.value)
                local message = "You are now officially on the ballot for "..data.current.value
                TriggerEvent("vorp:TipBottom", (message), 4000)
                local nowonBallot = true
                menu.close()
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function OpenVoteMenu(registered, city, region, onBallot)
    VORPMenu.CloseAll()
    local vcity = city
    local vregion = region
    local menuElements = {}
    
    local addMenuElement
    for k,v in pairs(Config.Positions) do
        addMenuElement ={ label = v.name, value = v.name, desc = "Vote for"..v.name }
        table.insert(menuElements, addMenuElement)  
    end
    addMenuElement= { label = "Main Menu", value = "back", desc = "Back to Main Menu" }
    table.insert(menuElements,addMenuElement)
    addMenuElement = { label = "Exit Menu", value = "exit_menu", desc = "Close Menu" }
    table.insert(menuElements,addMenuElement)
    
   
    -- Open the menu using VORPMenu
    VORPMenu.Open(
        "default",
        GetCurrentResourceName(),
        "votemenu",
        {
            title = "Vote",
            subtext = " in "..vcity..", "..vregion,
            align = "top-center",
            elements = menuElements,
            itemHeight = "4vh",
        },
        function(data, menu)
            if data.current.value == "back" then
                OpenStartMenu(registered, city, region, onBallot)
            elseif data.current.value == "exit_menu" then
                print("close")
                menu.close()
            else               
                --Open Candidate Menu
                OpenCandidatesMenu(registered,city,region,data.current.value,onBallot)

            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function OpenCandidatesMenu(registered, city, region, position, onBallot)
    VORPMenu.CloseAll()
    local vcity = city
    local vregion = region
    local position = position
    local menuElements = {}
    local addMenuElement
    local jurisdiction

    for k, v in pairs(Config.Positions) do
        if v.name == position then
            jurisdiction = string.lower(v.jurisdiction)
        end
    end

    print(vcity, vregion, position, jurisdiction)

    TriggerEvent("vorp:ExecuteServerCallBack", "democracy:getCandidates", function(cb)
        local result = cb
        if #cb == 0 then
            print("No candidates found.")
            TriggerEvent("vorp:TipBottom", "No candidates found for this position.", 4000)
        end

        for k, v in pairs(cb) do
            label = cb[k].name
            value = cb[k].cid
            ballotID = cb[k].ballotID
            
            addMenuElement = { label = label, value = value, ballotid =ballotID, desc = "Vote for this candidate" }
            table.insert(menuElements, addMenuElement)
        end

        addMenuElement = { label = "Vote for Other Positions", value = "back", desc = "Back" }
        table.insert(menuElements, addMenuElement)
        addMenuElement = { label = "Exit Menu", value = "exit_menu", desc = "Close Menu" }
        table.insert(menuElements, addMenuElement)

        -- Open the menu using VORPMenu
        VORPMenu.Open(
            "default",
            GetCurrentResourceName(),
            "reallyvotemenu",
            {
                title = "Vote for Candidate",
                subtext = " in " .. vcity .. ", " .. vregion,
                align = "top-center",
                elements = menuElements,
                itemHeight = "4vh",
            },
            function(data, menu)
                if data.current.value == "back" then
                    OpenVoteMenu(registered, city, region, onBallot)
                elseif data.current.value == "exit_menu" then
                    print("close")
                    menu.close()
                else
                    local selectedBallotID = data.current.ballotid
                    local selectedCandidateID = data.current.value
                    CastVote(registered,city,region,position,jurisdiction,selectedCandidateID,selectedBallotID,onBallot)

                end
            end,
            function(data, menu)
                menu.close()
            end
        )
    end, { city = vcity, region = vregion, jurisdiction = jurisdiction, position = position })
end

function CastVote(registered,city, region, position,jurisdiction,candidateid,ballotid,onballot)
    local vcity = city
    local vregion = region
    local position = position
    local jurisdiction = jurisdiction
    local candidateid = candidateid
    local ballotid =ballotid
    local onBallot = onballot
    print("from client:", vcity, vregion, position, jurisdiction,"ballot:", ballotId, "cand:", candidateid)

    TriggerEvent("vorp:ExecuteServerCallBack", "democracy:hasvotervotedalready", function(cb)
        local result = cb
        if cb then 
            local button = "You have already voted in this race.  Do you wish to remove your vote and vote again?"
            local placeholder = "y or n"
            TriggerEvent("vorpinputs:getInput", button, placeholder, function(answer)
                print("User input received:", answer)
                if answer == "y" or answer == "Y" then
                    TriggerEvent("vorp:TipBottom", ("Your vote has been reset for this position"), 4000) 
                    TriggerServerEvent('updateVote', vcity, vregion, position, jurisdiction, candidateid, ballotid)
                    TriggerEvent("vorp:TipBottom", ("You have cast your vote for "..jurisdiction.." "..position.." in "..vcity.." "..vregion), 4000) 
                    OpenVoteMenu(registered, city, region, onBallot)
                else
                    TriggerEvent("vorp:TipBottom", ("Ok, your old vote stands, your new vote has been cancelled"), 4000) 
              
                end
            end)
        
        else
            local button = "You are about to place a vote for "..jurisdiction.." "..position.." in "..vcity.." "..vregion.." ".." Press y to confirm."
            local placeholder = "y or n"
            TriggerEvent("vorpinputs:getInput", button, placeholder, function(answer)
                print("User input received:", answer)
                if answer == "y" or answer == "Y" then
                   
                    TriggerServerEvent('addNewVote', vcity, vregion, position, jurisdiction, candidateid, ballotid)
                    TriggerEvent("vorp:TipBottom", ("You have cast your vote for "..jurisdiction.." "..position.." in "..vcity.." "..vregion), 4000) 
                    OpenVoteMenu(registered, city, region, onBallot)
                end
            end)    
        end
    end, { city = vcity, region = vregion, jurisdiction = jurisdiction, position = position, candidateid, ballotid })
end

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
	SetTextCentre(centre)
	SetTextFontForCurrentCommand(15) 
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	--Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end
RegisterNetEvent('democracy:stoprunning')
AddEventHandler('democracy:stoprunning', function()
    --Lets get what they are running for from the database and show them.
    TriggerEvent("vorp:ExecuteServerCallBack", "democracy:runningstatus", function(cb)
        local result = cb
        print(result)
        local button = "Are you sure you wish to stop running for" .. result.."?.  This cannot be undone."
        local placeholder = "y or n"

            TriggerEvent("vorpinputs:getInput", button, placeholder, function(answer)
                print("User input received:", answer)
                if answer == "y" or answer == "Y" then
                    TriggerServerEvent("removeFromBallot")
                    TriggerEvent("vorp:TipBottom", ("You have removed your name from the slate for " .. result), 4000) 
                else
                    TriggerEvent("vorp:TipBottom", ("Ok, you will remain in the running for " .. result), 4000) 
                end
            end)
        
    end)
end)
RegisterCommand("electionresults", function()
        TriggerEvent("vorp:ExecuteServerCallBack", "democracy:isAdmin", function(cb)
            local results=cb
            print(results)
            if results then
                TriggerServerEvent("openelectionresultsmenu")
            else
                TriggerEvent("vorp:TipBottom", ("Only Election Officials are authorized to use this command. "), 4000) 
            end  
    end)
  
end)


--[[ RegisterCommand("resetelection", function()
    TriggerEvent("vorp:ExecuteServerCallBack", "democracy:isAdmin", function(cb)
        local result = cb
        print("is it true", result)
        if result then 
            local button = "Are you sure you wish to delete all the votes and candidates from the database? This cannot be undone."
            local placeholder = "y or n"
            TriggerEvent("vorpinputs:getInput", button, placeholder, function(answer)
            print("User input received:", answer)
            if answer == "y" or answer == "Y" then
                TriggerServerEvent("cleanupScript")
                TriggerEvent("vorp:TipBottom", ("Cleanup Processing" .. result), 4000) 
            else
            TriggerEvent("vorp:TipBottom", ("Cleanup Canceled" .. result), 4000) 
             end
            end)
        else
            TriggerEvent("vorp:TipBottom", ("Not authorized" .. result), 4000) 
        end

        end)
end) ]]


RegisterNetEvent('democracy:openElecResMenu')
AddEventHandler('democracy:openElecResMenu', function()
    VORPMenu.CloseAll()
    local menuElements = {}
    
    local addMenuElement
    for k,v in pairs(Config.Positions) do
        addMenuElement ={ label = v.name, value = v.name, desc = "Show results" }
        table.insert(menuElements, addMenuElement)  
    end
    
    addMenuElement = { label = "Exit Menu", value = "exit_menu", desc = "Close Menu" }
    table.insert(menuElements,addMenuElement)
    
    -- Open the menu using VORPMenu
    VORPMenu.Open(
        "default",
        GetCurrentResourceName(),
        "runmenu",
        {
            title = "Election Results",
            subtext = "Election Officials Only",
            align = "top-center",
            elements = menuElements,
            itemHeight = "4vh",
        },
        function(data, menu)
            if data.current.value == "exit_menu" then
                menu.close()
            else
                RaceSelectedResults(data.current.value)
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end)


function RaceSelectedResults(position)
    VORPMenu.CloseAll()
    local vposition = position
    local menuElements = {}
    local addMenuElement
    local jurisdiction
    local locations ={}
    local addlocation

    for k, v in pairs(Config.Positions) do
        if v.name == position then
            jurisdiction = string.lower(v.jurisdiction)
        end
    end

    for k,v in pairs(Config.VotingLocations) do
        local valueToAdd
        local labelToAdd
        local descToAdd
    
        if jurisdiction == "local" then
            valueToAdd = Config.VotingLocations[k].city
            labelToAdd = Config.VotingLocations[k].city
            descToAdd = Config.VotingLocations[k].city
        elseif jurisdiction == "regional" then
            valueToAdd = Config.VotingLocations[k].region
            labelToAdd = Config.VotingLocations[k].region
            descToAdd = Config.VotingLocations[k].region
        elseif jurisdiction == "federal" then
            showResults(position, "federal", "federal")
            break
        end
    
        -- Check if the valueToAdd already exists in menuElements
        local exists = false
        for _, element in ipairs(menuElements) do
            if element.value == valueToAdd then
                exists = true
                break
            end
        end
    
        -- If the value doesn't exist, insert the new element
        if not exists then
            addMenuElement = { label = labelToAdd, value = valueToAdd, desc = descToAdd, position = position, jurisdiction = jurisdiction }
            table.insert(menuElements, addMenuElement)
        end
    end
    
   
 

        addMenuElement = { label = "Results for Other Positions", value = "back", desc = "Back" }
        table.insert(menuElements, addMenuElement)
        addMenuElement = { label = "Exit Menu", value = "exit_menu", desc = "Close Menu" }
        table.insert(menuElements, addMenuElement)

        -- Open the menu using VORPMenu
        VORPMenu.Open(
            "default",
            GetCurrentResourceName(),
            "reallyvotemenu",
            {
                title = "Results",
                subtext = " for "..vposition,
                align = "top-center",
                elements = menuElements,
                itemHeight = "4vh",
            },
            function(data, menu)
                if data.current.value == "back" then
                    TriggerEvent('democracy:openElecResMenu')
                elseif data.current.value == "exit_menu" then
                    print("close")
                    menu.close()
                else
                    local position = data.current.position
                    local location = data.current.value
                    local jurisdiction = data.current.jurisdiction
                    showResults(position, location, jurisdiction)
                end
            end,
            function(data, menu)
                menu.close()
            end
        )
    end

    

    function showResults(position, location, jurisdiction)
        VORPMenu.CloseAll()
        local vcity = city
        local vregion = region
        local position = position
        local menuElements = {}
        local addMenuElement
        local position  = position
        local location = location
        local jurisdiction = jurisdiction      
        local subtitle
        print(position..location..jurisdiction)
        TriggerEvent("vorp:ExecuteServerCallBack", "democracy:getResults", function(cb)
            local result = cb
            if #cb == 0 then
                print("No candidates found.")
                TriggerEvent("vorp:TipBottom", "No candidates found for this position.", 4000)
                subtitle = "No candidates"
            end
            for k, v in pairs(cb) do
                
                label = cb[k].candidate_name.." - "..cb[k].votes.." votes"
                value = cb[k].candidate_name
                
                addMenuElement = { label = label, value = value }
                table.insert(menuElements, addMenuElement)
            end
    
            addMenuElement = { label = "Back", value = "back", desc = "Back" }
            table.insert(menuElements, addMenuElement)
            addMenuElement = { label = "Exit Menu", value = "exit_menu", desc = "Close Menu" }
            table.insert(menuElements, addMenuElement)
    
            -- Open the menu using VORPMenu
            VORPMenu.Open(
                "default",
                GetCurrentResourceName(),
                "reallyresults",
                {
                    title = "Results for "..position,
                    subtext = "Results",
                    align = "top-center",
                    elements = menuElements,
                    itemHeight = "4vh",
                },
                function(data, menu)
                    if data.current.value == "back" then
                        if jurisdiction ~="federal" then
                            RaceSelectedResults(position)
                        else 
                            TriggerEvent('democracy:openElecResMenu')
                        end
          
                    elseif data.current.value == "exit_menu" then
                        
                        menu.close()
                    else
                        --donothing. it is the end of the road, finally
    
                    end
                end,
                function(data, menu)
                    menu.close()
                end
            )
        end, { location = location, position = position, jurisdiction=jurisdiction })
    end

  