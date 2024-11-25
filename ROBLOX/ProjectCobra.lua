------------------------------------------------
--------------[[ Project Cobra ]]---------------
--------[[ MrLonely1221 & WaverlyCole ]]--------
------------------------------------------------


--//Security
local Module = script;script=nil;
Module.Name = "Project Cobra";
Module.Archivable=false;
local Assets = require(03624313593);
local Modules = {}; --//Modules are now internal.

--//Internal Modules

local Encryption = {};

local Encodes = {}
Encodes.a = [[`]]
Encodes.b = [[~]]
Encodes.c = [[!]]
Encodes.d = [[@]]
Encodes.e = [[#]]
Encodes.f = [[$]]
Encodes.g = [[%]]
Encodes.h = [[^]]
Encodes.i = [[&]]
Encodes.j = [[*]]
Encodes.k = [[(]]
Encodes.l = [[)]]
Encodes.m = [[_]]
Encodes.n = [[))]]
Encodes.o = [[-]]
Encodes.p = [[=]]
Encodes.q = [[|]]
Encodes.r = [[{]]
Encodes.s = [[}]]
Encodes.t = "]"
Encodes.u = "["
Encodes.v = [[;]]
Encodes.w = [[:]]
Encodes.x = [[']]
Encodes.y = [["]]
Encodes.z = [[\]]
Encodes['1'] = [[<]]
Encodes['2'] = [[>]]
Encodes['3'] = [[,]]
Encodes['4'] = [[~-]]
Encodes['5'] = [[?]]
Encodes['6'] = [[/]]
Encodes['7'] = [[^^]]
Encodes['8'] = [[**]]
Encodes['9'] = [[##]]
Encodes['0'] = [[!!]]
Encodes['Space'] = [[__]]

local Split = function (inputstr,sep)
	local t,i = {},1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end
local EncodeEncryption = function(cipher)
	local String = {}
	for i = 1,#cipher do
		local Find = cipher:sub(i,i)
		if Find == ' ' then Find = 'Space' end 
		local Encode = Encodes[Find]
		table.insert(String,i,Encode..'.')
	end
	return table.concat(String)
end
local DecodeEncryption = function(cipher)
	local String = {}
	local Args = Split(cipher,'.')
	for i = 1,#Args do
		local Find = Args[i]
		for x,y in pairs(Encodes) do
			if y == Find then
				if x == 'Space' then x = ' ' end
				table.insert(String,i,x)
			end
		end
	end
	return table.concat(String)
end

Encryption.Decrypt = function(cipher,key)
	cipher = DecodeEncryption(cipher)
	local key_bytes
	key = tostring(key)
	if type(key) == "string" then
		key_bytes = {}
		for key_index = 1, #key do
			key_bytes[key_index] = string.byte(key, key_index)
		end
	else
		key_bytes = key
	end
	local cipher_raw_length = #cipher
	local key_length = #key_bytes
	local cipher_bytes = {}
	local cipher_length = 0
	local cipher_bytes_index = 1
	for byte_str in string.gmatch(cipher, "%x%x") do
		cipher_length = cipher_length + 1
		cipher_bytes[cipher_length] = tonumber(byte_str, 16)
	end
	local random_bytes = {}
	local random_seed = 0
	for key_index = 1, key_length do
		random_seed = (random_seed + key_bytes[key_index] * key_index) * 1103515245 + 12345
		random_seed = (random_seed - random_seed % 65536) / 65536 % 4294967296
	end
	for random_index = 1, (cipher_length - key_length + 1) * key_length do
		random_seed = (random_seed % 4194304 * 1103515245 + 12345)
		random_bytes[random_index] = (random_seed - random_seed % 65536) / 65536 % 256
	end
	local random_index = #random_bytes
	local last_key_byte = key_bytes[key_length]
	local result_bytes = {}
	for cipher_index = cipher_length, key_length, -1 do
		local result_byte = cipher_bytes[cipher_index] - last_key_byte
		if result_byte < 0 then
			result_byte = result_byte + 256
		end
		result_byte = result_byte - random_bytes[random_index]
		random_index = random_index - 1
		if result_byte < 0 then
			result_byte = result_byte + 256
		end
		for key_index = key_length - 1, 1, -1 do
			cipher_index = cipher_index - 1
			local cipher_byte = cipher_bytes[cipher_index] - key_bytes[key_index]
			if cipher_byte < 0 then
				cipher_byte = cipher_byte + 256
			end
			cipher_byte = cipher_byte - result_byte
			if cipher_byte < 0 then
				cipher_byte = cipher_byte + 256
			end
			cipher_byte = cipher_byte - random_bytes[random_index]
			random_index = random_index - 1
			if cipher_byte < 0 then
				cipher_byte = cipher_byte + 256
			end
			cipher_bytes[cipher_index] = cipher_byte
		end
		result_bytes[cipher_index] = result_byte
	end
	local result_characters = {}
	for result_index = 1, #result_bytes do
		result_characters[result_index] = string.char(result_bytes[result_index])
	end
	return table.concat(result_characters)
end
Encryption.Encrypt = function(message,key)
	local key_bytes
	key = tostring(key)
	if type(key) == "string" then
		key_bytes = {}
		for key_index = 1, #key do
			key_bytes[key_index] = string.byte(key, key_index)
		end
	else
		key_bytes = key
	end
	local message_length = #message
	local key_length = #key_bytes
	local message_bytes = {}
	for message_index = 1, message_length do
		message_bytes[message_index] = string.byte(message, message_index)
	end
	local result_bytes = {}
	local random_seed = 0
	for key_index = 1, key_length do
		random_seed = (random_seed + key_bytes[key_index] * key_index) * 1103515245 + 12345
		random_seed = (random_seed - random_seed % 65536) / 65536 % 4294967296
	end
	for message_index = 1, message_length do
		local message_byte = message_bytes[message_index]
		for key_index = 1, key_length do
			local key_byte = key_bytes[key_index]
			local result_index = message_index + key_index - 1
			local result_byte = message_byte + (result_bytes[result_index] or 0)
			if result_byte > 255 then
				result_byte = result_byte - 256
			end
			result_byte = result_byte + key_byte
			if result_byte > 255 then
				result_byte = result_byte - 256
			end
			random_seed = (random_seed % 4194304 * 1103515245 + 12345)
			result_byte = result_byte + (random_seed - random_seed % 65536) / 65536 % 256
			if result_byte > 255 then
				result_byte = result_byte - 256
			end
			result_bytes[result_index] = result_byte
		end
	end
	local result_buffer = {}
	local result_buffer_index = 1
	for result_index = 1, #result_bytes do
		local result_byte = result_bytes[result_index]
		result_buffer[result_buffer_index] = string.format("%02x", result_byte)
		result_buffer_index = result_buffer_index + 1
	end
	return EncodeEncryption(table.concat(result_buffer))
end


Modules.Encryption = Encryption

--[[	USAGE:
	
	
	local GetDate = require(somewhere.GetDate)
	
	local date = GetDate()
		-- Returns a table containing the following:
			- total: seconds since Jan. 1, 1970
			- seconds: current seconds relative to minute
			- minutes: current minute relative to hour
			- hours: current hour (0-23) relative to day
			- hoursPm: current hour (1-12) relative to day
			- year: current year (2014)
			- yearShort: current year (14)
			- isLeapYear: true or false, indicating if current year is a leap year
			- isAm: true if morning, false if afternoon
			- month: numerical month of year (3)
			- monthWord: month of year (March)
			- day: day of the month
			- dayOfYear: day of the year
	
	
	Formatting dates:
		date:format(str)
		
		Where 'str' is a string formatter:
		
			#s  seconds
			#m  minutes
			#h  hours
			#H  hours AM/PM
			#Y  year
			#y  year short
			#a  AM/PM marker
			#W  month word
			#M  month numerical
			#d  day of month
			#D  day of year
			#t  total seconds
			
		Examples:
		
			local today = date:format("#W #d, #Y)
			print(today)
					> October 16, 2014
			
			local currentTime = date:format("#H:#m #a")
			print(currentTime)
					> 11:46 AM
	
	
--]]

function GetDate(t)
	local date = {}
	local months = {
		{"January", 31};
		{"February", 28};
		{"March", 31};
		{"April", 30};
		{"May", 31};
		{"June", 30};
		{"July", 31};
		{"August", 31};
		{"September", 30};
		{"October", 31};
		{"November", 30};
		{"December", 31};
	}
	if not t then t = tick() end
	date.total = t
	date.seconds = math.floor(t % 60)
	date.minutes = math.floor((t / 60) % 60)
	date.hours = math.floor((t / 60 / 60) % 24)
	date.year = (1970 + math.floor(t / 60 / 60 / 24 / 365.25))
	date.yearShort = tostring(date.year):sub(-2)
	date.isLeapYear = ((date.year % 4) == 0)
	date.isAm = (date.hours < 12)
	date.hoursPm = (date.isAm and date.hours or (date.hours == 12 and 12 or (date.hours - 12)))
	if (date.hoursPm == 0) then date.hoursPm = 12 end
	if (date.isLeapYear) then
		months[2][2] = 29
	end
	do
		date.dayOfYear = math.floor((t / 60 / 60 / 24) % 365.25)
		local dayCount = 0
		for i,month in pairs(months) do
			dayCount = (dayCount + month[2])
			if (dayCount > date.dayOfYear) then
				date.monthWord = month[1]
				date.month = i
				date.day = (date.dayOfYear - (dayCount - month[2]) + 1)
				break
			end
		end
	end
	function date:format(str)
		str = str
			:gsub("#s", ("%.2i"):format(self.seconds))
			:gsub("#m", ("%.2i"):format(self.minutes))
			:gsub("#h", tostring(self.hours))
			:gsub("#H", tostring(self.hoursPm))
			:gsub("#Y", tostring(self.year))
			:gsub("#y", tostring(self.yearShort))
			:gsub("#a", (self.isAm and "AM" or "PM"))
			:gsub("#W", self.monthWord)
			:gsub("#M", tostring(self.month))
			:gsub("#d", tostring(self.day))
			:gsub("#D", tostring(self.dayOfYear))
			:gsub("#t", tostring(self.total))
		return str
	end
	return date
end


Modules.GetDate = GetDate

local Cache = {}
--local SBTags = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("https://tusk.protosmasher.net/RBX_API/TAGS/server.php?APIKey=2&GetTags&Players"))
local GetInfo = function(UserId)
if Cache[UserId] then
	return Cache[UserId]
end

--local OwnedTags = {}
--local SBTags = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("https://tusk.protosmasher.net/RBX_API/TAGS/server.php?APIKey=2&GetTags&Players"))
--
--for i,v in pairs(SBTags) do
--	if v.userId == UserId then
--		table.insert(OwnedTags,v)
--	end
--end


local Source = ''
local succ,err = pcall(function()
	Source = game:service'HttpService':GetAsync("https://projectcobra.dannyftm.com/api/playerInfo.php?&userId="..UserId)
end)
if not succ then
	local succ,err = pcall(function()
		Source = game:service'HttpService':GetAsync("https://projectcobra.dannyftm.com/api/playerInfo.php?&userId="..UserId)
	end)
end

local PatternEscapeFind = function(Text1,Text2)
	Text2 = string.gsub(Text2, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
	return string.find(Text1,Text2)
end
local Split = function (inputstr,sep)
	local t,i = {},1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end
local SearchData = function (Type)
	local Type = "data-"..Type.."="
	local StartPlace = PatternEscapeFind(Source,Type)+#Type
	
	
	local Number = ''
	local Finished = false
	local CurrentChar = StartPlace
	
	while not Finished do
		local Char = Source:sub(CurrentChar,CurrentChar)
		if tonumber(Char) then
			Number = Number..Char
			CurrentChar = CurrentChar + 1
		else
			Finished = true
		end
	end	
	
	return Number
end

local StartAbout = PatternEscapeFind(Source,"Roblox and explore together!")+#"Roblox and explore together!"
local EndAbout = PatternEscapeFind(Source,[["><meta name=keywords content="]])-1

local PastNamesStart,PastNamesEnd = nil,nil
local PastNamesSucc = pcall(function()
	PastNamesStart = PatternEscapeFind(Source,[[tooltip-pastnames data-toggle=tooltip title="]])+#[[tooltip-pastnames data-toggle=tooltip title="]]
	PastNamesEnd = PatternEscapeFind(Source,[["> <span class=icon-pastname>]])-1
end)

local JoinDateStart = PatternEscapeFind(Source,[[Join Date<p class=text-lead>]])+#[[Join Date<p class=text-lead>]]
local JoinDateEnd = PatternEscapeFind(Source,[[<li class=profile-stat><p class=text-label>Place]])-1

local VisitsStart = PatternEscapeFind(Source,[[>Place Visits<p class=text-lead>]])+#[[>Place Visits<p class=text-lead>]]
local VisitsEnd = PatternEscapeFind(Source,[[</li></ul></div></div></div><div]])-1

local Friends = SearchData('friendscount')
local Followers = SearchData('followerscount')
local Following = SearchData('followingscount')
local About = Source:sub(StartAbout,EndAbout)
local PastNames = ''
if PastNamesSucc then
	PastNames = Source:sub(PastNamesStart,PastNamesEnd)
else
	PastNames = nil
end
local JoinDate = Source:sub(JoinDateStart,JoinDateEnd)
local PlaceVisits = Source:sub(VisitsStart,VisitsEnd)
local RAP = 'Failed'
pcall(function()
    local Data = game:service'HttpService':GetAsync([[https://nodewebserver-tuskor661.herokuapp.com/rap?userId=]]..UserId);
    pcall (function() Data = game:service'HttpService':JSONDecode(Data); end);
    if Data then
        if Data.RAP then
            RAP = Data['RAP']
        end
    end
end);

local Info = {}
Info['Friends'] = tonumber(Friends) or 'Failed'
Info['Followers'] = tonumber(Followers) or 'Failed'
Info['Following'] = tonumber(Following) or 'Failed'
Info['About'] = About or 'Failed'
Info['PastNames'] = PastNames or 'None'
Info['JoinDate'] = JoinDate or 'Failed'
Info['PlaceVisits'] = PlaceVisits or 'Failed'
Info['RAP'] = RAP or 'Failed'
Info['SBTags'] = {}--OwnedTags

Cache[UserId] = Info

return Info
end

Modules.UserData = GetInfo

--//Site Functions
local Site = {
	Link = "https://projectcobra.dannyftm.com/";
	HTTP = game:GetService("HttpService");
	Headers = {
		['Key'] = [[251EF652F40000006F28E568400000003CC43AB322000000000000005FE3119F]];
		['Job-Id'] = game.JobId;
		['Content-Type'] = "application/json";
	};
	Functions = {};
};
local CurrentPrice = {
	20;
	55;
	160;
};

function Site.Functions:sendData(Data, Link, Override)
	local Link = Link or "server.php";
	local Data = Data or {};
	Data = Site.HTTP:JSONEncode(Data);
	local Headers = Site.Headers;
	if Override then
		for Key, Value in ipairs(Override) do
			Headers[Key] = Value;
		end;
	end;
	
	local res;
	local succ, err = pcall(function()
		local Returned = Site.HTTP:RequestAsync({
			Url = Site.Link .. Link;
			Method = "POST";
			Headers = Headers;
			Body = Data;
		});
		
		if not Returned.Success then
			if not Returned.statusCode or Returned.statusMessage then
				return warn("Website error: No status found")
			end
			warn("Website error:\n\r\t" .. Returned.statusCode .. " - " .. Returned.statusMessage);
		end;
		
		--print(Returned.Body);
		if string.sub(Returned.Body, 0, 1) == "{" then
			res = Site.Functions:Decode(Returned.Body);
		else
			res = {['status'] = "Error"; ['body'] = "Website didn't return JSON."};
		end;
		
	end);
	
	if not succ then
		warn("sendData Error:", err);
		--print(Data)
	end;
	
	--print("send","\n",Link,"\n",Data,"\n",table.concat(Headers," "),"\n",res);
	
	return res;
end;

function Site.Functions:getData(Data, Link)
	local Link = Link or "server.php";
	if Link == "players.php" then
		--Link = "players2.php";
	end;
	local Data = Site.Functions:format(Data);
	local res;
	local succ, err = pcall(function()
		local Returned = Site.HTTP:RequestAsync({
			Url = Site.Link .. Link .. Data;
			Method = "GET";
			Headers = Site.Headers;
		});
		
		if not Returned.Success then
			if not Returned.statusCode or Returned.statusMessage then
				return warn("Website error: No status found")
			end
			warn("Website error:\n\r\t" .. Returned.statusCode .. " - " .. Returned.statusMessage);
		end;
		
		--warn("----------Start " .. Link .. "----------");
		--print(Returned.Body);
		--warn("----------End " .. Link .. "----------");
		if string.sub(Returned.Body, 0, 1) == "{" then
			res = Site.Functions:Decode(Returned.Body);
		else
			res = {['status'] = "Error"; ['body'] = "Website didn't return JSON."};
		end;

	end);
	
	if not succ then
		warn("getData Error:",err);
	end;
	
	--print("get","\n",Link,"\n",Data,"\n",table.concat(Headers," "),"\n",res);

	return res;
end;

function Site.Functions:Decode(String)
	return Site.HTTP:JSONDecode(String);
end;

function Site.Functions:Encode(String)
	return Site.HTTP:JSONEncode(String);
end;

function Site.Functions:format(Data)
	if Data == nil then
		return "";
	end;
	local Temp = "?";
	local Index = 0;
	for Key, Value in pairs(Data) do
		if Index > 0 then
			Temp = Temp .. "&";
		end;
		Temp = Temp .. Key .. "=" .. Value;
		Index = Index + 1;
	end;
	return Temp;
end;


Modules.WebModule = Site.Functions;

local MainEnv,ExeEnv = getfenv(0),{};
	
Module:Destroy();
print("[PC] Loading");

--//Yes i know this is absolute garbage
local Allowed;
local succ, err = pcall(function()
	Allowed = game:GetService("HttpService"):GetAsync("https://projectcobra.dannyftm.com/allowed.php");
end);
if not succ then
	warn("HttpService not enabled or is flooded: " .. err);
	while true do wait() end
	return 0;
end;
if Allowed == "2" then
	warn("Project Cobra request missing parameters.");
	while true do wait() end
	return 0;
elseif Allowed == "0" and not game.PlaceId == 1679056195 then
	warn("Project Cobra cannot run here.");
	while true do wait() end
	return 0;
end;

local Web = Modules.WebModule
local Encryption = Modules.Encryption
local GetDate = Modules.GetDate;

local Allowed;
local succ, err = pcall(function()
	Allowed = game:GetService("HttpService"):GetAsync("https://projectcobra.dannyftm.com/allowed.php");
end);
if not succ then
	warn("HttpService not enabled or is flooded. " .. err);
	return nil;
end;
if Allowed == "2" then
	warn("Project Cobra request missing parameters.");
	return nil;
elseif Allowed == "0" and not game.PlaceId == 1679056195 then
	warn("Project Cobra cannot run here.");
	return nil;
end;

--//Internal Settings
local Stats = {
	RemotesAveragePerMinute = 0;
	RemotesPerMinute = 0;
	ToalDataRefreshes = 0;
	TotalRemotes = 0;
};
local Settings = {
	AntiGlobalSounds = false;
	AdminName = "Project Cobra";
	BlockedAliasCommands = {
		['kick'] = true;
		['kill'] = true;
	};
	DataFailure = false;
	Debug = false;
	Messages = {
		Error = {
			ALREADY_VERIFIED = "Already verified.";
			CANNOT_REQUEST_HELP_PS = "Cannot request help in private servers.";
			GETINFO_TOO_MANY_USERS = "Info can only be seen for one user at a time.";
			HIGHER_RANK = "This User has a higher rank!";
			INSUFFICIENT_RANK = "Insufficient Rank.";
			INVALID_CODE = "Invalid code.";
			INVALID_INPUT = "Invalid input.";
			MAX_TIMES = "Limit for your rank is %d.";
			NO_ALIASES = "You do not have any aliases!";
			NO_HUMANOID = "Couldn't find HumanoidRootPart for player(s).";
			NO_KICK_REASON = "You did not specify a kick reason / it was too short!";
			NO_PLAYER = "No player(s) found.";
			NO_STAFF_ONLINE = "Could not find any online staff.";
			PREFIX_TOO_LONG = "Prefix can only be one character.";
			RANK_NOT_NUMBER = "Rank must be a number!";
			RESTRICTED_FROM_ALIAS = "Command \"%s\" restricted from having an alias set!";
			SEND_TO_DEV = "Command Error.\nSend screenshot to a Developer.";
			TOO_MANY_PLAYERS = "Too many players selected!";
			VERIFY_WEB_ERROR = "Web error.\nPlease try again.";
		};
		Status = {
			CHECKING_ONLINE_STAFF = "Checking for online staff..";
			LOADING = "Loading...";
			LOADING_INFO = "Loading info...\n(%d)";
			SETTING = "Setting %s...";
			TELEPORTING = "Teleporting...";
			UPDATED = "Updated!";
			UPDATING = "Updating...";
		};
		Success = {
			HELP_REQUEST_SENT = "Help request sent!";
			SET = "%s set!";
			SUFFICIENT_RANK = "Sufficient Rank";
			VERIFY = "Verify success!";
		};
	};
	Suffix = " ";
	Version = "1.0.03";
};


--//Local Cache
local Cache = {Tabs = {}; LoadConfirmations = {}; Info = {};};
local AntiDeath = {};
local BubbleChat = {};
local CommandLogs = {};
local NumUsers = 0;
local Online = {};
local NewOnline = {};
local Users = {};
local ClickEvents = {};
local Commands = {};
local ActivePlayers = {};
local Core = {};
local MorphHandler = require(Assets.MorphHandler)
--local PCDataStore = game:GetService("DataStoreService"):GetDataStore(Settings.AdminName);
local LockedProperties = {};
--//Command Logs
spawn(function()
	while wait(15) do
		Web:sendData({['Method'] = "log"; ['Commands'] = CommandLogs}, "logs.php");
		CommandLogs = {};
	end;
end);

--//New Online System
if not game:GetService("RunService"):IsStudio() then
	game:GetService("MessagingService"):SubscribeAsync("PCOnlineSystem", function(Data)
		local Data = Web:Decode(Data.Data)
		
		for Name,PlrData in pairs(Data) do
			for x,y in pairs(NewOnline) do
				if y.Username == PlrData.Username then
					table.remove(NewOnline,x) --If they are already in table, remove them
				end
			end
			table.insert(NewOnline,PlrData)
		end
	end)
	spawn(function()
		while true do
			local Data = {}
			for i,Player in pairs(ActivePlayers) do
				if Player:Rank() > 0 then
					local PlrData = {}
					PlrData.Seen = os.time()
					PlrData.JobId = game.JobId
					PlrData.PlaceId = game.PlaceId
					PlrData.Username = Player.Name
					PlrData.Rank = Player:Rank()
					
					table.insert(Data,PlrData)
				end
			end
			
			Data = Web:Encode(Data);
			
			game:GetService("MessagingService"):PublishAsync("PCOnlineSystem",Data)
			
			for Index,Data in pairs(NewOnline) do
				local TimePassed = math.floor((os.time() - Data.Seen) + .5)
				if TimePassed > 10 then
					table.remove(NewOnline,Index)
				end
			end
			
			wait(5)
		end
	end)
end

--//ItemChanged

game.ItemChanged:Connect(function(Object,ChangedProp)
	--//Property Lock
	pcall(function()
		if Object:IsDescendantOf(workspace) then
			for Class, Properties in pairs(LockedProperties) do
				if Object:IsA(Class) then
					if Properties[ChangedProp] then
						Object[ChangedProp] = Properties[ChangedProp]
					end
				end
			end
		end
	end)
end)

--//DescendantAdded

game.DescendantAdded:connect(function(Object)
    --//Property Lock
    pcall(function()
        for Class, Properties in pairs(LockedProperties) do
            if Object:IsA(Class) then
                spawn(function()
                    for Property, Value in pairs(Properties) do
                        pcall(function()
                          if type(Value) == "table" then
                            Object[Property] = math.clamp(Object[Property], unpack(Value));
                          else
                            Object[Property] = Value;
                          end;
                        end);
                    end;
                end);
            end;
        end;
    end);
    --//Anti Global Sounds
    spawn(function()
        pcall(function()
            if Object:IsA('Sound') and Settings.AntiGlobalSounds then
                if not Object.Parent:IsA('BasePart') and Object.Parent.ClassName ~= "PlayerGui" then
                    local ClosestPart = nil;
                    local CurrentCheck = Object.Parent;
                    repeat
                        local Part = CurrentCheck:FindFirstChildOfClass('Part') or CurrentCheck:FindFirstChildOfClass('PlayerGui');
                        if Part then
                            ClosestPart = Part;
                        else
                            CurrentCheck = CurrentCheck.Parent;
                        end;
                    until ClosestPart or CurrentCheck == workspace.Parent;
                    if ClosestPart then
                        repeat
                            local succ,err = pcall(function()
                              local found = false;
                              table.foreach(ClosestPart:GetChildren(), function(i,v)
                                if not found and v:IsA("Sound") then
                                  found = (v.SoundId == Object.SoundId);
                                end;
                              end);
                              if found then
                                Object:Destroy();
                              else
                                Object.Parent = ClosestPart;
                              end;
                            end);
                            wait();
                        until succ or not Object.Parent;
                    end;
                end;
            end;
        end);
    end);
end);

--//Old Property Lock
--spawn(function()
--	game:GetService("RunService").heartbeat:Connect(function()
--		for _, obj in pairs(game:GetDescendants()) do
--			for Class, Data in pairs(LockedProperties) do
--				if obj:IsA(Class) then
--					for Property, Value in pairs(Data) do
--						obj[Property] = Value;
--					end;
--				end;
--			end;
--		end;
--	end);
--end);

--//Events
spawn(function()
	local Previous = 0;
	local Checks = 0;
	while true do
		Checks = Checks + 1;
		local Current = Stats.TotalRemotes;
		local Difference = Current - Previous;
		Previous = Current;
		Stats.RemotesPerMinute = Difference;
		Stats.RemotesAveragePerMinute = math.floor(Stats.TotalRemotes/Checks + .5);
		wait(60);
	end;
end);
local Remote = nil;
local NewRemote;NewRemote = function()
	Remote = Instance.new("RemoteEvent");
	local ReplicatedStorage = game:GetService("ReplicatedStorage");
	
	Remote.Name = "PCRemote";
	Remote.Parent = ReplicatedStorage;
	
	local RunRemote = function(RawPlayer,Data)
		Stats.TotalRemotes = Stats.TotalRemotes + 1;
		local Player = nil;
		for x,y in pairs(ActivePlayers) do
			if y.PlrObj == RawPlayer then
				Player = y;
			end;
		end;
		if Player then
			for x,y in pairs(Data) do
				if type(y) == "string" then
					Data[x] = Encryption.Decrypt(y,Player.UserId);
				end;
			end;
			Player:GotEvent(Data);
		end;
	end;
	Remote.OnServerEvent:Connect(RunRemote);
	local Conn;Conn = Remote.AncestryChanged:connect(function(Parent)
		Conn:Disconnect();
		pcall(function()Remote:Destroy();end);
		NewRemote();
	end);
end;
NewRemote();
--//Help System and Broadcast system
local Loaded = false;
if not game:GetService("RunService"):IsStudio() then
	game:GetService("MessagingService"):SubscribeAsync("PCBroadcast", function(Data)
		Data = Web:Decode(Data.Data)
		
		for x,Player in pairs(ActivePlayers) do
			Player:NewTab(Data.msg.."\n\n~"..Data.from,"Lime green");
		end
	end)
	game:GetService("MessagingService"):SubscribeAsync("PCHelpSystem", function(helpData)
		helpData = Web:Decode(helpData.Data)
		if helpData.JobId ~= game.JobId then
			for i,Plr in pairs(ActivePlayers) do
				if Plr:Rank() >= 4 then
					Plr:NewTab("Help requested by "..helpData.RequestedBy.."!\n\n"..helpData.Reason.."\n\n","Lime green");
					Plr:NewTab("Join Server","Lime green",function()
						game:GetService("TeleportService"):TeleportToPlaceInstance(tonumber(helpData.PlaceId), tostring(helpData.JobId), Plr.PlrObj);
					end);
				end;
			end;
		else
			Core:SendToRank(4,"Help requested in your server by "..helpData.RequestedBy.."!","Lime green");
		end;
	end);
end
--//Rank Purchases
game:GetService("MarketplaceService").PromptGamePassPurchaseFinished:connect(function(Player, Id, Purchased)
	for i,v in pairs(ActivePlayers) do
		if v.PlrObj == Player then
			Player = v;
		end;
	end;
	
	if Purchased then
		if Users[tostring(Player.UserId)]['GamepassOverride'] == '0' then
			if Id == 4423994 and Player:Rank() < 3 then
				Player:SetData("Rank",3);
				Player:SetExtraData("RankChange-" .. os.time(), "Gamepass - 3");
				Player:SaveData();
				local Title = Player:NewTab("Rank 3 purchased!", "Lime green");
				local S = Instance.new("Sound",Player.PlayerGui);
				S.SoundId = "rbxassetid://2163823654";
				S.Volume = 1;
				S:Play();
				Player:NewTab("You can check your rank with\n"..Player:Prefix().."checkrank", "Lime green");
	--			Web:sendData({['Method'] = "add"; ['User-Id'] = Player.UserId; ['Product-Id'] = Id; ['Purchase-Amount'] = 100; ['Note'] = "None";}, "purchase.php");
			elseif Id == 4423993 and Player:Rank() < 2 then
				Player:SetData("Rank",2);
				Player:SetExtraData("RankChange-" .. os.time(), "Gamepass - 2");
				Player:SaveData();
				local Title = Player:NewTab("Rank 2 purchased!", "Lime green");
				local S = Instance.new("Sound",Player.PlayerGui);
				S.SoundId = "rbxassetid://2163823654";
				S.Volume = 1;
				S:Play();
				Player:NewTab("You can check your rank with\n"..Player:Prefix().."checkrank", "Lime green");
	--			Web:sendData({['Method'] = "add"; ['User-Id'] = Player.UserId; ['Product-Id'] = Id; ['Purchase-Amount'] = 40; ['Note'] = "None";}, "purchase.php");
			elseif Id == 4423991 and Player:Rank() < 1 then
				Player:SetData("Rank",1); 
				Player:SetExtraData("RankChange-" .. os.time(), "Gamepass - 1");
				Player:SaveData();
				local Title = Player:NewTab("Rank 1 purchased!", "Lime green");
				local S = Instance.new("Sound",Player.PlayerGui);
				S.SoundId = "rbxassetid://2163823654";
				S.Volume = 1;
				S:Play();
				Player:NewTab("You can check your rank with\n"..Player:Prefix().."checkrank", "Lime green");
	--			Web:sendData({['Method'] = "add"; ['User-Id'] = Player.UserId; ['Product-Id'] = Id; ['Purchase-Amount'] = 20; ['Note'] = "None";}, "purchase.php");
			end;
			Web:sendData({['Method'] = "add"; ['User-Id'] = Player.UserId; ['Product-Id'] = Id; ['Note'] = "None";}, "purchase.php");
		end;
	end;
end);

--//Core
Core.ToFormattedTime = function (self,Time)
	local Seconds = math.floor(Time % 60);
	local Minutes = math.floor((Time / 60) % 60);
	local Hours = math.floor((Time / 60 / 60) % 24);
	local Days = math.floor((Time / 60 / 60 / 24) % 365);
	return Days, Hours, Minutes, Seconds;
end;
Core.FromFormattedTime = function (self,Days,Hours,Minutes,Seconds)
	if not Days then Days = 0 end;
	if not Hours then Hours = 0 end;
	if not Minutes then Minutes = 0 end;
	if not Seconds then Seconds = 0 end;
	return (Days*86400) + (Hours*3600) + (Minutes*60) + (Seconds*1);
end;
Core.SendToRank = function(self, Rank, Text, Color, Function, TabPosition, TabCFrame)
	for i,Plr in pairs(ActivePlayers) do
		if Plr:Rank() >= Rank then
			Plr:NewTab(Text, Color, Function, TabPosition, TabCFrame);
		end;
	end;
end;
Core.UpdateGlobalData = function(self)
	Stats.ToalDataRefreshes = Stats.ToalDataRefreshes + 1;
	NumUsers = 0;
	Online = {};
	local AllData = Web:getData({['Action'] = "getall";}, "players.php");
	if not AllData or AllData == nil then Settings.DataFailure = true return; end;
	if AllData['status'] == "Success" then AllData = AllData['data']; else return warn("[PCData] Error:", AllData['data']); end;
	for Index,Data in pairs(AllData) do
		NumUsers = NumUsers + 1;
		if Data['ExtraData'] then
			local succ,err = pcall(function()Data['ExtraData'] = Web:Decode(Data['ExtraData']);end);
			if not succ then
				Data['ExtraData'] = {};
			end;
		end;
	end;
	Users = AllData;
	for User,Data in pairs(Users) do
		if Data.ExtraData then
			local Extra = Data.ExtraData;
			if Extra.JoinMessage and #Extra.JoinMessage > 0 then
				for i,Player in pairs(ActivePlayers) do
					if Player.UserId == tonumber(User) then
						Player:NewTab("[" .. Settings.AdminName .. " System Message]\n" .. Player:GetExtraData("JoinMessage"), "Lime green", function() Player:SetExtraData("JoinMessage", ""); end);
					end;
				end;
			end;
			if Extra.LastSeen and Extra.LastServer then
				if Extra.LastSeen ~= "Offline" then
					local TimePassed = os.difftime(os.time(),tonumber(Extra.LastSeen));
					local Username = Extra.Username;
					if not Username then
						Username = game:GetService("Players"):GetNameFromUserIdAsync(tonumber(User));
						Extra["Username"] = Username;
						local Data = {['Method'] = "update"; ['User-Id'] = tonumber(User);};
						for i,v in pairs(Users[tostring(User)]) do
							if i == "ExtraData" then Data[i] = Web:Encode(v) else Data[i] = v; end;
						end;
						Web:sendData(Data, "players.php");
					end;
					if TimePassed <= 20 and TimePassed > 0 then
						Extra["TimePassed"] = TimePassed;
						table.insert(Online,Data)
					end
				end
			end
		end
	end
	if NumUsers == 0 then
		Settings.DataFailure = true
	else
		Settings.DataFailure = false
	end
end;
Core.WrapPlayer = function(self, RealPlayer)
	local Player = newproxy(true);
	local Meta = getmetatable(Player);
	local CustomFunctions = {};
	local IsAfk = false;
	
	--//Custom Functions (All names lowercase)
	
	CustomFunctions.findrotpos = function(self)
		if not Player.Character then
			return Vector3.new(0,5,0),CFrame.new(0,5,0);
		end;
		if Player.Character:FindFirstChild('HumanoidRootPart') then
			return Player.Character.HumanoidRootPart.Position,Player.Character.HumanoidRootPart.CFrame;
		else
			return Vector3.new(0,5,0),CFrame.new(0,5,0);
		end;
	end;
	CustomFunctions.dismiss = function(self,Tab)
		if not Tab then return; end;
		for i,v in pairs(Cache.Tabs[Player]) do
			if v == Tab then
				table.remove(Cache.Tabs[Player],i);
			end;
		end;
		Player:SendData({"UpdateTabs",Cache.Tabs[Player]});
		Tab.Name = "Removed";
		Tab:Destroy();
	end;
	CustomFunctions.timeddismiss = function(self, Tab, Time)
		if not Tab then return; end;
		local Time = Time or 5;
		spawn(function()
			wait(Time);
			for i,v in pairs(Cache.Tabs[Player]) do
				if v == Tab then
					table.remove(Cache.Tabs[Player],i);
				end;
			end;
			Player:SendData({"UpdateTabs",Cache.Tabs[Player]});
			Tab.Name = "Removed";
			Tab:Destroy();
		end);
	end;
	CustomFunctions.dismissall = function(self,Tab)
		local Tabs = Cache.Tabs[Player];
		for _,Tab in pairs(Tabs) do
			if Tab then
				if Tab.Parent then
					Tab.Name = "Removed";
					Tab:Destroy();
				end;
			end;
		end;
		Cache.Tabs[Player] = {};
		Player:SendData({"UpdateTabs",Cache.Tabs[Player]});
	end;
	CustomFunctions.savedata = function(self, Override)
		local Override = Override or false;
		local Data = {['Method'] = "update"; ['User-Id'] = Player.UserId;};
		if Override then
			Data['Override'] = true;
		end;
		if Users[tostring(Player.UserId)] then
			for i,v in pairs(Users[tostring(Player.UserId)]) do
				if i == "ExtraData" then Data[i] = Web:Encode(v) else Data[i] = v; end;
			end;
			if not Users[tostring(Player.UserId)]['Prefix'] then
				Users[tostring(Player.UserId)]['Prefix'] = ".";
			end;
			if not Users[tostring(Player.UserId)]['ExtraData'] then
				Users[tostring(Player.UserId)]['ExtraData'] = Web:Encode({});
			end;
		end;
		Web:sendData(Data, "players.php");
		
		if Settings.DataFailure then
			if Player:Rank() >= 1 then
				Player:DismissAll()
				Player:NewTab("Data cannot save.\nNot connected to Database.","Persimmon",nil,function()
					while Tab.Parent do
						ChangeColor("Crimson");
						wait(.1);
						ChangeColor("Persimmon");
						wait(.1);
						ChangeColor("Really red");
						wait(.1);
					end;
				end);
			end
		end;
	end;
	CustomFunctions.vsbrank = function(self)
		return RealPlayer:GetRoleInGroup(3256759);
	end;
	CustomFunctions.afk = function(self,toggle)
		if IsAfk == true and toggle == false then
			IsAfk = false
		elseif IsAfk == false and toggle == true then
				IsAfk = true
				while wait() and IsAfk do
					if not Player.Character or Player.Character == nil then return; end;
					local Head = Player.Character:FindFirstChild("Head")
					if Head then
						local Tag = Head:FindFirstChild("AFK")
						if not Tag then
							local NewTag = Assets.AFK:Clone()
							NewTag.Parent = Head
						end
					end
				end
				local Head = Player.Character:FindFirstChild("Head")
				if Head then
					local Tag = Head:FindFirstChild("AFK")
					if Tag then
						Tag:Destroy()
					end
				end
		end
	end
	CustomFunctions.getdata = function(self,Search)
		if Users[tostring(Player.UserId)] then
			return Users[tostring(Player.UserId)][Search];
		else
			return nil;
		end;
	end;
	CustomFunctions.setdata = function(self,Index, Value)
		if Users[tostring(Player.UserId)] then
			Users[tostring(Player.UserId)][Index] = Value;
		end;
	end;
	CustomFunctions.getextradata = function(self,Search)
		if Users[tostring(Player.UserId)] then
			if Users[tostring(Player.UserId)]["ExtraData"] then
				return Users[tostring(Player.UserId)]["ExtraData"][Search]
			end;
		end;
		return nil;
	end;
	CustomFunctions.setextradata = function(self,Index, Value)
		if Users[tostring(Player.UserId)] then
			if Users[tostring(Player.UserId)]["ExtraData"] then
				local ExtraData = Users[tostring(Player.UserId)]["ExtraData"]
				ExtraData[Index] = Value;
			else
				local ExtraData = {};
				ExtraData[Index] = Value;
				Users[tostring(Player.UserId)]["ExtraData"] = ExtraData
			end;
		end;
	end;
	--Points
	CustomFunctions.getpoints = function(self)
		if Users[tostring(Player.UserId)] then
			if Users[tostring(Player.UserId)]["ExtraData"] then
				if Users[tostring(Player.UserId)]["ExtraData"]['Points'] then
					return Users[tostring(Player.UserId)]["ExtraData"]["Points"];
				end;
				return 0;
			end;
		end;
		return 0;
	end;
	--end points
	CustomFunctions.newtab = function(self, Text, Color, Function, LiveFunction, TabPosition, TabCFrame)
		local Style = self:GetExtraData("Style") or "Square";
		if Color == "Cyan" then
			Color = self:GetExtraData("Color") or "Cyan";
		end
		local Tab = Assets.Styles[Style]:Clone();
		Tab.Locked = true;
		Tab.Archivable = false;
		if not Text then Text = "NO TEXT SET"; end;
		Tab.BrickColor = BrickColor.new(Color)
		Tab.PointLight.Color = Tab.Color;
		if Tab.Name == "Alpha" then Tab.SelectionBox.Color3 = Tab.Color; end;
		Tab.BillboardGui.TextLabel.TextColor3 = Tab.Color;
		Tab.BillboardGui.TextLabel.Text = Text;
		
		if TabPosition then
			Cache.Tabs[Player][TabPosition] = Tab;
		else
			table.insert(Cache.Tabs[Player],Tab);
			TabPosition = #Cache.Tabs[Player];
		end;
		if TabCFrame then
			Tab.CFrame = TabCFrame;
			Tab.BodyPosition.Position = TabCFrame.p;
			Tab.BodyGyro.CFrame = TabCFrame;
		else
			local Pos,Frame = Player:FindRotPos();
			Tab.CFrame = Frame;
			Tab.BodyPosition.Position = Pos;
		end;
		
		Tab.Parent = workspace;
		Tab:SetNetworkOwner(RealPlayer);
		
		local Click = Instance.new("BindableFunction");
		ClickEvents[Tab] = Click;
		Click.OnInvoke = function()
			if Function then
				Player:Dismiss(Tab);
				pcall(function()
					Function();
				end);
			else
				Player:Dismiss(Tab);
			end;
		end;

		if LiveFunction then
			local TabEnv = {};
			TabEnv['Tab'] = Tab;
			TabEnv['ChangeText'] = function (NewText)
				pcall(function()
					if not Tab then return; end;
					Tab.BillboardGui.TextLabel.Text = NewText;
					Text = NewText;
				end);
			end;
			TabEnv['ChangeColor'] = function (NewColor)
				pcall(function()
				if not Tab then return; end;
					Tab.BrickColor = BrickColor.new(NewColor);
					--Tab.SelectionBox.Color3 = Tab.Color;
					Tab.PointLight.Color = Tab.Color;
					Tab.BillboardGui.TextLabel.TextColor3 = Tab.Color;
					Color = NewColor;
				end);
			end;
			
			setfenv(LiveFunction,setmetatable({},{
				__index = function (self, Index)
					if MainEnv[Index] then --//Default globals like wait()
						return MainEnv[Index];
					elseif TabEnv[Index] then --//Custom tab env
						return TabEnv[Index];
					elseif Core[Index] then
						return function(...)
            				return Core[Index](Core, ...); --//Translate Core methods to a function ;)
						end;
					elseif Player[Index] then
						return function(...)
							return Player[Index](Player,...); --//Translate Player methods to a function ;)
						end;
					end
				end
			}))
			
			spawn(function()LiveFunction()end)
		end
		
		spawn(function()
			while Tab do
				TabCFrame = Tab.CFrame;
				game:GetService('RunService').Stepped:wait();
			end;
		end);
		local Rem;Conn = nil,nil
		Rem = Tab.ChildRemoved:Connect(function(Child)
			if Tab.Name ~= "Removed" and pcall(function() return Player.Parent; end) then
				Conn:Disconnect();
				Rem:Disconnect();
				pcall(function()
					Tab:Destroy();
				end);
				Tab = nil;
				if not Player then return; end;
				if not Player.Parent then return; end;
				Player:NewTab(Text, Color, Function, LiveFunction, TabPosition, TabCFrame);
			end;
		end);
		Conn = Tab.AncestryChanged:Connect(function(Parent)
			if Parent ~= workspace and Tab.Name ~= "Removed" and pcall(function() return Player.Parent; end) then
				Conn:Disconnect();
				Rem:Disconnect();
				Tab = nil;
				if not Player then return; end;
				if not Player.Parent then return; end;
				Player:NewTab(Text, Color, Function, LiveFunction, TabPosition, TabCFrame);
				pcall(function()
					Tab:Destroy();
				end);
			end;
		end);
		
		spawn(function()Player:SendData({"AddTab",Tab,Cache.Tabs[Player]});end);
		if LiveFunction then return LiveFunction, Tab; else return Tab; end;
	end;
	CustomFunctions.senddata = function(self,Data)
		if not Cache.LoadConfirmations[Player] == true then
			repeat wait(); until Cache.LoadConfirmations[Player] == true;
		end
		for x,y in pairs(Data) do
			if type(y) == "string" then
				Data[x] = Encryption.Encrypt(y,Player.UserId)
			end
		end
		Remote:FireClient(Player.PlrObj,Data)
	end
	CustomFunctions.alpha = function(self)
		if Users then
			if Users[tostring(Player.UserId)] then
				if Users[tostring(Player.UserId)].Alpha then
					return tonumber(Users[tostring(Player.UserId)].Alpha) == 1;
				end;
			end;
		end;
		return false;
	end;
	CustomFunctions.rank = function(self)
		if Player.UserId == 13282741 or Player.UserId == 21467784 then return 7 end;
		if Users then
			if Users[tostring(Player.UserId)] then
				if Users[tostring(Player.UserId)].Rank then
					return tonumber(Users[tostring(Player.UserId)].Rank);
				end;
			end;
		end;
		return 0;
	end;
	CustomFunctions.id = function(self)
		if Users then
			if Users[tostring(Player.UserId)] then
				if Users[tostring(Player.UserId)].id then
					return tonumber(Users[tostring(Player.UserId)].id);
				end;
			end;
		end;
		return 0;
	end;
	CustomFunctions.prefix = function(self)
		if Users then
			if Users[tostring(Player.UserId)] then
				if Users[tostring(Player.UserId)].Prefix then
					return Users[tostring(Player.UserId)].Prefix
--				else
--					return ".";
				end
--			else
--				return ".";
			end
		end
		return ".";
	end;
	CustomFunctions.gotevent = function(self,Args)
		local Events = {
			["ShowMouse"] = function(Args)
				local Folder = workspace:FindFirstChild("Mouse") or Instance.new("Folder",workspace)
				Folder.Name = "Mouse"
				
				local Mouse = Folder:FindFirstChild(Player.Name) or Assets.Mouse:Clone()
				Mouse.Parent = Folder;Mouse.Name = Player.Name
				
				Mouse.BillboardGui.TextLabel.Text = Player.Name
				Mouse.CFrame = Args[2]
			end;
			["HideMouse"] = function(Args)
				local Folder = workspace:FindFirstChild("Mouse") or Instance.new("Folder",workspace)
				Folder.Name = "Mouse"
				
				if Folder:FindFirstChild(Player.Name) then
					Folder:FindFirstChild(Player.Name):Destroy()
				end
			end;
			['ActiveTab'] = function(Args)
				local ActiveTab = Args[2];
				ActiveTab.PointLight.Enabled = true;
				local Click = Assets.Click:Clone();
				Click.Parent = ActiveTab;
				Click:Play();
			end;
			['UnActiveTab'] = function(Args)
				local ActiveTab = Args[2];
				ActiveTab.PointLight.Enabled = false;
			end;
			['AFK'] = function(Args)
				Player:AFK(Args[2]);
			end;
			['Click'] = function(Args)
				if ClickEvents[Args[2]] then
					Player:AFK(false);
					ClickEvents[Args[2]]:Invoke();
				end;
			end;
			['Text'] = function(Args)
				Player:AFK(false);
				Player:RunCommand(Args[2]);
			end;
			['Loaded'] = function(Args)
				print("[PC] Connected "..Player.Name);
				Cache.LoadConfirmations[Player] = true;
				Player:SendData({"DataRecieve", Users[tostring(Player.UserId)],Users});
				if Player:Rank() ~= 0 then
					Player:TimedDismiss(Player:NewTab(Settings.AdminName.."\nOnline: "..#NewOnline,"Deep orange",function()
						Player:DismissAll();
					end),6);
--					local S = Instance.new("Sound",Player.PlayerGui);
--					S.SoundId = "rbxassetid://2163745307";
--					S.Volume = 1;
--					S:Play();
					Player:TimedDismiss(Player:NewTab("Data Loaded\nRank: "..Player:Rank().."\nPrefix: "..Player:Prefix(),"Lime green",function()
						Player:DismissAll();
					end),6);
					if Player:GetData("Verified") ~= "1" then
						Player:NewTab("Alert!\nClick to verify your discord.","Crimson",function()
							Player:DismissAll();
							Player:NewTab("Verification Help","Deep orange");
							Player:NewTab("1.\nJoin the discord. discord.gg/ywzYAje","Cyan");
							Player:NewTab("2.\nSay ;verify in the verify channel.","Cyan");
							Player:NewTab("3.\nRun the .verify command with the code you are given.","Cyan");
							Player:NewTab("Do not share this code with anyone.","Crimson");
						end);
					end;
					if Player:GetExtraData("JoinMessage") and #Player:GetExtraData("JoinMessage") > 0 then
						Player:NewTab("[" .. Settings.AdminName .. " System Message]\n" .. Player:GetExtraData("JoinMessage"), "Lime green", function() Player:SetExtraData("JoinMessage", ""); end);
					end;
				end;
			end;
		};
		if Events[Args[1]] then
			pcall(Events[Args[1]], Args);
		else
			Player:DismissAll();
			local Run,Returned = Player:NewTab("Someone is tampering with your Events.","Crimson",nil,function()
				while Tab.Parent do
					wait(.1);
					ChangeColor("Crimson");
					wait(.1);
					ChangeColor("Really red");
				end;
			end);
			--spawn(function()Run();end);
		end
	end
	CustomFunctions.dismisstab = function(self)
		Player:NewTab("Dismiss", "Persimmon", function()
			Player:DismissAll();
		end);
	end;
	CustomFunctions.loadcharacter = function()
		RealPlayer:LoadCharacter();
	end;
	CustomFunctions.runcommand = function(self, Message, LogOverride)
		if not Player.Parent then return; end;
		if LogOverride == nil then LogOverride = true end;
		if Message:sub(1,#Player:Prefix()) == Player:Prefix() or ((Player:Rank() > 5 or Player.alpha == '1' or Player:GetExtraData("AccessToCobraPrefix") == "1") and Message:sub(1, #("cobra, ")):lower() == "cobra, ") then
			Message = (Message:sub(1,#Player:Prefix()) == Player:Prefix() and Message:sub(#Player:Prefix() + 1) or Message:sub(#("cobra, ") + 1));
			for i,CurrentCommand in pairs(Core:Split(Message, "|")) do
				local Args = Core:Split(CurrentCommand, Settings.Suffix);
				local GivenCommand = Args[1]:lower();
				table.remove(Args,1) --//Remove Alias from Args
				local pAliases = Player:GetExtraData("Aliases") or {};
				for Alias, OrigCmd in pairs(pAliases) do
					if Alias..' ' == GivenCommand..' ' then
						GivenCommand = OrigCmd;
					end;
				end;
				for i,Command in pairs(Commands) do
					for i,Alias in pairs(Command.Use) do
						Alias = Alias:lower();
						if Alias..' ' == GivenCommand..' ' then
							if Player:Rank() >= Command.Rank then
								local Success,Error = pcall(function()
									Command.Function(Player, Args);
									if Command.Log == true and LogOverride == true then
										local Data = {}
										Data.UserId = Player.UserId;
										Data.Username = Player.Name;
										Data.Command = Alias;
										Data.Args = Core:Split(CurrentCommand, Settings.Suffix);
										table.remove(Data.Args, 1);
										Data.Args = table.concat(Data.Args, Settings.Suffix);
										table.insert(CommandLogs,Data);
									end
								end); 
								if not Success then
									local Title = Player:NewTab(Error, "Crimson");
									local S = Instance.new("Sound",Player.PlayerGui);
									S.SoundId = "rbxassetid://2163821790";
									S.Volume = 1;
									S:Play();
									Player:NewTab(Settings.Messages.Error.SEND_TO_DEV, "Crimson");
								end;
							else
								Player:NewTab(Settings.Messages.Error.INSUFFICIENT_RANK, "Crimson");
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	CustomFunctions.getplrs = function(self, Search)
		if not Search then
			return {self}
		end
		local Players = {};
		local Searches = Core:Split(Search, ',');
		for i,Search in pairs(Searches) do
			local Remove = false;
			if Search:sub(0, 1) == "~" then
				Remove = true;
				Search = Search:sub(2);
			end;
			if Search:lower() == "me" then
				if Remove then
					for i,P in pairs(Players) do
						if P.PlrObj == Player.PlrObj then
							table.remove(Players, i);
						end;
					end;
				else
					table.insert(Players, Player);
				end;
			elseif Search:lower() == "all" then
				for i,P in pairs(ActivePlayers) do
					table.insert(Players, P);
				end;
			elseif Search:lower() == "others" then
				for i,P in pairs(ActivePlayers) do
					if P.PlrObj ~= Player.PlrObj then
						table.insert(Players, P);
					end;
				end;
			else
				for i,P in pairs(ActivePlayers) do
					if Search:lower() == P.Name:lower():sub(1,#Search) then
						if Remove then
							for i,P2 in pairs(Players) do
								if P.PlrObj == P2.PlrObj then
									table.remove(Players, i);
								end;
							end;
						else
							table.insert(Players, P);
						end;
					end;
				end;
			end;
		end;
		return Players;
	end;
	CustomFunctions.kick = function(self,Data)
		Player.PlrObj:Kick(Data);
	end;
	CustomFunctions.plrobj = RealPlayer;
	
	--//To do: Add rawget() and rawset() to secure Env.
	Meta.__index = function(self,Index)
		if CustomFunctions[Index:lower()] then
			return CustomFunctions[Index:lower()]
		else
			if type(RealPlayer[Index]) == 'function' then --//Re-add default roblox  methods.
				return function (self,...)
					return RealPlayer[Index](RealPlayer,...);
				end;
			else
				return RealPlayer[Index];
			end;
		end;
	end;
	Meta.__newindex = function(s,i,v)
        Player[i] = v;
    end;
    Meta.__tostring = function()
    	return tostring(Player);
    end;
	Meta.__metatable = "This metatable is locked by "..Settings.AdminName;
	
	return Player;
end;
Core.Split = function(self,inputstr,sep)
	local t,i = {},1;
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str;
		i = i + 1;
	end;
	return t;
end;
Core.AddCmd = function(self, Name, Use, Description, Rank, Example, Function, Log)
	local Log = Log or true;--if not Log then Log = true; end; --//Enable command logging by default.
	table.insert(Commands, {Name = Name, Use = Use, Description = Description, Rank = Rank, Example = Example, Function = Function, Log = Log});
end;
Core.ConnectPlayer = function(self, Player)
	print("Connecting Player");
	--//Player Proxy
	local Player = Core:WrapPlayer(Player);
	table.insert(ActivePlayers,Player);
	
	--//Gaurentee Data
	local Exists = true;
	if not Users[tostring(Player.UserId)] then
		Users[tostring(Player.UserId)] = {Rank = 0; Prefix = "."; ExtraData = {};};
		Exists = false;
	end;
	Cache.Tabs[Player] = {};
	Cache[Player] = {};
	
	local LeftCon;LeftCon = game:GetService("Players").PlayerRemoving:connect(function(Left)
		if Left == Player.PlrObj then
			LeftCon:Disconnect();
			Cache.LoadConfirmations[Player] = nil;
			Cache[Player] = {};
			spawn(function()
				Player:DismissAll();
				Player:SetExtraData("LastSeen","Offline");
				Player:SetExtraData("LastServer","Offline");
				Player:SetExtraData("PlaceId","Offline");
				Player:SaveData();
			end);
			LeftCon = nil;
			for i,v in pairs(ActivePlayers) do
				if v == Player then
					table.remove(ActivePlayers,i);
				end;
			end;
		end;
	end);	
	
	local GiveClient;GiveClient = function()
		local Client = Assets.Client:Clone();
		Client.Parent = Player:FindFirstChildOfClass("PlayerGui");
		wait(5);
		if not Cache.LoadConfirmations[Player] then
			pcall(function() --//Prevent multiple clients from activating.
				Client.Disabled = true;
				Client:Destroy();
			end);
			GiveClient();
		end;
	end;
	GiveClient();

	if Player:Rank() == -1 then
		local Extra = Users[tostring(Player.UserId)]["ExtraData"];
		local BanTime = Core:FromFormattedTime(Extra.BanDays);
		local TimePassed = os.difftime(os.time(),Extra.BanTime);
		
		if TimePassed >= BanTime then
			Extra.PreviousBan = {["BannedBy"] = Extra.BannedBy;["BanDays"] = Extra.BanDays;["BanTime"] = Extra.BanTime;["BanReason"] = Extra.BanReason};
			Extra.BannedBy = nil;
			Extra.BanDays = nil;
			Extra.BanTime = nil;
			Extra.BanReason = nil;
			Users[tostring(Player.UserId)].Rank = 0;
			Player:SaveData(true);
			Player:NewTab("You have been un-banned.","Crimson");
			Player:NewTab("Say "..Player:Prefix().."checkrank to restore purchased ranks.","White");
			--BanHook("Green","Automatically un-banned [" .. Player.Name.."](https://www.roblox.com/users/"..Player.UserId.."/profile)\nTime: "..Extra.PreviousBan.BanDays.." days\nReason: "..Extra.PreviousBan.BanReason.."\nBanned by: "..Extra.PreviousBan.BannedBy,Player.UserId);
		else
			local Days,Hours,Minutes,Seconds = Core:ToFormattedTime(BanTime - TimePassed);
			Player:Kick("Project Cobra\nBanned by: "..Extra.BannedBy.."\nReason: "..Extra.BanReason.."\nTime left: "..Days.." days, "..Hours.." hours, "..Minutes.." minutes\nYou can appeal here -> discord.gg/ywzYAje");
			Core:SendToRank(4,"Banned Player\n"..Player.Name);
			return;
		end;
	end;
	
	Player:SetExtraData("Username",Player.Name);
	--//If theyve never used PC or been in a PC server (They are not in Database.)
--	if not Exists and not Settings.DataFailure then
--		local Title = Player:NewTab("Welcome to Project Cobra!\nI see this is your first time!","Deep orange",function()end)
--		local S = Instance.new("Sound",Player.PlayerGui)
--		S.SoundId = "rbxassetid://2163746548"
--		S.Volume = 1
--		S:Play()
--		Player:NewTab("Click me to get started!","Cyan",function()Player:RunCommand(Player:Prefix().."info")end)
--	end
	
	--//Rank Check
	spawn(function()
		if Settings.DataFailure then
			Player:NewTab("Data cannot save.\nNot connected to Database.","Persimmon",nil,function()
				while Tab.Parent do
					ChangeColor("Crimson");
					wait(.1);
					ChangeColor("Persimmon");
					wait(.1);
					ChangeColor("Really red");
					wait(.1);
				end;
			end);
		end;
		
		if Users[tostring(Player.UserId)]['GamepassOverride'] == '0' then
			if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(Player.UserId, 4423994) and Player:Rank() < 3 then --//Rank 2
				Player:SetData("Rank",3);
				Player:SetExtraData("RankChange-" .. os.time(), "Gamepass - 3");
				Player:SaveData();
				local Title = Player:NewTab("Rank 3 purchase detected!", "Lime green");
				local S = Instance.new("Sound",Player.PlayerGui)
				S.SoundId = "rbxassetid://2163823654"
				S.Volume = 1
				S:Play()
				Player:NewTab("You can check your rank with\n"..Player:Prefix().."checkrank", "Lime green");
				Web:sendData({['Method'] = "add"; ['User-Id'] = Player.UserId; ['Product-Id'] = 4423994; ['Purchase-Amount'] = 100; ['Note'] = "None";}, "purchase.php")
			elseif game:GetService("MarketplaceService"):UserOwnsGamePassAsync(Player.UserId, 4423993) and Player:Rank() < 2 then --//Rank 2
				Player:SetData("Rank",2);
				Player:SetExtraData("RankChange-" .. os.time(), "Gamepass - 2");
				Player:SaveData();
				local Title = Player:NewTab("Rank 2 purchase detected!", "Lime green");
				local S = Instance.new("Sound",Player.PlayerGui)
				S.SoundId = "rbxassetid://2163823654"
				S.Volume = 1
				S:Play()
				Player:NewTab("You can check your rank with\n"..Player:Prefix().."checkrank", "Lime green");
				Web:sendData({['Method'] = "add"; ['User-Id'] = Player.UserId; ['Product-Id'] = 4423993; ['Purchase-Amount'] = 40; ['Note'] = "None";}, "purchase.php")
			elseif game:GetService("MarketplaceService"):UserOwnsGamePassAsync(Player.UserId, 4423991) and Player:Rank() < 1 then --//Rank 1
				Player:SetData("Rank",1);
				Player:SetExtraData("RankChange-" .. os.time(), "Gamepass - 1");
				Player:SaveData();
				local Title = Player:NewTab("Rank 1 purchase detected!", "Lime green");
				local S = Instance.new("Sound",Player.PlayerGui)
				S.SoundId = "rbxassetid://2163823654"
				S.Volume = 1
				S:Play()
				Player:NewTab("You can check your rank with\n"..Player:Prefix().."checkrank", "Lime green");
			  Web:sendData({['Method'] = "add"; ['User-Id'] = Player.UserId; ['Product-Id'] = 4423991; ['Purchase-Amount'] = 20; ['Note'] = "None";}, "purchase.php")
			end
		end;
	end)
	
	--//Online and Recursive data updating.
	
	spawn(function()
		while LeftCon ~= nil do
			Player:SetExtraData("LastSeen",os.time());
			Player:SetExtraData("LastServer",game.JobId);
			Player:SetExtraData("PlaceId",game.PlaceId);
			Player:SaveData();
			Player:SendData({"DataRecieve",Users[tostring(Player.UserId)],Users});
			wait(15); --//Keep data updated globally (every 15 seconds)
		end;
	end);
	print("Connected Player");
	
	Player.Chatted:Connect(function(Chat)
		if BubbleChat[Player] then
			Chat = game:GetService("Chat"):FilterStringForBroadcast(Chat)
			for i,v in pairs(Player.Character.HumanoidRootPart:GetChildren()) do
				if v.className == "BillboardGui" and v.Name == "BubbleChat" then
					v.StudsOffset = v.StudsOffset + Vector3.new(0,-2.2,0)
				end
			end
			
			local Gui = Assets.BubbleChat:Clone()
			local Main = Gui:WaitForChild("ImageLabel")
			local Name = Main:WaitForChild("Name")
			local Content = Main:WaitForChild("Content")
			
			Gui.Parent = Player.Character.HumanoidRootPart
			Name.Text = Player.Name
			for i = 1,#Chat do
				Content.Text = Chat:sub(1,i).."|"
				wait()
			end
			Content.Text = Chat
			wait(3)
			for i = .1,1,.1 do
				Main.ImageTransparency = i
				Name.TextTransparency = i + .1
				Content.TextTransparency = i + .1
				wait()
			end
			Gui:Destroy()
		end
	end)
end;

--//Active Commands
--Rank 0
local cmdRank = 0;

Core:AddCmd("Ping", {"ping"}, "Pings a message.", cmdRank, "ping [Message]", function(Player, Args)
	Player:NewTab("Pong\n" .. game:GetService("Chat"):FilterStringForBroadcast(table.concat(Args,' '), Player.PlrObj), "White");
end);
Core:AddCmd("Timer", {"timer"}, "Starts a timer.", cmdRank, "timer [Seconds]", function(Player, Args)
	local Time = tonumber(Args[1]);
	if not Time then
		Player:NewTab("Invalid time.","Crimson");
		return;
	end;
	local Run,Returned = Player:NewTab("Timer: ","Lime green",nil,function()
		local Time = Time;
		while Tab.Parent and Time >= 1 do
			ChangeText("Timer: "..Time);
			Time = Time - 1;
			wait(1);
		end;
	end);
	--spawn(function()Run()end)
	wait(Time)
	Player:Dismiss(Returned)
	local Run2,Returned2 = Player:NewTab("Timer finished!","Lime green",nil,function()
		while Tab.Parent do
			ChangeColor("Lime green")
			wait(.2)
			ChangeColor("Crimson")
			wait(.2)
		end
	end)
	--Run2()
end);
Core:AddCmd("BuyRank", {"buyrank","getrank","rankme"}, "Purchase ranks here.", cmdRank, "buyrank", function(Player, Args)
	Player:DismissAll()
	Player:NewTab("Purchasable Ranks","Deep orange");
	Player:NewTab("Rank 1","Cyan",function()
		game:GetService("MarketplaceService"):PromptGamePassPurchase(Player.PlrObj,4423991)
		Player:DismissAll()
	end);
	Player:NewTab("Rank 2","Cyan",function()
		game:GetService("MarketplaceService"):PromptGamePassPurchase(Player.PlrObj,4423993)
		Player:DismissAll()
	end);
	Player:NewTab("Rank 3","Cyan",function()
		game:GetService("MarketplaceService"):PromptGamePassPurchase(Player.PlrObj,4423994)
		Player:DismissAll()
	end);
end);
Core:AddCmd("CheckRank", {"checkrank","checkr","rankcheck","updaterank"}, "Checks and updates your rank.", cmdRank, "checkrank", function(Player, Args)
	Player:DismissAll()
	Player:NewTab("Is rank "..Player:Rank().." correct?","Lime green");
	Player:NewTab("Yes","Lime green",function()
		Player:DismissAll()
	end);
	Player:NewTab("No","Persimmon",function()
		Player:DismissAll()
		Player:NewTab("Checking...","Lime green");
		if Player:Rank() < 0 then
			Player:NewTab("Your rank is locked.","Crimson"); --//Bans?
			return
		end
		if Users[tostring(Player.UserId)]['GamepassOverride'] == '0' then
			if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(Player.UserId, 4423994) and Player:Rank() < 3 then --//Rank 2
				Player:SetData("Rank",3);
				Player:SetExtraData("RankChange-" .. os.time(), "Gamepass - 3");
				Player:SaveData();
			elseif game:GetService("MarketplaceService"):UserOwnsGamePassAsync(Player.UserId, 4423993) and Player:Rank() < 2 then --//Rank 2
				Player:SetData("Rank",2);
				Player:SetExtraData("RankChange-" .. os.time(), "Gamepass - 2");
				Player:SaveData();
			elseif game:GetService("MarketplaceService"):UserOwnsGamePassAsync(Player.UserId, 4423991) and Player:Rank() < 1 then --//Rank 1
				Player:SetData("Rank",1);
				Player:SetExtraData("RankChange-" .. os.time(), "Gamepass - 1");
				Player:SaveData();
			end
		end
		Player:RunCommand(Player:Prefix().."checkrank")
	end);
end);
Core:AddCmd("OnlineUsers", {"onlineplayers","online","onlineusers"}, "View all online Cobra users.", cmdRank, "online", function(Player, Args)
	Player:DismissAll();
	local Onlinee = Player:NewTab("Online Users","Deep orange");
	for Index,Data in pairs(NewOnline) do
		local Username = Data.Username;
		local TimePassed = math.floor(os.time() - Data.Seen)
		local Rank = Data.Rank
		
		local StaffOption = "";
		if Data.Rank == 4 then
			 StaffOption = "\n[Moderator]";
		elseif Data.Rank ==  5 then
			StaffOption = "\n[Administrator]";
		elseif Data.Rank == 6 or Data.Rank == 7 then
			StaffOption = "\n[Creator]";
		else
			StaffOption = "\n["..Data.Rank.."]";
		end;
		Player:NewTab(Username.."\nSeen "..TimePassed.." seconds ago."..StaffOption,"Cyan",function()
			Player:DismissAll();
			Player:NewTab("Online Users\n"..Username,"Deep orange");
			Player:NewTab("Get user info.","Cyan",function()
				Player:DismissAll();
				Player:RunCommand(Player:Prefix().."ginfo "..Username,false);
			end);
			Player:NewTab("Teleport to server.","Cyan",function()
				Player:DismissAll();
				Player:NewTab(Settings.Messages.Status.TELEPORTING,"Lime green");
				game:GetService('TeleportService'):TeleportToPlaceInstance(Data.PlaceId, Data.JobId, Player.PlrObj);
			end);
			Player:NewTab("Back","Space grey",function()
				Player:RunCommand(Player:Prefix().."online");
			end);
			Player:DismissTab();
		end);
	end
end)
--Core:AddCmd("OnlineUsers", {"onlineplayers","online","onlineusers"}, "View all online Cobra users.", cmdRank, "online", function(Player, Args)
--	Player:DismissAll();
--	local Onlinee = Player:NewTab("Online Users","Deep orange");
--	Core:UpdateGlobalData();
--	local Current = 0;
--	spawn(function()
--		while wait() and Onlinee.Parent and Current < #Online do
--			pcall(function()
--				Onlinee.BillboardGui.TextLabel.Text = "Online Users\nLoading .. "..math.floor((Current/NumUsers)*100).."%";
--			end);
--		end;
--		Onlinee.BillboardGui.TextLabel.Text = "Online Users";
--	end);
--	for User,Data in pairs(Online) do
--		Current = Current + 1;
--		local Extra = Data.ExtraData;
--		local TimePassed = Extra.TimePassed;
--		local Username = Extra.Username;
--		if TimePassed <= 20 and TimePassed > 0 then
--			local StaffOption = "";
--			if Data.Rank == 4 then
--				 StaffOption = "\n[Moderator]";
--			elseif Data.Rank ==  5 then
--				StaffOption = "\n[Administrator]";
--			elseif Data.Rank == 6 then
--				StaffOption = "\n[Creator]";
--				if Username == "MrLonely1221" then StaffOption = "\n[RESTRICTED]"; end;
--			else
--				StaffOption = "\n["..Data.Rank.."]";
--			end;
--			Player:NewTab(Username.."\nSeen "..TimePassed.." seconds ago."..StaffOption,"Cyan",function()
--				Player:DismissAll();
--				Player:NewTab("Online Users\n"..Username,"Deep orange");
--				Player:NewTab("Get user info.","Cyan",function()
--					Player:DismissAll();
--					Player:RunCommand(".ginfo "..Username,false);
--				end);
--				Player:NewTab("Teleport to server.","Cyan",function()
--					Player:DismissAll();
--					Player:NewTab(Settings.Messages.Status.TELEPORTING,"Lime green");
--					game:GetService('TeleportService'):TeleportToPlaceInstance(Extra.PlaceId, Extra.LastServer, Player.PlrObj);
--				end);
--				Player:NewTab("Back","Space grey",function()
--					Player:RunCommand(".online");
--				end);
--				Player:DismissTab();
--			end);
--		end;
--	end;
--	Player:DismissTab();
--end);
Core:AddCmd("SbTags", {"sbtags"}, "Gets sb tags for a user.", cmdRank, "sbtags [User]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1])
	local UserId = 1
	local Name = "ROBLOX"
	if #Players > 1 then
		Player:NewTab(Settings.Messages.Error.GETINFO_TOO_MANY_USERS,"Crimson");
		return;
	elseif #Players == 1 then
		UserId = Players[1].UserId;
		Name = Players[1].Name;
	else
		UserId = game:GetService('Players'):GetUserIdFromNameAsync(Args[1]);
		Name = Args[1];
	end;
	if not Cache.Info[UserId] then
		local Tab = Player:NewTab(string.format(Settings.Messages.Status.LOADING_INFO, UserId),"Lime green");
		local S = Instance.new("Sound",Tab)
		S.SoundId = "rbxassetid://2163820828"
		S.Volume = 1
		S:Play()
		Cache.Info[UserId] = require(Modules.UserData)(UserId);
		Player:Dismiss(Tab);
	end;
	local SbTags = ""
	for x,y in pairs(Cache.Info[UserId].SBTags) do
		SbTags = SbTags .. y.tagText .. "\n"
	end
	if SbTags == "" then
		SbTags = "None"
	end
	Player:NewTab("Sb Tags for "..Name.."\n"..SbTags,"Cyan");
end)
Core:AddCmd("LastSeen", {"lastseen","seen"}, "Checks when the user was last seen.", cmdRank, "seen [User]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	local UserId = 1;
	local Name = "ROBLOX";
	if #Players > 1 then
		Player:NewTab("Found multiple users with given parameter.","Crimson");
		return;
	elseif #Players == 1 then
		UserId = Players[1].UserId;
		Name = Players[1].Name;
	else
		UserId = game:GetService('Players'):GetUserIdFromNameAsync(Args[1]);
		Name = Args[1];
	end;
	
	if Users[tostring(UserId)] then
		local Info = Users[tostring(UserId)];
		if Info.ExtraData then
			if Info.ExtraData.LastSeen then
				local SeenDate = GetDate(tonumber(Info.ExtraData.LastSeen)):format("#W #d, #Y at #H:#m #a")
				Player:NewTab(Name.."\nLast Seen\n"..SeenDate,"Cyan");
				return
			end
		end
	end
	Player:NewTab("Couldnt find user with provided parameter.","Crimson");
end)
Core:AddCmd("GetInfo", {"getinfo","ginfo"}, "Gets info for a user.", cmdRank, "getinfo [User]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	local UserId = 1;
	local Name = "ROBLOX";
	if #Players > 1 then
		Player:NewTab(Settings.Messages.Error.GETINFO_TOO_MANY_USERS,"Crimson");
		return;
	elseif #Players == 1 then
		UserId = Players[1].UserId;
		Name = Players[1].Name;
	else
		UserId = game:GetService('Players'):GetUserIdFromNameAsync(Args[1]);
		Name = Args[1];
	end;
	if not Cache.Info[UserId] then
		local Tab = Player:NewTab(string.format(Settings.Messages.Status.LOADING_INFO, UserId),"Lime green");
		local S = Instance.new("Sound",Tab);
		S.SoundId = "rbxassetid://2163820828";
		S.Volume = 1;
		S:Play();
		Cache.Info[UserId] = Modules.UserData(UserId);
		Player:Dismiss(Tab);
	end;
	Player:DismissAll();
	Player:NewTab("Info\n"..Name,"Deep orange");
	--//Player:NewTab("Points\n"..Players[1]:GetPoints(),"Cyan");
	for x,y in pairs(Cache.Info[UserId]) do
		if x ~= "About" and x ~= "SBTags" then
			Player:NewTab(x.."\n"..y,"Cyan");
		end;
	end;
	local SbTags = ""
	for x,y in pairs(Cache.Info[UserId].SBTags) do
		SbTags = SbTags .. y.tagText .. "\n"
	end
	if SbTags == "" then
		SbTags = "None"
	end
	Player:NewTab("Sb Tags\n"..SbTags,"Cyan");
	if Users[tostring(UserId)] then
		local Info = Users[tostring(UserId)];
		Player:NewTab("Rank\n"..Info.Rank,"Cyan");
		if Info.Verified == "1" then
			Player:NewTab("Discord Verified\nTrue","Cyan");
		else
			Player:NewTab("Discord Verified\nFalse","Cyan")
		end
		if Info.Alpha == "1" then
			Player:NewTab("Alpha Tester\nTrue","Cyan");
		else
			Player:NewTab("Alpha Tester\nFalse","Cyan");
		end;
		if Info.id then
			Player:NewTab("Project Cobra Id\n"..Info.id,"Cyan");
		else
			Player:NewTab("Project Cobra Id\nUnknown","Cyan");
		end
		if Info.ExtraData then
			if Info.ExtraData.LastSeen then
				local SeenDate = GetDate(tonumber(Info.ExtraData.LastSeen)):format("#W #d, #Y at #H:#m #a")
				Player:NewTab("Last Seen\n"..SeenDate,"Cyan");
			end
		end
	end;
	local Check = false
	for i,v in pairs(ActivePlayers) do
		if v.Name == Name then
			Check = true
			Player:NewTab("Voidacity Rank\n"..v:VsbRank(),"Cyan");
		end;
	end;
	if not Check then
		Player:NewTab("Voidacity Rank\nUnknown","Cyan");
	end
	Player:DismissTab();
end);
Core:AddCmd("Verify", {"verify"}, "Verifies your discord. [Must be in the discord.]", cmdRank, "verify [Given Code]", function(Player, Args)
	if Player:GetData("Verified") == "1" then
		Player:NewTab(Settings.Messages.Error.ALREADY_VERIFIED,"Crimson");
		return;
	end;
	if not Args[1] then
		Player:NewTab(Settings.Messages.Error.INVALID_CODE,"Crimson");
		return;
	end;
	local Data = Web:sendData({['Method'] = "update"; ['User-Id'] = Player.UserId; ['Token'] = Args[1];}, "verify.php");
	if Data then
		if Data['status'] == "Success" then
			Core:UpdateGlobalData()
			Player:NewTab(Settings.Messages.Success.VERIFY,"Lime green");
		else
			--Player:NewTab(Settings.Messages.Error.INVALID_CODE,"Crimson");
			Player:NewTab("Verify Debug System\nSend a screenshot to a developer.","Deep orange");
			Player:NewTab(Data['status'],"Crimson");
			Player:NewTab(Data['data'],"Crimson");
		end;
	else
		Player:NewTab(Settings.Messages.Error.VERIFY_WEB_ERROR,"Crimson");
	end;
end);
Core:AddCmd("AdminInfo", {"admininfo","info"}, "Show admin information.", cmdRank, "info", function(Player, Args)
	Player:DismissAll();
	local Title = Player:NewTab("Project Cobra Information","Deep orange");
	local S = Instance.new("Sound",Player.PlayerGui)
	S.SoundId = "rbxassetid://2163745784"
	S.Volume = 1
	S:Play()
	Player:NewTab("Website and Bot created by MrLonely1221.","Cyan");
	Player:NewTab("Roblox system created by WaverlyCole.","Cyan");
	Player:NewTab("Discord:\nywzYAje","Dark Royal blue");
	Player:NewTab("Say "..Player:Prefix().."cmds to view commands!","Cyan");
	Player:NewTab("Say "..Player:Prefix().."help to request help from online staff!","Cyan");
	Player:DismissTab();
end,false);
Core:AddCmd("MultiPing", {"mping","multiping"}, "Pings a message multiple times.", cmdRank, "mping [Times] [Message]", function(Player, Args)
	Player:DismissAll();
	local Times = tonumber(Args[1]);
	table.remove(Args,1);
	if Times then
		local MaxTimes = Player:Rank() * 5;
		if MaxTimes < 5 then MaxTimes = 5; end;
		if Times > MaxTimes then
			Player:NewTab(string.format(Settings.Messages.Error.MAX_TIMES, MaxTimes), "Crimson");
			Times = MaxTimes;
		end;
		for i = 1,Times do
			Player:NewTab(game:GetService("Chat"):FilterStringForBroadcast(table.concat(Args,' '), Player.PlrObj),"White");
		end;
	else
		Player:NewTab(Settings.Messages.Error.INVALID_INPUT,"Crimson");
	end;
end);
Core:AddCmd("DismissTabs", {"dismisstabs",'dismiss','dt'}, "Dismiss your tabs.", cmdRank, "dt", function(Player, Args)
	Player:DismissAll();
end,false);
Core:AddCmd("ViewUsers", {"viewusers",'ranked','users'}, "Shows all users.", cmdRank, "ranked [Optional:Rank]", function(Player, Args)
	Player:DismissAll();
	local ViewRanked;ViewRanked = function(Rank,Page)
		Player:DismissAll();
		local Display = ""
		if Rank == 4 then
			Display = "[Moderator]"
		elseif Rank == 5 then
			Display = "[Administrator]"
		elseif Rank == 6 or Rank == 7 then
			Display = "[Creator]"
		else
			Display = "Rank: "..Rank
		end
		local InitUsers = {}
		for User,Data in pairs(Users) do
			if Data.Rank == Rank then
				Data.UserId = User
				table.insert(InitUsers,Data)
			end
		end
		Player:NewTab("Users\n" .. Display.."\n("..#InitUsers..")\n ", "Deep orange");
		if not Page then Page = 1 end
		local SelectedUsers = {}
		local Start = 1
		if Page > 1 then Start = (Page * 10) - 9 end
		local End = Start + 9
		local HasNextPage = true
		for i = Start,End do
			if InitUsers[i] then
				SelectedUsers[i] = InitUsers[i]
			else
				HasNextPage = false
			end
		end
		for i,Data in pairs(SelectedUsers) do
			local Username = Data.ExtraData.Username
			if not Username then
				Username = game:GetService("Players"):GetNameFromUserIdAsync(tonumber(Data.UserId))
			end
			Player:NewTab(Username,"Cyan",function()
				Player:RunCommand(Player:Prefix().."ginfo "..Username,false)
			end)
		end
		if HasNextPage then
			Player:NewTab("Next Page", "Bright orange",function()
				Player:DismissAll()
				ViewRanked(Rank,Page+1)
			end);
		end
		Player:NewTab('Page:\n'..Page..[[/]].. math.ceil(#InitUsers/10), "Bright orange");
		if Page > 1 then
			Player:NewTab("Previous Page", "Bright orange",function()
				Player:DismissAll()
				ViewRanked(Rank,Page-1)
			end);
		end
		Player:NewTab("Back", "Space grey", function()
			Player:RunCommand(Player:Prefix() .. "ranked",false);
		end);
		Player:DismissTab();
	end
	if tonumber(Args[1]) then
		ViewRanked(tonumber(Args[1]));
	else
		Player:NewTab("Users\n("..NumUsers..")\n ", "Deep orange");
		for Rank = 0,6 do
			local Display = ""
			if Rank == 4 then
				Display = "Moderators"
			elseif Rank == 5 then
				Display = "Administrators"
			elseif Rank == 6 or Rank == 7 then
				Display = "Creators"
			else
				Display = "Rank "..Rank
			end
			Player:NewTab(Display, "Cyan", function()
				ViewRanked(tonumber(Rank));
			end);
		end;
		Player:DismissTab();
	end
end)
Core:AddCmd("ViewCommands", {"viewcommands",'commands','cmds'}, "Shows commands.", cmdRank, "cmds [Optional:Rank]", function(Player, Args)
	Player:DismissAll();
	local CommandsForRank;CommandsForRank = function(Rank,Page)
		Player:DismissAll();
		Player:NewTab("Commands\nRank: " .. Rank, "Deep orange");
		local InitRankedCmds = {}
		for Index,Cmd in pairs(Commands) do
			if Cmd.Rank == Rank then
				table.insert(InitRankedCmds,Cmd);
			end;
		end;
		if not Page then Page = 1; end;
		local RankedCmds = {};
		local Start = 1;
		if Page > 1 then Start = (Page * 10) - 9; end;
		local End = Start + 9;
		local HasNextPage = true;
		for i = Start,End do
			if InitRankedCmds[i] then
				RankedCmds[i] = InitRankedCmds[i];
			else
				HasNextPage = false;
			end;
		end;
		for i,Command in pairs(RankedCmds) do
			if Command.Rank == Rank then
				Player:NewTab(Command.Name, "Cyan", function()
					Player:DismissAll();
					Player:NewTab(Command.Name, "Deep orange");
					Player:NewTab("Description:\n"..Command.Description, "Cyan");
					Player:NewTab("Uses:\n"..table.concat(Command.Use,','), "Cyan");
					Player:NewTab("Example:\n"..Command.Example, "Cyan");
					Player:NewTab("Rank:\n"..Command.Rank, "Cyan");
					Player:NewTab(Player:Rank() >= Rank and Settings.Messages.Success.SUFFICIENT_RANK or Settings.Messages.Error.INSUFFICIENT_RANK, Player:Rank() >= Rank and "Lime green" or "Crimson");
					Player:NewTab("Back", "Space grey", function()
						CommandsForRank(Rank);
					end);
					Player:DismissTab();
				end);
			end;
		end;
		if HasNextPage then
			Player:NewTab("Next Page", "Bright orange",function()
				Player:DismissAll();
				CommandsForRank(Rank,Page+1);
			end);
		end;
		Player:NewTab('Page:\n'..Page..[[/]].. math.ceil(#InitRankedCmds/10), "Bright orange");
		if Page > 1 then
			Player:NewTab("Previous Page", "Bright orange",function()
				Player:DismissAll();
				CommandsForRank(Rank,Page-1);
			end);
		end;
		Player:NewTab("Back", "Space grey", function()
			Player:RunCommand(Player:Prefix() .. "cmds",false);
		end);
		Player:DismissTab();
	end;
	if tonumber(Args[1]) then
		if tonumber(Args[1]) > 5 then
			return Player:NewTab("Invalid Rank","Crimson");
		end;
		CommandsForRank(tonumber(Args[1]));
	else
		Player:NewTab("Commands", "Deep orange");
		for Rank = 0,5 do
			Player:NewTab("Rank:\n"..Rank, "Cyan", function()
				CommandsForRank(Rank);
			end);
		end;
		Player:NewTab("Your rank:\n"..Player:Rank(),"Lime green");
		Player:DismissTab();
	end;
end,false);
Core:AddCmd("RequestHelp", {"requesthelp","help"}, "Request help from an online staff member.", cmdRank, "help [Reason]", function(Player, Args)
	if game.VIPServerId ~= "" then
		Player:NewTab(Settings.Messages.Error.CANNOT_REQUEST_HELP_PS,"Crimson")
		return
	end
	local Reason = table.concat(Args,' ')
	if Reason == "" or Reason == " " then
		Player:NewTab("Please provide a reason.","Crimson")
		return
	end
	Player:DismissAll()
	local Checking = Player:NewTab(Settings.Messages.Status.CHECKING_ONLINE_STAFF,"Lime green")
	local StaffOnline = false
	local CurrentlyOnline = {}
	for i,PlrData in pairs(NewOnline) do
		if PlrData.Rank >= 4 then
			StaffOnline = true
			table.insert(CurrentlyOnline,PlrData.Username)
		end
	end
	Player:Dismiss(Checking)
	if StaffOnline then
		Player:NewTab("Online Staff\n"..table.concat(CurrentlyOnline,"\n"),"Lime green")
		local helpData = {}
		helpData.JobId = game.JobId;
		helpData.PlaceId = game.PlaceId;
		helpData.RequestedBy = Player.Name
		helpData.Reason = Reason
		game:GetService("MessagingService"):PublishAsync("PCHelpSystem", Web:Encode(helpData))
		Player:NewTab("Request Sent","Lime green")
	else
		Player:NewTab(Settings.Messages.Error.NO_STAFF_ONLINE,"Crimson")
	end
end);


--Rank 1
cmdRank = 1;

Core:AddCmd("Sticky", {'sticky'}, "Makes a player sticky", cmdRank, "sticky [Player]" ,function(Player,Args)
	local Players = Player:GetPlrs(Args[1])
	
	local function weldBetween(a, b)
   		local weld = Instance.new("ManualWeld")
    	weld.Part0 = a
    	weld.Part1 = b
    	weld.C0 = CFrame.new()
    	weld.C1 = b.CFrame:inverse() * a.CFrame
    	weld.Parent = a
    	return weld;
	end
	for i,v in pairs(Players) do
		pcall(function()
			local Char = v.Character
			for i,v in pairs(Char:GetChildren()) do
				if v:IsA('BasePart') then
					v.Touched:connect(function(part)
						if not part:IsDescendantOf(Char) and part.Anchored == false then
							weldBetween(v,part)
						end
					end)
				end
			end
		end)
	end
end)
Core:AddCmd("Rope", {'rope','leash'}, "Attaches player to a rope.", cmdRank, "rope [Player]",function(Player,Args)
	local Players = Player:GetPlrs(Args[1])
	for i,v in pairs(Players) do
		pcall(function()
			local P2 = v.Character
			local Posss = v.Character.HumanoidRootPart.CFrame
	
			local P = Instance.new('Part',P2)
			P.Anchored = true
			P.CanCollide = false
			P.Size = Vector3.new(.2,.2,.2)
			P.CFrame = Posss
			P.BrickColor = BrickColor.new('Persimmon')
			P.Transparency = 0
			local S = Instance.new('Part',P)
			S.Anchored = true
			S.CanCollide = false
			S.Size = Vector3.new(.4,3,.4)
			S.BrickColor = BrickColor.new('Black')
			S.CFrame = P.CFrame * CFrame.new(0,-1.5,0)
			S.Transparency = 0
			local Rope = Instance.new('RopeConstraint',P)
			local AT1 = Instance.new('Attachment',P)
			local AT2 = Instance.new('Attachment',P2.Head)
	
			Rope.Attachment0 = AT1
			Rope.Attachment1 = AT2
			Rope.Length = 15
			Rope.Visible = true
			Rope.Color = BrickColor.new('Persimmon')
		end)
	end
end)
Core:AddCmd("Tie", {'tie','bond'}, "Ties 2 playes together.", cmdRank, "tie [Plr] [Plr]",function(Player,Args)
	local Players1 = Player:GetPlrs(Args[1])
	table.remove(Args,1)
	local Players2 = Player:GetPlrs(Args[1])
	for i,v in pairs(Players1) do
		pcall(function()
			for x,y in pairs(Players2) do
				local AT1 = Instance.new('Attachment',v.Character.Head)
				local AT2 = Instance.new('Attachment',y.Character.Head)
				local Rope = Instance.new('RopeConstraint',v.Character.Head)
				
				Rope.Attachment0 = AT1
				Rope.Attachment1 = AT2
				Rope.Length = 15
				Rope.Visible = true
				Rope.Color = BrickColor.new('Persimmon')
			end
		end)
	end
end)
Core:AddCmd("AFK", {"afk"}, "Sets you as AFK.", cmdRank, "afk", function(Player, Args)
	Player:AFK(true)
end);
Core:AddCmd("Clone", {'clone'}, "Clones a player.", cmdRank, "clone [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]) or {Player};
	if #Players >= 1 then
		for i,v in pairs(Players) do
			pcall(function()
				v.Character.Archivable = true;
				v.Character:Clone().Parent=workspace;
				v.Character.Archivable = false;
			end);
		end;
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Switch", {'switch'}, "Switch places with a player.", cmdRank, "switch [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			pcall(function()
				local mepos = Player.Character.HumanoidRootPart.CFrame
				local thempos = v.Character.HumanoidRootPart.CFrame
				Player.Character.HumanoidRootPart.CFrame = thempos
				v.Character.HumanoidRootPart.CFrame = mepos
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end)
Core:AddCmd("Players", {'players','plrs'}, "View all players in the current server.", cmdRank, "players", function(Player, Args)
	Player:SendData({"GiveGui", "Players"});
end);
Core:AddCmd("SetPrefix", {"setprefix"}, "Sets a custom prefix.", cmdRank, "setprefix [Prefix]", function(Player, Args)
	local Prefix = Args[1]
	if #Args[1] <= 1 then
		local Progress = Player:NewTab("Setting prefix...","Lime green");
		Player:SetData("Prefix",Prefix);
		Player:SaveData();
		Player:Dismiss(Progress);
		local Title = Player:NewTab("Prefix set!","Lime green");
		local S = Instance.new("Sound",Player.PlayerGui)
		S.SoundId = "rbxassetid://2163821361"
		S.Volume = 1
		S:Play()
	else
		Player:NewTab(Settings.Messages.Error.PREFIX_TOO_LONG,"Crimson");
	end;
end);
Core:AddCmd("TeleportTo", {"teleportto","tpto","to"}, "Teleports you to a player.", cmdRank, "tpto [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		local Succ,Err = pcall(function()
			Player.Character.HumanoidRootPart.CFrame = Players[1].Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(180),0) * CFrame.new(0,0,5)
		end)
		if not succ then
			Player:NewTab(Settings.Messages.Error.NO_HUMANOID,"Crimson");
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Jump", {"jump"}, "Makes a player jump.", cmdRank, "jump [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				v.Character.Humanoid.Jump = true
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Sit", {"Sit"}, "Makes a player sit.", cmdRank, "sit [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				v.Character.Humanoid.Sit = true
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Heal", {"heal"}, "Heals a player.", cmdRank, "heal [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				v.Character.Humanoid.Health = v.Character.Humanoid.MaxHealth
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("WalkSpeed", {"walkspeed","ws"}, "Sets a players walkspeed.", cmdRank, "ws [Player] [Number]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	local Speed = tonumber(Args[2])
	if not Speed then
		Player:NewTab("Invalid speed.","Crimson");
		return
	end
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				v.Character.Humanoid.WalkSpeed = Speed
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("JumpPower", {"jumppower","jp"}, "Sets a players jumppower.", cmdRank, "jp [Player] [Number]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	local Speed = tonumber(Args[2])
	if not Speed then
		Player:NewTab("Invalid power.","Crimson");
		return
	end
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				v.Character.Humanoid.JumpPower = Speed
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Invisible", {"invisible",'invis'}, "Makes a player invisible.", cmdRank, "invisible [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args, 1);
	local Color = table.concat(Args,' ');
	if #Players >= 1 then
		for i,v in pairs(Players) do
			--local Succ,Err = pcall(function()
				for x,y in pairs(v.Character:GetDescendants()) do
					if y:IsA"BasePart" and y.Name ~= "HumanoidRootPart" then
						spawn(function()
							for i = 0,1,.1 do
								y.Transparency = i;
								wait();
							end;
						end);
					elseif y.Name == "face" then
						Cache[Player].Face = y:Clone();
						y:Destroy();
					end;
				end;
			--end);
		end;
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end;
end);
Core:AddCmd("Visible", {"Visible",'vis'}, "Makes a player visible.", cmdRank, "visible [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1)
	local Color = table.concat(Args,' ')
	if #Players >= 1 then
		for i,v in pairs(Players) do
			--local Succ,Err = pcall(function()
				for x,y in pairs(v.Character:GetDescendants()) do
					if y:IsA"BasePart" and y.Name ~= "HumanoidRootPart" then
						spawn(function()
							for i = 1,0,-.1 do
								y.Transparency = i
								wait()
							end
						end)
					end
					if Cache[Player].Face then
						Cache[Player].Face:Clone().Parent = v.Character.Head
					end
				end
			--end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("CheckRank", {"checkrank","crank"}, "Gets a players rank..", cmdRank, "grank [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1)
	local Color = table.concat(Args,' ')
	if #Players >= 1 then
		for i,v in pairs(Players) do
			Player:NewTab(v.Name.."\nRank "..v:Rank(),"Cyan")
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Sparkles", {"sparkles"}, "Gives a player sparkles.", cmdRank, "sparkles [Player] [Color]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1)
	local Color = table.concat(Args,' ')
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				local Effect = Instance.new("Sparkles")
				Effect.SparkleColor = BrickColor.new(Color).Color
				Effect.Parent = v.Character.HumanoidRootPart
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("UnSparkles", {"unsparkles"}, "Removes a player sparkles.", cmdRank, "unsparkles [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				for x,y in pairs(Player.Character:GetDescendants()) do
					if y.ClassName == "Sparkles" then
						y:Destroy()
					end
				end
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("UnSmoke", {"unsmoke"}, "Removes a player smoke.", cmdRank, "unsmoke [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				for x,y in pairs(Player.Character:GetDescendants()) do
					if y.ClassName == "Smoke" then
						y:Destroy()
					end
				end
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("UnFire", {"unfire"}, "Removes a player fire.", cmdRank, "unfire [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				for x,y in pairs(Player.Character:GetDescendants()) do
					if y.ClassName == "Fire" then
						y:Destroy()
					end
				end
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("UnLight", {"unlight"}, "Removes a player light.", cmdRank, "unlight [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				for x,y in pairs(Player.Character:GetDescendants()) do
					if y.ClassName == "PointLight" then
						y:Destroy()
					end
				end
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("AntiGlobalSounds", {"antiglobalsounds","globalsounds","gsounds"}, "Prevents sounds from being global.", cmdRank, "gsounds", function(Player, Args)
	Settings.AntiGlobalSounds = not Settings.AntiGlobalSounds;
	if Settings.AntiGlobalSounds then
		Player:NewTab("AntiGlobalSounds\nOn","Lime green");
	else
		Player:NewTab("AntiGlobalSounds\nOff","White");
	end
end);
Core:AddCmd("Fire", {"Fire"}, "Gives a player a fire.", cmdRank, "fire [Player] [Color]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1)
	local Color = table.concat(Args,' ')
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				local Effect = Instance.new("Fire")
				Effect.Color = BrickColor.new(Color).Color
				Effect.Parent = v.Character.HumanoidRootPart
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Density", {"density"}, "Changes a players density.", cmdRank, "density [Player] [Number]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1)
	local Number = tonumber(Args[1])
	if not Number then
		Player:NewTab("Invalid density.","Crimson");
		return
	end
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				for x,y in pairs(v.Character:GetDescendants()) do
					if y:IsA"BasePart" then
						local oldProp = PhysicalProperties.new(y.Material)
						local newphys = PhysicalProperties.new(Number,oldProp.Friction,oldProp.Elasticity)
						y.CustomPhysicalProperties = newphys
					end
				end 
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Light", {"Light"}, "Gives a player a light.", cmdRank, "light [Player] [Color]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1)
	local Color = table.concat(Args,' ')
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				local Effect = Instance.new("PointLight")
				Effect.Color = BrickColor.new(Color).Color
				Effect.Brightness = 5
				Effect.Range = 10
				Effect.Parent = v.Character.HumanoidRootPart
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Smoke", {"smoke"}, "Gives a player smoke.", cmdRank, "smoke [Player] [Color]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1)
	local Color = table.concat(Args,' ')
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				local Effect = Instance.new("Smoke")
				Effect.Color = BrickColor.new(Color).Color
				Effect.Parent = v.Character.HumanoidRootPart
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Refresh", {'refresh','ref','re'}, "Refresh a player.", cmdRank, "refresh [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	for i,v in pairs(Players) do
		if v.Character then
			local pos = v.Character:findFirstChild'HumanoidRootPart' or v.Character:findFirstChild'Torso' or v.Character:findFirstChild'Head' or Instance.new("Part");
			local position = pos.CFrame;
			v:LoadCharacter();
			v.Character.HumanoidRootPart.CFrame = position;
		else
			v:LoadCharacter();
		end;
	end;
end);
Core:AddCmd("Flip", {"flip"}, "Flips a player.", cmdRank, "flip [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				v.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,math.rad(180))
			end);
			if not succ then
				Player:NewTab(Settings.Messages.Error.NO_HUMANOID,"Crimson");
			end;
		end;
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end;
end);
Core:AddCmd("TeleportHere", {"teleporthere","tphere","bring"}, "Teleports a player to you.", cmdRank, "bring [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				v.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(180),0) * CFrame.new((-#Players/2 * 4) + (4*i-2),0,5);
			end);
			if not succ then
				Player:NewTab(Settings.Messages.Error.NO_HUMANOID,"Crimson");
			end;
		end;
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end;
end);
Core:AddCmd("Points", {'browniepoints','brownies','points','pts'}, "Check your points (Essentially brownie points for helping staff)", cmdRank, "points", function(Player, Args)
	Player:NewTab(string.format("Your points\n%d Points", Player:GetPoints()), "Cyan");
end);
Core:AddCmd("Aliases", {'listaliases','aliaslist','aliases','alist','al'}, "Lists your currently set aliases.", cmdRank, "aliases", function(Player, Args)
	local CurrAliases = Player:GetExtraData("Aliases")
	if CurrAliases == nil then
		Player:TimedDismiss(Player:NewTab(Settings.Messages.Error.NO_ALIASES, "Crimson"));
		return
	end
	Player:DismissAll();
	--if #CurrAliases == 0 then return Player:TimedDismiss(Player:NewTab(Settings.Messages.Error.NO_ALIASES, "Crimson")); end;
	Player:NewTab("Aliases", "Deep orange");
	for A, O in pairs(CurrAliases) do
		Player:NewTab(string.format("Alias: %s\nCommand: %s", A, O), "Cyan");
	end;
	Player:DismissTab();
end);
Core:AddCmd("Alias", {'alias','a'}, "Add aliases for commands.", cmdRank, "alias [Your Alias] [Original Command]", function(Player, Args)
	local Alias = string.lower(Args[1]); table.remove(Args, 1);
	local Orig = string.lower(Args[1]); table.remove(Args, 1);
	Player:DismissAll();
	if Settings.BlockedAliasCommands[Orig] and Player:Rank() < 4 then return Player:NewTab(string.format(Settings.Messages.Error.RESTRICTED_FROM_ALIAS, Orig), "Crimson"); end;
	local CurrAliases = Player:GetExtraData("Aliases") or {};
	local Exists = false;
	for A, O in pairs(CurrAliases) do --//Never runs cause {} is empty
		if string.lower(A) == Alias then Exists = true;return Player:NewTab("Error: Alias \"" .. A .. "\" already set to " .. O, "Crimson"); end;
	end;
	if not Exists then
		CurrAliases[Alias] = Orig;
		Player:SetExtraData("Aliases", CurrAliases)
		local S = Instance.new("Sound",Player.PlayerGui);
		S.SoundId = "rbxassetid://2163821361";
		S.Volume = 1;
		S:Play();
		Player:NewTab(string.format("Alias \"%s\" set to \"%s\"", Alias, Orig), "Lime green");
	end
	--local teb = Player:NewTab("Alias set!", "Lime green");
	--Player:TimedDismiss(teb);
end);
Core:AddCmd("RemoveAlias", {'removealias','removea','ralias','ra'}, "Remove aliases for commands.", cmdRank, "ralias [Alias]", function(Player, Args)
	local Alias = string.lower(Args[1]); table.remove(Args, 1);
	local CurrAliases = Player:GetExtraData("Aliases")
	Player:DismissAll();
	if CurrAliases == {} then return Player:TimedDismiss(Player:NewTab(Settings.Messages.Error.NO_ALIASES, "Crimson")); end;
	local Found = false;
	for A, O in pairs(CurrAliases) do
		if string.lower(A) == Alias then Found = true; end;
	end;
	if Found then
		CurrAliases[Alias] = nil;
		Player:SetExtraData("Aliases", CurrAliases);
		local S = Instance.new("Sound",Player.PlayerGui);
		S.SoundId = "rbxassetid://2163821361";
		S.Volume = 1;
		S:Play();
		Player:NewTab(string.format("Alias \"%s\" removed!", Alias), "Lime green");
	else
		Player:NewTab(string.format("Alias \"%s\" not found!", Alias), "Crimson");
	end;
end);

--Rank 2
cmdRank = 2;

Core:AddCmd("SetStyle",{"setstyle","style"}, "Sets the tab shape.", cmdRank, "setstyle", function(Player,Args)
	local OriginalStyle = Player:GetExtraData("Style");
	Player:DismissAll();
	Player:NewTab("Style Select","Deep orange");
	for i,v in pairs(Assets.Styles:GetChildren()) do
		if v.Name == "Alpha" and Player:Alpha() == false then
			--rip?
		else
			Player:SetExtraData("Style",v.Name);
			Player:NewTab(v.Name,"Cyan",function()
				Player:DismissAll();
				Player:SetExtraData("Style",v.Name);
				local Title = Player:NewTab("Style set!","Lime green");
				local S = Instance.new("Sound",Player.PlayerGui);
				S.SoundId = "rbxassetid://2163821361";
				S.Volume = 1;
				S:Play();
			end);
		end
	end;
	Player:SetExtraData("Style",OriginalStyle);
end);
Core:AddCmd("SetColor",{"setcolor","color"}, "Sets the tab color.", cmdRank, "setcolor [Optional BrickColor]", function(Player,Args)
	if not Args[1] then Args[1] = "" end;
	Args[1] = table.concat(Args,' ')
	if tostring(BrickColor.new(Args[1])) ~= "Medium stone grey" then
		Player:SetExtraData("Color",Args[1])
		local Title = Player:NewTab("Color set!","Lime green");
		local S = Instance.new("Sound",Player.PlayerGui)
		S.SoundId = "rbxassetid://2163821361"
		S.Volume = 1
		S:Play()
	else
		Player:DismissAll()
		Player:NewTab("Select Color","Deep orange");
		local Run2,Returned2;Run2,Returned2 = Player:NewTab("Color","Lime green",function()
			Player:DismissAll()
			Player:SetExtraData("Color",tostring(Returned2.BrickColor))
			local Title = Player:NewTab("Color set!","Lime green");
			local S = Instance.new("Sound",Player.PlayerGui)
			S.SoundId = "rbxassetid://2163821361"
			S.Volume = 1
			S:Play()
		end, function()
			local rainbow = {};
			local currcol = 1;
			for i = 0,1,1/100 do
				local color = Color3.fromHSV(i,1,1);
				table.insert(rainbow,color);
			end;
			while Tab.Parent do
				local color;
				currcol = currcol +1;
				if rainbow[currcol] then
					color = rainbow[currcol];
				else
					currcol = 1;
					color = rainbow[1];
				end;
				Tab.Color = color;
				Tab.BillboardGui.TextLabel.TextColor3 = color;
				Tab.BillboardGui.TextLabel.Text = tostring(Tab.BrickColor);
				wait(.2);
			end;
		end);
		Run2();
	end;
end);
Core:AddCmd("Dummy", {"dummy"}, "Makes a dummy clone of a player.", cmdRank, "dummy [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1)
	if #Players < 1 then
		Players = {Player}
	end
	for i,v in pairs(Players) do
		local Succ,Err = pcall(function()
			v.Character.Archivable = true
			local Char = v.Character:Clone()
			v.Character.Archivable = false
			for x,y in pairs(Char:GetChildren()) do
				if y:IsA("Script") then
					y:Destroy()
				end
			end
			for x,y in pairs(Assets.Dummy:GetChildren()) do
				local Part = y:Clone()
				Part.Parent = Char
				Part.Disabled = false
			end
			Char.HumanoidRootPart:Destroy()
			Char.Parent = workspace
			Char.Torso.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(180),0) * CFrame.new(0,0,5)
		end)
	end
end);
Core:AddCmd("Kill", {"kill","rip","murder"}, "Kills a player.", cmdRank, "rip [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				v.Character:BreakJoints()
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Damage", {"damage","hurt"}, "Makes a player take damage.", cmdRank, "damage [Player] [Number]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	local Speed = tonumber(Args[2])
	if not Speed then
		Player:NewTab("Invalid damage.","Crimson");
		return
	end
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				v.Character.Humanoid.Health = v.Character.Humanoid.Health - Speed
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Rocket", {'rocket'}, "Rockets a player.", cmdRank, "rocket [Player]",function(Player,Args)
	local Players = Player:GetPlrs(Args[1]);
	local function weldBetween(a, b)
   		local weld = Instance.new("ManualWeld");
    	weld.Part0 = a;
    	weld.Part1 = b;
    	weld.C0 = CFrame.new();
    	weld.C1 = b.CFrame:inverse() * a.CFrame;
    	weld.Parent = a;
    	return weld;
	end;
	for i,v in pairs(Players) do
		if v.Character then
			if not v.Character:FindFirstChild("HumanoidRootPart") then return; end;
			local Torso;
			if v.Character:FindFirstChild("Torso") then
				Torso = v.Character:FindFirstChild("Torso");
			elseif v.Character:FindFirstChild("UpperTorso") then
				Torso = v.Character:FindFirstChild("UpperTorso");
			elseif v.Character:FindFirstChild("Head") then
				Torso = v.Character:FindFirstChild("Head");
			elseif v.Character.HumanoidRootPart then
				Torso = v.Character:FindFirstChild("HumanoidRootPart");
			else
				Torso = Instance.new('Part');
			end;
			if not Torso then return; end;
			local BodyForce = Instance.new('BodyForce')
			BodyForce.Force = Vector3.new(0,8000,0)
			local Rocket = Instance.new("Part")
			Rocket.Size = Vector3.new(1,1,4)
			local Fire = Instance.new("Fire",Rocket)
			local Mesh = Instance.new("SpecialMesh",Rocket)
			Mesh.MeshId = 'http://www.roblox.com/asset/?id=2251534'
			Mesh.Scale =Vector3.new(.5,.5,.5)
			Rocket.Parent = v.Character
			Rocket.CFrame = Torso.CFrame*CFrame.new(Vector3.new(0,0,1))*CFrame.Angles(math.rad(90),0,0)
			weldBetween(Torso,Rocket)
			BodyForce.Parent = v.Character.HumanoidRootPart
			pcall(function()
				v.Character.Humanoid.Jump = true
			end)
			spawn(function()
				wait(5)
				if Rocket.Parent and v.Character and Torso then
					if not v.Character.HumanoidRootPart then return end
					local Expl = Instance.new('Explosion')
					Expl.Position = v.Character.HumanoidRootPart.Position
					Expl.BlastPressure = 500
					Expl.Parent = workspace
				end
			end)
		end
	end
end)
Core:AddCmd("Explode", {"explode"}, "Explodes a player.", cmdRank, "explode [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1)
	local Color = table.concat(Args,' ')
	if #Players >= 1 then
		for i,v in pairs(Players) do
			local Succ,Err = pcall(function()
				local Effect = Instance.new("Explosion")
				Effect.BlastRadius = 5
				Effect.Position = v.Character.HumanoidRootPart.Position
				Effect.Parent = workspace
			end)
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("Bubblechat", {'bubblechat','bchat'}, "Respawns you as soon as you die.", cmdRank, "bchat [Players]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	for i,v in pairs(Players) do
		BubbleChat[v] = true
		Player:TimedDismiss(Player:NewTab("BubbleChat: On\n"..v.Name, "Cyan"),2)
	end
end)
Core:AddCmd("UnBubblechat", {'unbubblechat','unbchat'}, "Respawns you as soon as you die.", cmdRank, "unbchat [Players]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	for i,v in pairs(Players) do
		BubbleChat[v] = false
		Player:TimedDismiss(Player:NewTab("BubbleChat: Off\n"..v.Name, "Cyan"),2)
	end
end)
Core:AddCmd("AntiDeath", {'antideath','ad'}, "Respawns you as soon as you die.", cmdRank, "antideath", function(Player, Args)
	if not AntiDeath[Player] then
		AntiDeath[Player] = Player.CharacterAdded:connect(function(Char)
			Char.Humanoid.Died:connect(function()
				Player:RunCommand(Player:Prefix()..'re me',false)
			end)
		end)
		Player:RunCommand(Player:Prefix()..'re me')
		Player:NewTab('Anti death is active.','Lime green')
	else
		AntiDeath[Player]:disconnect()
		AntiDeath[Player] = nil
		Player:RunCommand(Player:Prefix()..'re me')
		Player:NewTab('Anti death is deactivated.','Crimson')
	end
end)
Core:AddCmd("DeepClean", {'deepclean','dclean','deepc','dc'}, "Deep cleans the server.", cmdRank, "dclean", function(Player, Args)
	game:GetService("Lighting"):ClearAllChildren();
	game:GetService("Workspace"):FindFirstChildWhichIsA("Terrain"):Clear();
	game:GetService("Workspace"):FindFirstChildWhichIsA("Terrain"):ClearAllChildren();
	game:GetService("Workspace").Gravity = 196.2;
	game:GetService("Lighting").Brightness = 0;
	game:GetService("Lighting").Ambient = Color3.fromRGB(0, 0, 0);
	game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255, 255, 255);
	game:GetService("Lighting").TimeOfDay = 14;
	game:GetService("Lighting").GlobalShadows = true;
	game:GetService("Lighting").GeographicLatitude = 41.733;
	game:GetService("Lighting").Outlines = true;
	game:GetService("Lighting").FogStart = 0;
	game:GetService("Lighting").FogEnd = 100000;
	for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
		coroutine.resume(coroutine.create(function()
			if not v:IsA("Terrain") and not v:IsA("Camera") then
				if v.Name ~= "Base" and v.Name ~= "Baseplate" then
					v:Destroy();
				else
					v:ClearAllChildren();
					v.Anchored = true;
					v.CanCollide = true;
					v.Locked = true;
					v.Archivable = false;
					v.Material = Enum.Material.Grass;
					v.BrickColor = BrickColor.Green();
				end;
			end;
		end));
	end;
	
	for i,v in pairs(game:GetService('Players'):GetPlayers()) do
		spawn(function()
			if v.Character then
     			local pos = v.Character:FindFirstChild('HumanoidRootPart') or v.Character:FindFirstChild('Torso') or v.Character:FindFirstChild('Head') or Instance.new("Part");
      			local position = pos.CFrame;
      			v:LoadCharacter();
      			v.Character:FindFirstChild("HumanoidRootPart").CFrame = position;
			else
				v:LoadCharacter();
			end;
		end);
	end;
	local Services = {'Workspace','Lighting','ReplicatedStorage','Players','ReplicatedFirst','ServerScriptService','ServerStorage'};
	for i,Service in pairs(Services) do
		pcall(function() game:GetService(Service).Name = Service; end);
	end;
end);
Core:AddCmd("PingTo", {'pingto','pto','pingt'}, "Ping to someone.", cmdRank, "pingto [Player(s)] [Message]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args, 1);
	local Msg = table.concat(Args, ' ');
	for _, Plr in pairs(Players) do
		Plr:NewTab("Pong\n" .. game:GetService("Chat"):FilterStringForBroadcast(table.concat(Args,' '), Player.PlrObj), "White");
	end;
end);

--Rank 3
cmdRank = 3;

Core:AddCmd("Morph", {"morph"}, "Morphs a player.", cmdRank, "morph [Player] [Morph]",function(Player,Args)
	local Players = Player:GetPlrs(Args[1]);
	local Morph = Args[2]
	for i,v in pairs(Players) do
		spawn(function()for _,cMorph in pairs(Assets.Morphs:GetChildren()) do
			if cMorph.Name:lower():find(Morph) then
				pcall(function()MorphHandler:Morph(v.PlrObj,cMorph:Clone())end)
				Player:TimedDismiss(Player:NewTab("Morphed "..v.Name .. "\n"..cMorph.Name, "Cyan"))
				return
			end
		end;end)
	end
end)
Core:AddCmd("ListMorphs", {"ListMorphs","morphs","lmorphs"}, "Lists Morphs.", cmdRank, "morphs [Page]",function(Player,Args)
	local InitMorphs = {}
	local Page = tonumber(Args[1])
	if not Page then Page = 1 end
	for Index,Morph in pairs(Assets.Morphs:GetChildren()) do
		table.insert(InitMorphs,Morph)
	end;
	local viewMorphs;viewMorphs = function(Page)
		Player:DismissAll();
		Player:NewTab("Morphs","Deep orange");
		if not Page then Page = 1; end;
		local showMorphs = {};
		local Start = 1;
		if Page > 1 then Start = (Page * 10) - 9; end;
		local End = Start + 9;
		local HasNextPage = true;
		for i = Start,End do
			if InitMorphs[i] then
				showMorphs[i] = InitMorphs[i];
			else
				HasNextPage = false;
			end;
		end;
		for i,Morph in pairs(showMorphs) do
			Player:NewTab(Morph.Name, "Cyan", function()
				Player:DismissAll()
				Player:RunCommand(Player:Prefix().."morph me "..Morph.Name:lower())
			end);
		end;
		if HasNextPage then
			Player:NewTab("Next Page", "Bright orange",function()
				Player:DismissAll();
				viewMorphs(Page+1);
			end);
		end;
		Player:NewTab('Page:\n'..Page..[[/]].. math.ceil(#InitMorphs/10), "Bright orange");
		if Page > 1 then
			Player:NewTab("Previous Page", "Bright orange",function()
				Player:DismissAll();
				viewMorphs(Page-1);
			end);
		end;
		Player:DismissTab();
	end;
	viewMorphs(1)
end)
Core:AddCmd("ShowMouse", {"showmouse",'showpointer',"showm"}, "Shows a players mouse.", cmdRank, "showmouse [Player]",function(Player,Args)
	local Players = Player:GetPlrs(Args[1])
	for i,v in pairs(Players) do
		pcall(function()
			v:SendData({"ShowMouse"})
		end)
	end
end)
Core:AddCmd("HideMouse", {"hidemouse",'hidepointer',"hidem"}, "Hides a players mouse.", cmdRank, "hidemouse [Player]",function(Player,Args)
	local Players = Player:GetPlrs(Args[1])
	for i,v in pairs(Players) do
		pcall(function()
			v:SendData({"HideMouse"})
		end)
	end
end)
Core:AddCmd("AdminStats", {'adminstats','astats'}, "Shows admin stats.", cmdRank, "astats", function(Player, Args)
	Player:DismissAll()
	Player:NewTab("Statistics","Deep orange");
	for x,y in pairs(Stats) do
		Player:NewTab(x.."\n"..y,"Cyan");
	end
	Player.DismissTab()
end)
--Core:AddCmd("ListScripts", {'scripts','lscripts','listscripts'}, "Loads a saved script.", cmdRank, "loads [Name]", function(Player, Args)
--	local Saves = Player:GetExtraData("SavedScriptsFE")
--	if not Saves then
--		Player:NewTab("No saves found.","Crimson");
--		return
--	end
--	Player:DismissAll()
--	Player:NewTab("Saved Scripts","Deep orange");
--	for i,v in pairs(Saves) do
--		Player:NewTab(i,"Cyan",function()
--			Player:DismissAll()
--			Player:RunCommand(Player:Prefix().."loads "..i)
--		end);
--	end;
--	Player.DismissTab()
--end)
--Core:AddCmd("LoadScript", {'loadscript','runs','loads'}, "Loads a saved script.", cmdRank, "loads [Name]", function(Player, Args)
--	local Name = Args[1];
--	if not Name then
--		Player:NewTab("Invalid args.\n[Name]","Crimson");
--		return;
--	end;
--	local Saves = Player:GetExtraData("SavedScriptsFE");
--	
--	if Saves then
--		for i,v in pairs(Saves) do
--			if i == Name then
--				local Progress = Player:NewTab("Loading "..i.."...","Lime green");
--				require(Modules.RunAsFe)(Player.PlrObj,v);
--				Player:Dismiss(Progress);
--			end;
--		end;
--	else
--		Player:NewTab("No saves scripts.","Crimson");
--	end;
--end);
--Core:AddCmd("SaveScript", {'savescript','news','saves'}, "Saves a script.", cmdRank, "saves [Name] [Link]", function(Player, Args)
--	Player:DismissAll()
--	local Name = Args[1]
--	local Link = Args[2]
--	if not Name or not Link then
--		Player:NewTab("Invalid args.\n[Name] [Link]","Crimson");
--		return
--	end
--	if not Player:GetExtraData("SavedScriptsFE") then
--		Player:SetExtraData("SavedScriptsFE",{})
--	end
--	
--	local Progress = Player:NewTab("Working...","Lime green");
--	
--	local Saves = Player:GetExtraData("SavedScriptsFE")
--	if Player:GetExtraData("SavedScripts") then
--		Player:SetExtraData("SavedScripts",nil)
--	end
--	
--	
--	local Source = nil
--	pcall(function()
--		Source = game:service"HttpService":GetAsync(Link)
--	end)
--	
--	if not Source then
--		Player:DismissAll()
--		Player:NewTab("Failed to get link. Save aborted.","Crimson");
--		return
--	end
--	
--	
--	Player:RunCommand(Player:Prefix().."re me")
--	require(Modules.RunAsFe)(Player.PlrObj,Link)
--	wait()
--	Player:DismissAll()
--	Player:NewTab("Save Script\nDid your local load properly?","Deep orange");
--	Player:NewTab("Yes","Lime green",function()
--		Player:DismissAll()
--		Saves[Name] = Link
--		Player:SetExtraData("SavedScriptsFE",Saves)
--		Player:SaveData()
--		Player:NewTab("Script saved!","Lime green");
--	end);
--	Player:NewTab("No","Persimmon",function()
--		Player:DismissAll()
--		Player:NewTab("Save aborted.","Crimson");
--	end);
--end)
--Core:AddCmd("RemoveScript", {'removescript','removes','rmscript','rms'}, "Removes a script from your saved scripts.", cmdRank, "removescript [Name]", function(Player, Args)
--	Player:DismissAll();
--	local Name = Args[1];
--	if not Name then
--		Player:NewTab("Invalid args.\n[Name]","Crimson");
--		return;
--	end;
--	if not Player:GetExtraData("SavedScriptsFE") then
--		Player:SetExtraData("SavedScriptsFE",{});
--		Player:NewTab("You have no saved scripts.", "Crimson");
--		return;
--	end;
--	
--	local Progress = Player:NewTab("Working...","Lime green");
--	local Saves = Player:GetExtraData("SavedScriptsFE");
--	local Found = false;
--	
--	if Saves[Name] then
--		Player:DismissAll();
--		Player:NewTab("Remove Script\nScript \"" .. Name .. "\" found. Remove?", "Deep orange");
--		Player:NewTab("Yes", "Lime green", function()
--			Player:DismissAll();
--			Saves[Name] = nil;
--			Player:SetExtraData("SavedScriptsFE", Saves);
--			Player:SaveData();
--			Player:NewTab("Removed script \"" .. Name .. "\"", "Lime green");
--		end);
--		Player:NewTab("No", "Persimmon", function()
--			Player:DismissAll();
--			Player:NewTab("Remove aborted.", "Crimson");
--		end);
--	else
--		Player:DismissAll();
--		Player:NewTab("Could not find script \"" .. Name .. "\"", "Crimson");
--	end;
--end);

Core:AddCmd("Kick", {"kick"}, "Kicks a player.", cmdRank, "kick [Player] [reason]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1);
	local Reason = table.concat(Args,' ');
	if #Args < 4 then Player:NewTab(Settings.Messages.Error.NO_KICK_REASON,"Crimson"); end;
	if #Players == 1 or Player:Rank() >= 4 then
		for i,v in pairs(Players) do
			if Player:Rank() > v:Rank() and Player ~= v then
				local Succ,Err = pcall(function()
					v:Kick("Project Cobra\n"..Player.Name.."\n".. game:GetService("Chat"):FilterStringForBroadcast(Reason, Player.PlrObj));
					Player:NewTab("Kicked "..v.Name,"Lime green");
				end);
			else
				Player:NewTab(v.Name.." is a equal or higher rank.","Crimson");
			end;
		end;
	elseif #Player == 0 then
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	else
		Player:NewTab("Only staff can kick multiple people at once.","Crimson");
	end;
end);


--Rank 4
cmdRank = 4;

Core:AddCmd("Warn", {'warn','w'}, "Warn a player.", cmdRank, "warn [Player] [Message]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args,1);
	local Message = table.concat(Args,' ');
	if #Players == 1 then
		for i,v in pairs(Players) do
			if Player:Rank() > v:Rank() and Player ~= v then
				local Succ,Err = pcall(function()
					v:NewTab("Warning\n" .. game:GetService("Chat"):FilterStringForBroadcast(table.concat(Args,' '), Player.PlrObj), "Crimson");
					Player:NewTab("Warned "..v.Name,"Lime green");
				end);
				if not Succ then
					Player:NewTab("Error Warning ".. v.Name,"Crimson");
				end;
			else
				Player:NewTab(v.Name.." is a equal or higher rank.","Crimson");
			end;
		end;
	elseif #Players == 0 then
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	elseif #Players > 1 then
		Player:NewTab("You cannot warn multiple Players at once!","Crimson");
	end;
end);
Core:AddCmd("Broadcast", {"broadcast"}, "Sends a message to all servers.", cmdRank, "broadcast", function(Player, Args)
	local Data = {}
	Data.from = Player.Name;
	Data.msg = table.concat(Args,' ')
	
	Data = Web:Encode(Data)
	
	game:GetService("MessagingService"):PublishAsync("PCBroadcast", Data)
	Player:NewTab("Broadcast Sent!","Lime green");
end);
--Core:AddCmd("ForceChat", {"forcechat","fchat"}, "Forces a player to chat a message..", cmdRank, "fchat [Player] [Message]", function(Player, Args)
--	local Players = Player:GetPlrs(Args[1]);
--	table.remove(Args,1)
--	if #Players >= 1 then
--		for i,v in pairs(Players) do
--			v:SendData({"FChat",table.concat(Args,' ')})
--			Player:NewTab("FChatted "..v.Name,"Lime green")
--		end
--	else
--		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
--	end
--end);
Core:AddCmd("DismissAllTabs", {"dismissalltabs",'dismissall','dta'}, "Dismiss all tabs.", cmdRank, "dta", function(Player, Args)
	for x,y in pairs(ActivePlayers) do
		y:DismissAll();
	end;
end,false);
Core:AddCmd("SBBlock", {"sbblock"}, "Prevents a player from using SB commands.", cmdRank, "sbblock [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			v:SendData({"SBBlock"})
			Player:NewTab("SBBlocked "..v.Name,"Lime green")
		end
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end
end);
Core:AddCmd("UnSBBlock", {"unsbblock"}, "Un SBBlocks a player", cmdRank, "unsbblock [Player]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players >= 1 then
		for i,v in pairs(Players) do
			v:SendData({"UnSBBlock"});
			Player:NewTab("UnSBBlocked "..v.Name,"Lime green");
		end;
	else
		Player:NewTab(Settings.Messages.Error.NO_PLAYER,"Crimson");
	end;
end);
Core:AddCmd("Unban", {"unban"},"Un-bans a player.", cmdRank, "unban [Username] [Reason]", function(Player, Args)
	Player:DismissALl();
	local Username = Args[1];
	table.remove(Args,1);
	local Reason = table.concat(Args,' ');
	if Reason == "" or Reason == " " then
		Player:NewTab("Please provide a reason..","Crimson");
		return;
	end;
	local UserId = 0;
	local UserIdSucc,Err = pcall(function()
		UserId = game:GetService("Players"):GetUserIdFromNameAsync(Username);
	end);
	if not UserIdSucc then
		Player:NewTab("Failed to find UserId.","Crimson");
		return;
	end;
	
	if Username and Reason and UserId then
		local Progress = Player:NewTab("Working...","Lime green");
		if not Users[tostring(UserId)] then
			Users[tostring(UserId)] = {Rank = 0; Prefix = "."; ExtraData = {};};
		end;
		if Users[tostring(UserId)].Rank >= 0 then
			Player:NewTab("User isnt banned.","Crimson");
			return;
		end;
		
		Users[tostring(UserId)].Rank = 0;
		
		local Extra = Users[tostring(UserId)]["ExtraData"];
		Extra.PreviousBan = {["BannedBy"] = Extra.BannedBy;["BanDays"] = Extra.BanDays;["BanTime"] = Extra.BanTime;["BanReason"] = Extra.BanReason};
		Extra.BannedBy = nil;
		Extra.BanDays = nil;
		Extra.BanTime = nil;
		Extra.BanReason = nil;
		
		local Data = {['Method'] = "update"; ['User-Id'] = UserId;};
		for i,v in pairs(Users[tostring(UserId)]) do
			if i == "ExtraData" then Data[i] = Web:Encode(v) else Data[i] = v; end;
		end;
		Data['Override'] = true;
		Web:sendData(Data, "players.php");
		--BanHook("Green",Player.Name.." un-banned [" .. Username.."](https://www.roblox.com/users/"..UserId.."/profile)\nUn-ban reason: "..Reason.."\nTime: "..Extra.PreviousBan.BanDays.." days\nReason: "..Extra.PreviousBan.BanReason.."\nBanned by: "..Extra.PreviousBan.BannedBy,UserId);
		Player:Dismiss(Progress);
		Player:NewTab("Un-ban sent!","Lime green");
	else
		Player:NewTab("Invalid input.","Crimson");
	end;
end);
Core:AddCmd("TempBan", {"tempban","tban"},"Temporarily ban a player.", cmdRank, "tban [Username] [Days] [Reason]", function(Player, Args)
	Player:DismissALl();
	local Username = Args[1];
	local Days = tonumber(Args[2]);
	table.remove(Args,1);
	table.remove(Args,1);
	local Reason = table.concat(Args,' ');
	if Reason == "" or Reason == " " then
		Player:NewTab("Please provide a reason..","Crimson");
		return;
	end;
	local UserId = 0;
	local UserIdSucc,Err = pcall(function()
		UserId = game:GetService("Players"):GetUserIdFromNameAsync(Username);
	end);
	if not UserIdSucc then
		Player:NewTab("Failed to find UserId.","Crimson");
		return;
	end;
	if not Days then
		Player:NewTab("Invalid time.","Crimson");
		return;
	end;
	
	if Username and Days and Reason and UserId then
		Player:NewTab("Click to confirm ban information.","Deep orange",function()
			Player:DismissAll();
			local Progress = Player:NewTab("Working...","Lime green");
			if not Users[tostring(UserId)] then
				Users[tostring(UserId)] = {Rank = 0; Prefix = "."; ExtraData = {};};
			end;
			if Users[tostring(UserId)].Rank >= Player:Rank() then
				Player:Dismiss(Progress);
				Player:NewTab("Cannot ban a user of higher or equal rank. Derp.","Crimson");
				return;
			else
				Users[tostring(UserId)].Rank = -1;
				Users[tostring(UserId)].ExtraData.BanDays = Days;
				Users[tostring(UserId)].ExtraData.BanTime = os.time();
				Users[tostring(UserId)].ExtraData.BannedBy = Player.Name;
				Users[tostring(UserId)].ExtraData.BanReason = Reason;
			
				local Data = {['Method'] = "update"; ['User-Id'] = UserId;};
				for i,v in pairs(Users[tostring(UserId)]) do
					if i == "ExtraData" then Data[i] = Web:Encode(v) else Data[i] = v; end;
				end;
				Data['Override'] = true;
				Web:sendData(Data, "players.php");
				--BanHook("Red",Player.Name .. " banned [" .. Username.."](https://www.roblox.com/users/"..UserId.."/profile)\nTime: "..Days.." days\nReason: "..Reason,UserId);
				Player:Dismiss(Progress);
				Player:NewTab("Ban sent!","Lime green");
			end
		end)
		Player:NewTab("Username: "..Username.."\nUserId: "..UserId,"Cyan");
		Player:NewTab("Ban time: "..Days.." days","Cyan");
		Player:NewTab("Reason: "..Reason,"Cyan");
		Player:NewTab("Click to abort ban.","Crimson",function()
			Player:DismissAll();
		end);
	else
		Player:NewTab("Invalid input.","Crimson");
	end;
end);
Core:AddCmd("ManualUpdate", {"manualupdate","manupdate"},"Manually updates all data.", cmdRank, "manupdate", function(Player, Args)
	local Update = Player:NewTab(Settings.Messages.Status.UPDATING,"White");
	Core:UpdateGlobalData();
	Player:Dismiss(Update);
	Player:NewTab(Settings.Messages.Status.UPDATED,"Lime green");
end);
Core:AddCmd("ChangePoints", {'cbrowniepoints','cbrownies','cpoints','cpts'}, "Allows staff to give and remove points. (Essentially brownie points)", cmdRank, "points [Get/Set/Give/Take] [Player(s)] [Number]", function(Player, Args)
	local Type = Args[1]; table.remove(Args, 1);
	local Players = Player:GetPlrs(Args[1]); table.remove(Args, 1);
	local Points;
	if Args[1] then Points = Args[1]; table.remove(Args, 1); end;
	Player:DismissAll();
	if not Type:lower() == "get" then if Points == nil then Player:NewTab(Settings.Messages.Error.INVALID_INPUT .. " No points specified.", "Crimson"); end; end;
	local funcs = {};
	funcs.set = function(Plr, Points)
		Plr:SetExtraData("Points", Points);
	end;
	funcs.give = function(Plr, Points)
		Plr:SetExtraData("Points", Plr:GetPoints() + Points);
	end; funcs.add = funcs['give'];
	funcs.take = function(Plr, Points)
		Plr:SetExtraData("Points", Plr:GetPoints() - Points);
	end; funcs.remove = funcs['take'];

	for _,Plr in pairs(Players) do
		if Plr:Rank() < Player:Rank() or Player:Rank() > 5 then
			if Type:lower() == "get" then
				Player:NewTab(string.format("%s\n%d Points", Plr.PlrObj.Name, Plr:GetPoints()), "Cyan");
			else
				pcall(funcs[string.lower(Type)], Plr, tonumber(Points));
--				if Status == 0 then
					local Teb = Player:NewTab(string.format("Points changed for %s!", Plr.PlrObj.Name), "Lime green");
					Player:TimedDismiss(Teb);
--				else
--					Player:NewTab(string.format("Error for %s: %s", Plr.PlrObj.Name, (Status == 1 and Settings.Messages.Error.INVALID_INPUT or "Player not found.")), "Crimson");
--				end;
			end;
		else
			if Type:lower() == "get" then
				Player:NewTab("Testing", "Lime green");
				Player:NewTab(string.format("%s\n%d Points", Plr.PlrObj.Name, Plr:GetPoints()), "Cyan");
			else
				Player:NewTab("Error: " .. Plr.PlrObj.Name .. " - " .. Settings.Messages.Error.HIGHER_RANK, "Crimson");
			end;
		end;
	end;
	if Type:lower() == "get" then Player:DismissTab(); end;
end);
Core:AddCmd("VolumeLock", {'volumelock', 'vlock'}, "Locks Volume for Sounds", cmdRank, "vlock [Value]", function(Player, Args)
	local Class, Property = "Sound", "Volume"
	local Value = table.concat(Args,' ')
	pcall(function() Value = loadstring([[return ]]..Value)(); end) --Allows you to lock other Values besides strings. Ex: Color3, Size, Position
	if not type(Value) == "number" then return Player:NewTab("Value must be a number","Crimson"); end;
	if Value > 1 or Value < 0.01 then return Player:NewTab("Volume must be between 0.01 and 1","Crimson"); end;
	if not LockedProperties[Class] then LockedProperties[Class] = {}; end;
	LockedProperties[Class][Property] = Value;
	
	for i,Part in pairs(workspace:GetDescendants()) do
		if Part:IsA(Class) then
			pcall(function()
				Part[Property] = Value;
			end);
		end;
	end;
	Player:NewTab(string.format("Locked %s at %s for %s", Property, tostring(Value), Class),"Lime green");
end);
Core:AddCmd("UnVolumeLock", {'unvolumelock', 'unvlock', 'uvlock'}, "Unlocks Volume for Sounds", cmdRank, "unvplock", function(Player, Args)
	if LockedProperties["Sound"] and LockedProperties["Sound"]["Volume"] then
		LockedProperties["Sound"]["Volume"] = nil;
		Player:NewTab(string.format("Unlocked %s for %s", "Volume", "Sound"),"Lime green");
	end;
end);



--Rank 5
cmdRank = 5;

Core:AddCmd("Sudo", {"sudo","s"}, "Forces a player to run a command.", cmdRank, "sudo [Player] [Command]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	table.remove(Args, 1);
	for _, Plr in pairs(Players) do
		if Plr:Rank() < Player:Rank() then
			Plr:RunCommand(Plr:Prefix() .. table.concat(Args, Settings.Suffix));
		else
			Player:NewTab(Settings.Messages.Error.HIGHER_RANK, "Crimson");
		end;
	end;
end);
Core:AddCmd("PropertyLock", {'propertylock', 'plock'}, "Locks properties of instances", cmdRank, "plock [Class] [Property] [Value]", function(Player, Args)
	local Class, Property = Args[1], Args[2];
	table.remove(Args,1);table.remove(Args,1);
	local Value = table.concat(Args,' ');
	pcall(function() Value = loadstring([[return ]]..Value)(); end); --Allows you to lock other Values besides strings. Ex: Color3, Size, Position
	if not LockedProperties[Class] then LockedProperties[Class] = {}; end;
	LockedProperties[Class][Property] = Value;
	
	for i,Part in pairs(workspace:GetDescendants()) do
		if Part:IsA(Class) then
			pcall(function()
				Part[Property] = Value;
			end);
		end;
	end;
	Player:NewTab(string.format("Locked %s at %s for %s", Property, tostring(Value), Class),"Lime green");
end);
Core:AddCmd("UnPropertyLock", {'unpropertylock', 'unplock', 'uplock'}, "Unlocks properties of instances", cmdRank, "unplock [Class] [Property]", function(Player, Args)
	if LockedProperties[Args[1]] and LockedProperties[Args[1]][Args[2]] then
		LockedProperties[Args[1]][Args[2]] = nil;
		Player:NewTab(string.format("Unlocked %s for %s", Args[2], Args[1]),"Lime green");
	end;
end);
Core:AddCmd("UnPropertyLockAll", {'unpropertylockall', 'unplockall', 'uplockall', 'uplocka'}, "Unlocks properties of all instances", cmdRank, "unplock", function(Player, Args)
	LockedProperties = {};
	Player:NewTab("Unlocked all properties","Lime green");
end);
Core:AddCmd("PermRank", {"permrank", "prank"}, "Changes a users rank permanently.", cmdRank, "prank [Player] [Rank]", function(Player, Args)
	local Players = Player:GetPlrs(Args[1]);
	if #Players == 1 then
		if not Users[tostring(Players[1].UserId)] then
			Users[tostring(Players[1].UserId)] = {Rank = 0; Prefix = "."; ExtraData = {};};
		end;
		if Players[1].PlrObj == Player.PlrObj then
			local Progress = Player:NewTab("Setting rank...","Lime green");
			wait(5);
			Player:Dismiss(Progress);
			Player:NewTab("You can't change your own rank! Derp.","Lime green");
		elseif Players[1]:Rank() < Player:Rank() then
			local Progress = Player:NewTab("Setting rank...","Lime green");
			if type(tonumber(Args[2])) == "number" then
				if tonumber(Args[2]) < Player:Rank() then
					Players[1]:SetData("Rank", tonumber(Args[2]));
					Players[1]:SetExtraData("RankChange-" .. os.time(), Player.PlrObj.Name .. " - " .. tonumber(Args[2]));
					Players[1]:SaveData(true);
					Player:Dismiss(Progress);
					Player:NewTab("Set "..Players[1].PlrObj.Name .. "'s rank.","Lime green");
					local Title = Players[1]:NewTab(Player.PlrObj.Name .. " set your rank to " .. Args[2], "Lime green");
					local S = Instance.new("Sound",Players[1].PlayerGui)
					S.SoundId = "rbxassetid://2163823654"
					S.Volume = 1
					S:Play()
				else
					Player:Dismiss(Progress);
					Player:NewTab("Cannot set a rank equal to or higher than your own.", "Crimson");
				end
			else
				Player:Dismiss(Progress);
				Player:NewTab(Settings.Messages.Error.RANK_NOT_NUMBER, "Crimson");
			end;
		else
			Player:NewTab(Settings.Messages.HIGHER_RANK,"Crimson");
		end;
	else
		Player:NewTab(Settings.Messages.TOO_MANY_PLAYERS,"Crimson");
	end;
end);
Core:AddCmd("Debug", {"debug"}, "Toggles Debug setting.", cmdRank, "debug", function(Player, Args)
	Settings.Debug = not Settings.Debug;
	if Settings.Debug then
		Player:NewTab("Debug\nOn","Lime green");
	else
		Player:NewTab("Debug\nOff","White");
	end
end);

Core:AddCmd("LocalExecute", {"localexecute", "lexe", "leval"}, "Execute code.", cmdRank, "leval [Code]", function(Player, Args)
	if not Player.PlrObj.UserId == 21467784 or not Player.PlrObj.UserId == 13282741 then return; end;
	local Code = table.concat(Args, Settings.Suffix);
	Player:SendData({"LocalEval",Code})
end);
Core:AddCmd("Execute", {"execute", "exe", "eval"}, "Execute code.", cmdRank, "eval [Code]", function(Player, Args)
	if not Player.PlrObj.UserId == 21467784 or not Player.PlrObj.UserId == 13282741 then return; end;
	local Code = table.concat(Args, Settings.Suffix);
	local MyCustomEnv = {};
		MyCustomEnv.print = function(...)
			local t = {...}
  			for i=1, select('#', ...) do
    			t[i] = tostring(t[i])
  			end
  			local data = table.concat(t, ' ')
			Player:NewTab("Print\n"..data,"Cyan");
		end
		MyCustomEnv.warn = function(...)
			local t = {...}
  			for i=1, select('#', ...) do
    			t[i] = tostring(t[i])
  			end
  			local data = table.concat(t, ' ')
			Player:NewTab("Warn\n"..data,"Bright orange");
		end
		MyCustomEnv.error = function(...)
			local t = {...}
  			for i=1, select('#', ...) do
    		t[i] = tostring(t[i])
  			local data = table.concat(t, ' ')
			Player:NewTab("Error\n"..data,"Crimson");
		end
		end
		
	local Function = loadstring(Code);
	if not Function then Player:NewTab('Syntax error', "Crimson"); return; end;
	
	local Run = setfenv(Function,setmetatable({},{
		__index = function (self, Index)
			if MyCustomEnv[Index] then
				return rawget(MyCustomEnv,Index)
			elseif Core[Index] then
				return function(...)
					return rawget(Core,Index)(Core,...)
				end
			elseif ExeEnv[Index] then
				return ExeEnv[Index]
			else
				return MainEnv[Index]
			end
		end;
		__newindex = function (self,Index,Value)
			rawset(ExeEnv,Index,Value)
		end;
		__metatable = "This metatable is locked by Terminal";
	}))
	
	local succ,err = pcall(Run);
	if succ then
		Player:NewTab("Code Executed.", 'White');
	else
		Player:NewTab(err, "Crimson")
	end
end);
Core:AddCmd("PlaceTP", {'placeteleport','placetp','ptp'}, "Teleport to place id.", cmdRank, "ptp [Id]", function(Player, Args)
	if not tonumber(Args[1]) then return; end;
	Player:NewTab(Settings.Messages.Status.TELEPORTING, "Lime green");
	game:GetService('TeleportService'):Teleport(tonumber(Args[1]), Player.PlrObj);
end);



--Rank 6
cmdRank = 6;



--//End Commands


--//Error Logger
game:GetService("ScriptContext").Error:Connect(function(message, trace, script)
	if Settings.Debug then
		Core:SendToRank(4, script:GetFullName().." errored!", "Bright red");
		Core:SendToRank(4, "Reason: "..message, "White");
		Core:SendToRank(4, "Trace: "..trace, "White");
	end;
end);

--//BindToClose
game:BindToClose(function()
	pcall(function() Web:sendData({['Method'] = "Remove";}); end);
end);

--//Start!
Core:UpdateGlobalData();
spawn(function()
	while true do
		wait(60); --//Every minute
		Core:UpdateGlobalData();
	end;
end);
repeat wait(); until Users ~= {};
print("[PC] Running");

--//Open Server In DB
spawn(function()
	do
		local succ, err = ypcall(function()
			local returned = Web:sendData({['Method'] = "Add"; ['Max-Players'] = tonumber(game:GetService("Players").MaxPlayers); ['Player-Count'] = #game:GetService("Players"):GetPlayers();});
		end);
	end;
end);

--//Player Functions
game:GetService("Players").PlayerAdded:connect(function(Player)
	spawn(function()Core:ConnectPlayer(Player);end);
end);
for i,Player in pairs(game:GetService("Players"):GetPlayers()) do
	spawn(function()Core:ConnectPlayer(Player);end);
end;

return setmetatable({},{
	__call = function()
		getfenv(0).warn("[Project Cobra] Load request sent.")
	end
})
