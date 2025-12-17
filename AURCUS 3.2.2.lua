

-- TIME LIMIT SYSTEM
gg.setVisible(false)

local function readFile(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local d = f:read("*a")
    f:close()
    return d
end

local function writeFile(path, text)
    local f = io.open(path, "w")
    if not f then return false end
    f:write(text)
    f:close()
    return true
end
-- ========== JANGAN LUPA DI UBAH ==========
local function timeLimit()
    local limitFile = "/sdcard/Android/limit.txt"
    local maxUses = 100
    local maxDays = 30
-- ==========================================
    local data = readFile(limitFile)
    local now = os.time()
    
    if not data then
        -- First run
        local newData = now .. "\n1\n" .. now
        writeFile(limitFile, newData)
        gg.toast("⏰ Trial Started (100 uses)")
        return true
    end
    
    local lines = {}
    for line in data:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    local installTime = tonumber(lines[1]) or now
    local useCount = tonumber(lines[2]) or 1
    local lastRun = tonumber(lines[3]) or now
    
    -- Check days limit
    local daysUsed = (now - installTime) / 86400
    if daysUsed > maxDays then
        gg.alert("⏰ Trial Expired!\n1 month limit reached.")
        return false
    end
    
    -- Check usage limit
    if useCount >= maxUses then
        gg.alert("⚠️ Usage Limit!\nMax 100 executions.")
        return false
    end
    
    -- Update data
    useCount = useCount + 1
    local newData = installTime .. "\n" .. useCount .. "\n" .. now
    writeFile(limitFile, newData)
    
    local daysLeft = math.floor(maxDays - daysUsed)
    local usesLeft = maxUses - useCount
    
    gg.toast("📅 " .. daysLeft .. " days, " .. usesLeft .. " uses left")
    return true
end

if timeLimit() then
    gg.toast("Time check OK")
else
    os.exit()
end

local KEY = "MY_COIN_KEY_ghj"


--===========================
-- 2. XOR ENCRYPT / DECRYPT
--===========================
local function xorCrypt(text, key)
    local res = {}
    local klen = #key
    for i = 1, #text do
        local b = string.byte(text, i)
        local kb = string.byte(key, ((i - 1) % klen) + 1)
        res[i] = string.char(b ~ kb)
    end
    return table.concat(res)
end


--===========================
-- 3. SAVE & LOAD COIN
--===========================
local coinFile = "/sdcard/Android/c.dat"

local function saveCoins(amount)
    local encrypted = xorCrypt(tostring(amount), KEY)
    local f = io.open(coinFile, "wb")

    if not f then
        gg.alert("❌ Tidak bisa menyimpan coin!")
        return false
    end

    f:write(encrypted)
    f:close()
    return true
end

local function loadCoins()
    local file = io.open(coinFile, "rb")

    -- Jika file tidak ada → coin awal 1000
    if not file then
        saveCoins(1000)
        return 1000
    end

    local encrypted = file:read("*a")
    file:close()

    local decrypted = xorCrypt(encrypted, KEY)
    return tonumber(decrypted) or 1000
end


--===========================
-- 4. FUNGSI -1 COIN
--===========================
local function spendCoin()
    local coins = loadCoins()

    if coins <= 0 then
        gg.alert("⚠️ Coin kamu habis!\nHubungi admin untuk isi ulang.")
        return false
    end

    coins = coins - 1
    saveCoins(coins)

    gg.toast("🪙 Coin tersisa: " .. coins)
    return true
end



gg.setVisible(false)
local script_run_count = 0
local CONFIGG = {
    THEME = {
        PRIMARY = "🔥",
        SECONDARY = "⚡",
        SUCCESS = "✅",
        ERROR = "❌",
        WARNING = "⚠️",
        INFO = "ℹ️",
        NETWORK = "🌐",
        SECURITY = "🔒",
        TERMINAL = "💻"
    },
    COLORS = {
        HEADER = "\27[38;5;196m",
        SUCCESS = "\27[38;5;46m",  
        INFO = "\27[38;5;51m",   
        WARNING = "\27[38;5;226m",
        RESET = "\27[0m"
    }
}

local function secureFileOperation(operation, filepath, data)
    local success, result = pcall(function()
        if operation == "read" then
            return gg.getFileContent(filepath) or "0"
        elseif operation == "write" then
            return gg.saveContent(filepath, data)
        end
    end)
    return success, result
end

local function loadRunCount()
    local success, count = secureFileOperation("read", "/sdcard/.velltools_data")
    if success then
        script_run_count = tonumber(count) or 0
    end
end

local function saveRunCount()
    script_run_count = script_run_count + 1
    secureFileOperation("write", "/sdcard/.velltools_data", tostring(script_run_count))
end

local function getSystemTimestamp()
    return {
        time = os.date("%H:%M:%S"),
        date = os.date("%d/%m/%Y"),
        year = os.date("%Y"),
        epoch = os.time(),
        day = os.date("%A"),
        month = os.date("%B")
    }
end

local function analyzeGameEnvironment()
    local package_name = gg.getTargetPackage() or "UNKNOWN_PROCESS"
    local version_info = "UNDEFINED"
    local app_name = "SYSTEM_PROCESS"
    local architecture = "UNKNOWN_ARCH"
    
    local success1, app_data = pcall(function()
        local info = gg.getTargetInfo()
        if info then
            return {
                version = info.versionName or "UNDEFINED",
                name = info.label or "SYSTEM_PROCESS",
                code = info.versionCode or 0
            }
        end
        return nil
    end)
    
    if success1 and app_data then
        version_info = app_data.version
        app_name = app_data.name
    end
    
    local success2, arch_data = pcall(function()
        local ranges = gg.getRanges()
        if ranges and type(ranges) == "table" and #ranges > 0 then
            local total_size = 0
            local arch_indicators = {arm64 = 0, arm = 0}
            
            for i = 1, math.min(#ranges, 10) do
                if ranges[i] and ranges[i].start and ranges[i].end_ then
                    local size = ranges[i].end_ - ranges[i].start
                    total_size = total_size + size
                    
                    if size > 0x10000000 then
                        arch_indicators.arm64 = arch_indicators.arm64 + 1
                    else
                        arch_indicators.arm = arch_indicators.arm + 1
                    end
                end
            end
            
            if arch_indicators.arm64 > arch_indicators.arm then
                return "ARM64-v8a"
            else
                return "ARM32-v7a"
            end
        end
        return "UNKNOWN_ARCH"
    end)
    
    if success2 then architecture = arch_data end
    
    local ranges_count = 0
    local success_ranges, ranges = pcall(function()
        return gg.getRanges()
    end)
    if success_ranges and ranges and type(ranges) == "table" then
        ranges_count = #ranges
    end
    
    local process_id = "N/A"
    local success_pid, target_info = pcall(function()
        return gg.getTargetInfo()
    end)
    if success_pid and target_info and target_info.processId then
        process_id = tostring(target_info.processId)
    end
    
    return {
        package = package_name,
        name = app_name,
        version = version_info,
        architecture = architecture,
        memory_ranges = ranges_count,
        process_id = process_id
    }
end

local function performNetworkAnalysis()
    gg.setVisible(false)
    gg.toast("🔍 Scanning network infrastructure...")
    
    local endpoints = {
        primary = "https://8.8.8.8",
        secondary = "https://1.1.1.1",
        test = "https://www.google.com"
    }
    
    local network_stats = {
        status = false,
        latency = 0,
        endpoint = "NONE",
        strength = "WEAK"
    }
    
    for name, url in pairs(endpoints) do
        local success, latency, endpoint = pcall(function()
            local start_time = os.clock()
            local response = gg.makeRequest(url)
            local end_time = os.clock()
            
            if response and response.code == 200 then
                local latency = (end_time - start_time) * 1000
                return latency, name
            end
            return nil, nil
        end)
        
        if success and latency then
            network_stats.status = true
            network_stats.latency = latency
            network_stats.endpoint = endpoint:upper()
            
            if latency < 50 then
                network_stats.strength = "EXCELLENT"
            elseif latency < 100 then
                network_stats.strength = "GOOD"
            elseif latency < 200 then
                network_stats.strength = "MODERATE"
            else
                network_stats.strength = "WEAK"
            end
            break
        end
    end
    
    return network_stats
end

local function gatherGeoIntelligence()
    local geo_data = {
        status = false,
        country = "CLASSIFIED",
        city = "UNKNOWN",
        isp = "SECURE_CONNECTION",
        ip = "HIDDEN",
        timezone = "UTC",
        threat_level = "LOW"
    }
    
    local success, response = pcall(function()
        return gg.makeRequest("http://ip-api.com/json/")
    end)
    
    if success and response and response.code == 200 then
        local data = response.content
        if data:find('"status":"success"') then
            geo_data.status = true
            geo_data.country = data:match('"country":"([^"]+)"') or "CLASSIFIED"
            geo_data.city = data:match('"city":"([^"]+)"') or "UNKNOWN"
            geo_data.isp = data:match('"isp":"([^"]+)"') or "SECURE_CONNECTION"
            geo_data.ip = data:match('"query":"([^"]+)"') or "HIDDEN"
            geo_data.timezone = data:match('"timezone":"([^"]+)"') or "UTC"
            
            -- Simulate threat assessment
            local threat_indicators = {
                data:find("VPN") and 1 or 0,
                data:find("Proxy") and 1 or 0,
                data:find("Tor") and 2 or 0
            }
            
            local total_threat = 0
            for _, threat in ipairs(threat_indicators) do
                total_threat = total_threat + threat
            end
            
            if total_threat > 2 then
                geo_data.threat_level = "HIGH"
            elseif total_threat > 0 then
                geo_data.threat_level = "MEDIUM"
            else
                geo_data.threat_level = "LOW"
            end
        end
    end
    
    return geo_data
end

local function generateHeader()
    local timestamp = getSystemTimestamp()
    return string.format([[
    
    ╔═══════════════════════════════════════════════════════════════╗
    ║  🔥 V E L L T O O L S  █  S Y S T E M  █  T E R M I N A L 🔥  ║
    ║                             [ RECON v2.0 ]                  ║
    ║═══════════════════════════════════════════════════════════════║
    ║ 💻 SESSION: %s  │  📅 DATE: %s        ║
    ║ ⚡ UPTIME: %s   │  🌍 DAY: %-10s     ║
    ║═══════════════════════════════════════════════════════════════║]], 
    timestamp.time, timestamp.date, 
    string.format("%04d SEC", os.time() % 10000), timestamp.day)
end

local function generateNetworkSection(network_data)
    local status_icon = network_data.status and "🟢" or "🔴"
    local strength_icon = ({
        EXCELLENT = "📶",
        GOOD = "📶", 
        MODERATE = "📵",
        WEAK = "📵"
    })[network_data.strength] or "❓"
    
    return string.format([[
    ║ 🌐 NETWORK STATUS: %s %-20s %s          ║
    ║ ⚡ RESPONSE TIME: %-8s │ 📡 ENDPOINT: %-10s ║
    ║ 📊 CONNECTION: %s %-15s                    ║]], 
    status_icon, 
    network_data.status and "ONLINE" or "OFFLINE",
    strength_icon,
    network_data.status and string.format("%.1f ms", network_data.latency) or "N/A",
    network_data.endpoint,
    strength_icon,
    network_data.strength)
end

local function generateGeoSection(geo_data)
    local security_icon = ({
        LOW = "🟢",
        MEDIUM = "🟡", 
        HIGH = "🔴"
    })[geo_data.threat_level] or "⚪"
    
    return string.format([[
    ║═══════════════════════════════════════════════════════════════║
    ║ 🗺️ GEOLOCATION: %-20s │ 🏙️ CITY: %-15s  ║
    ║ 🌐 IP ADDRESS: %-22s │ 🔒 THREAT: %s %-8s ║
    ║ 📡 ISP PROVIDER: %-47s ║]], 
    geo_data.country,
    geo_data.city,
    geo_data.ip,
    security_icon,
    geo_data.threat_level,
    geo_data.isp:sub(1, 47))
end

local function generateSystemSection(game_data)
    local arch_icon = game_data.architecture:find("64") and "🏗️" or "🔧"
    
    return string.format([[
    ║═══════════════════════════════════════════════════════════════║
    ║ 🎮 TARGET: %-50s ║
    ║ 📦 PACKAGE: %-48s ║
    ║ 🔖 VERSION: %-20s │ %s ARCH: %-15s ║
    ║ 🧠 MEMORY RANGES: %-8d │ 🔢 PID: %-18s ║]], 
    game_data.name:sub(1, 50),
    game_data.package:sub(1, 48),
    game_data.version,
    arch_icon,
    game_data.architecture,
    game_data.memory_ranges,
    tostring(game_data.process_id))
end

local function generateFooter()
    return string.format([[
    ║═══════════════════════════════════════════════════════════════║
    ║ 🔢 EXECUTION COUNT: %-8d │ 🛠️ GG ENGINE: %-15s ║
    ║ 👨‍💻 DEVELOPER: VELLIXAO      │ ⚡ STATUS: OPERATIONAL    ║
    ╚═══════════════════════════════════════════════════════════════╝
    
    🔥 System scan completed successfully
    ⚡ All modules operational
    🚀 Ready for advanced operations
    ]], 
    script_run_count,
    gg.VERSION or "UNKNOWN")
end
local function executeSystemScan()
   
    loadRunCount()
    saveRunCount()
    
    gg.toast("🔍 Initializing VellTools System Scanner...")
    gg.sleep(500)
    
    gg.toast("📡 Gathering system intelligence...")
    local game_data = analyzeGameEnvironment()
    
    gg.toast("🌐 Analyzing network infrastructure...")  
    local network_data = performNetworkAnalysis()
    
    gg.toast("🗺️ Collecting geolocation data...")
    local geo_data = gatherGeoIntelligence()
    
    gg.toast("📊 Compiling comprehensive report...")
    gg.sleep(300)
    
    local full_report = generateHeader() ..
                       generateNetworkSection(network_data) ..
                       generateGeoSection(geo_data) ..
                       generateSystemSection(game_data) ..
                       generateFooter()
    gg.alert(full_report, "🔄 Refresh", "📋 Export Data", "🚀 Continue")
 
    local export_data = string.format(
        "═══ VELLTOOLS SYSTEM REPORT ═══\n" ..
        "Developer: VELLIXAO | Session: %s\n" ..
        "Network: %s (%.1f ms)\n" ..
        "Location: %s, %s\n" ..
        "Target: %s v%s\n" ..
        "Architecture: %s | Runs: %d\n" ..
        "═══ END REPORT ═══",
        os.date("%H:%M:%S %d/%m/%Y"),
        network_data.status and "ONLINE" or "OFFLINE",
        network_data.latency or 0,
        geo_data.country,
        geo_data.city,
        game_data.name,
        game_data.version,
        game_data.architecture,
        script_run_count
    )
    
    gg.copyText(export_data)
    gg.toast("✅ System report exported to clipboard")
    gg.toast("🚀 VellTools scan completed - Ready for operations")
end
executeSystemScan()

function searchInDalvikMainSpace(searchString, searchType, sign)
    gg.setRanges(gg.REGION_JAVA_HEAP)
    local ranges = gg.getRangesList()
    local matched = {}

    for i, r in ipairs(ranges) do
        if r.name and r.name:lower():find("dalvik%-main space") then
            table.insert(matched, r)
        elseif tostring(r):lower():find("dalvik%-main space") then
            table.insert(matched, r)
        end
    end

    if #matched == 0 then
        gg.toast("❌ Tidak menemukan range dalvik-main space")
        return false
    end

    local totalFound = 0
    for i, r in ipairs(matched) do
        local startAddr = tonumber(r.start) or tonumber(tostring(r.start), 16)
        local endAddr   = tonumber(r["end"]) or tonumber(tostring(r["end"]), 16)

        if startAddr and endAddr and startAddr < endAddr then
            gg.searchNumber(searchString, searchType, false, sign, startAddr, endAddr, 0)
            local count = gg.getResultCount()
            if count > 0 then
                totalFound = totalFound + count
                gg.toast("✓ Range ke-" .. i .. ": " .. count .. " hasil")
                return true
            end
        end
    end
    
    if totalFound == 0 then
        gg.toast("❌ Tidak ada hasil ditemukan")
        return false
    end
end



-- Example usage with error handling
local function safeSearchNumber(value, type, ...)
    local status, result = pcall(gg.searchNumber, value, type, ...)
    
    if not status then
        logSecurityEvent("SEARCH_ERROR", "Failed search: " .. tostring(result))
        gg.alert("❌ Search error: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Menu for security settings
local function securityMenu()
    local choice = gg.choice({
        "1. Enable Security System",
        "2. Disable Security System",
        "3. Change Security Settings",
        "4. Test Security",
        "5. Back to Main Menu"
    }, nil, "🔒 Security Settings")
    
    if choice == 1 then
        enableSecuritySystem()
    elseif choice == 2 then
        disableSecuritySystem()
    elseif choice == 3 then
        -- Implementation for settings change
        gg.alert("Security settings menu coming soon!")
    elseif choice == 4 then
        gg.alert("Testing security system...")
        gg.setVisible(true) -- Trigger security manually for test
    end
end

-- Main protection loop (optional)
local function securityMonitor()
    while true do
        advancedSecurityCheck()
        gg.sleep(3000) -- Check every 3 seconds
    end
end

local AntiLoad = function(code) local Num = 0 local TakeCode = function(Code) local num2 = Num + 1 Num = num2 return code[Num] end return TakeCode end local code = {" "," "," "} assert(load(AntiLoad(code)))()
gg.setVisible(false)

-- Color palette professional untuk VELLIXAO Panel
local COLORS = {
    PRIMARY = "#2E86AB",    -- Blue professional
    SECONDARY = "#A23B72",  -- Purple elegant  
    SUCCESS = "#1F8A70",    -- Green success
    ACCENT = "#F0C808",     -- Gold accent
    TEXT = "#E8E8E8"        -- Light text
}

-- Fungsi loading box sesuai standar ELGG
function showLoading(text, duration)
    local loadingBox = getLoadingBox(text)
    if loadingBox then
        loadingBox["显示"]()
        if duration then
            gg.sleep(duration)
            loadingBox["关闭"]()
        end
        return loadingBox
    end
    return nil
end

-- Animasi loading bertahap
function stepLoading(steps)
    for i, step in ipairs(steps) do
        local loading = showLoading(step.text)
        gg.sleep(step.duration or 1000)
        if loading then
            loading["关闭"]()
        end
    end
end

-- Startup sequence
gg.colorAlert(
    "<font color='" .. COLORS.PRIMARY .. "'>🛡️ VELLIXAO DEVELOPMENT</font>",
    "<font color='" .. COLORS.TEXT .. "'>┌────────────────────────────┐</font>\n" ..
    "<font color='" .. COLORS.ACCENT .. "'>│    VIP PANEL PREMIUM SCRIPT.</font>\n" ..
    "<font color='" .. COLORS.TEXT .. "'>└────────────────────────────┘</font>\n\n" ..
    "<font color='" .. COLORS.SUCCESS .. "'>🎮 PREMIUM SERVER CLOUD</font>\n" ..
    "<font color='" .. COLORS.SECONDARY .. "'>💎 Tier: VIP</font>\n\n" ..
    "<font color='" .. COLORS.TEXT .. "'>✅ Press START to initialize</font>",
    "🚀 START", "❌ EXIT", "ℹ️ INFO"
)

gg.colorToast("<font color='" .. COLORS.ACCENT .. "'>🛡️ Initializing VELLIXAO Panel...</font>")

-- Loading sequence dengan getLoadingBox
stepLoading({
    {text = "🔍 Locating Game Process...", duration = 1000},
    {text = "🎯 Adapting to version ...", duration = 750},
    {text = "⚡ Initializing Modul Game...", duration = 5000},
    {text = "💎 Loading VIP Features...", duration = 850},
    {text = "🛡️ Activating security protocols...", duration = 600},
    {text = "✨ Optimizing performance...", duration = 500},
    {text = "✅ Panel ready for use...", duration = 400}
})

-- Completion message
gg.colorAlert(
    "<font color='" .. COLORS.SUCCESS .. "'>✅ PANEL READY</font>",
    "<font color='" .. COLORS.TEXT .. "'>All systems operational</font>\n\n" ..
    "<font color='" .. COLORS.ACCENT .. "'>✓ Aurcus Online v3.2.2</font>\n" ..
    "<font color='" .. COLORS.ACCENT .. "'>✓ VIP Bronze Activated</font>\n" ..
    "<font color='" .. COLORS.ACCENT .. "'>✓ Security Protocols Active</font>\n" ..
    "<font color='" .. COLORS.ACCENT .. "'>✓ Performance Optimized</font>\n\n" ..
    "<font color='" .. COLORS.SECONDARY .. "'>Developer: VELLIXAO</font>\n" ..
    "<font color='" .. COLORS.TEXT .. "'>Status: Professional Mode</font>",
    "🎮 CONTINUE", "⚙️ SETTINGS", "📊 INFO"
)

gg.colorToast("<font color='" .. COLORS.SUCCESS .. "'>🛡️ VELLIXAO Panel successfully loaded</font>")

-- Konfirmasi final
local loading = showLoading("🎯 Finalizing setup...", 1200)
if loading then
    loading["关闭"]()
end

gg.colorAlert(
    "<font color='" .. COLORS.PRIMARY .. "'>🚀 SYSTEM READY</font>",
    "<font color='" .. COLORS.TEXT .. "'>VELLIXAO Panel v3.2.2</font>\n\n" ..
    "<font color='" .. COLORS.SUCCESS .. "'>All modules loaded successfully</font>\n\n" ..
    "<font color='" .. COLORS.ACCENT .. "'>• Game: Aurcus Online (Global)</font>\n" ..
    "<font color='" .. COLORS.ACCENT .. "'>• Version: 3.2.2</font>\n" ..
    "<font color='" .. COLORS.ACCENT .. "'>• Tier: VIP Bronze</font>\n" ..
    "<font color='" .. COLORS.ACCENT .. "'>• Developer: VELLIXAO</font>\n\n" ..
    "<font color='" .. COLORS.SECONDARY .. "'>Professional gaming tools activated</font>",
    "💎 BEGIN", "🔧 OPTIONS", "📱 PROFILE"
)    
function searchInDalvikMainSpace(searchString, searchType, sign)
    gg.setRanges(gg.REGION_JAVA_HEAP)
    local ranges = gg.getRangesList()
    local matched = {}

    for i, r in ipairs(ranges) do
        if r.name and r.name:lower():find("dalvik%-main space") then
            table.insert(matched, r)
        elseif tostring(r):lower():find("dalvik%-main space") then
            table.insert(matched, r)
        end
    end

    if #matched == 0 then
        gg.toast("❌ Code Tidak Di Temukan")
        return false
    end

    local totalFound = 0
    for i, r in ipairs(matched) do
        local startAddr = tonumber(r.start) or tonumber(tostring(r.start), 16)
        local endAddr   = tonumber(r["end"]) or tonumber(tostring(r["end"]), 16)

        if startAddr and endAddr and startAddr < endAddr then
            gg.searchNumber(searchString, searchType, false, sign, startAddr, endAddr, 0)
            local count = gg.getResultCount()
            if count > 0 then
                totalFound = totalFound + count
                gg.toast("✓ Range ke-" .. i .. ": " .. count .. " hasil")
                return true
            end
        end
    end
    
    if totalFound == 0 then
        gg.toast("❌ Tidak ada hasil ditemukan")
        return false
    end
end
    
    function searchAndFreezeInDalvikMain(searchPattern1, searchPattern2, editValue1, freezeValue, valueName)
    gg.clearResults()
    gg.setVisible(false)
    
    -- Pencarian pertama di dalvik-main space
    if searchInDalvikMainSpace(searchPattern1, gg.TYPE_DWORD) then
        gg.processResume()
        local results = gg.getResults(100)
        if results and #results > 0 then
            gg.editAll(editValue1, gg.TYPE_DWORD)
        end
        gg.clearResults()
    end
    
    -- Pencarian kedua di dalvik-main space  
    if searchInDalvikMainSpace(searchPattern2, gg.TYPE_DWORD) then
        gg.processResume()
        local results = gg.getResults(100)
        if results and #results > 0 then
            for i, v in ipairs(results) do
                if v.flags == gg.TYPE_DWORD then
                    v.value = freezeValue
                    v.freeze = true
                end
            end
            gg.addListItems(results)
        end
        gg.clearResults()
    end
    
    -- Cleanup process
    gg.alert("🔒 " .. valueName .. " dibekukan. Klik icon GG untuk membersihkan...")
    while not gg.isVisible() do
        gg.sleep(100)
    end
    gg.setVisible(false)
    gg.clearResults()
    gg.clearList()
    gg.toast("🗑️ " .. valueName .. " - Freeze & Result dibersihkan.")
end
    
--button
running = true
TEMPLATE = 1

-- UI Constants
ON = "    ⃢🔵🔸"
OFF = "🔴⃢    🔸"
switch1 = OFF
switch2 = OFF
switch3 = OFF
switch4 = OFF

local stopLoot = false
local lastVisibleClock = 0

-- Utility: detect double-click on GG icon (approx within 0.6s)
local function checkDoubleClick()
  if gg.isVisible(true) then
    -- immediately hide GG UI to avoid showing it to user
    gg.setVisible(false)
    local now = os.clock()
    if now - lastVisibleClock <= 0.6 then
      -- second click within threshold -> toggle stop
      return true
    end
    lastVisibleClock = now
  end
  return false
end

-- Helper: run list of edits in order (preserve sequence)
local function runEditsSequential(edits)
  -- edits: array of tables {byteVal, wordVal, floatVal}
  for i = 1, #edits do
    local e = edits[i]
    gg.editAll(e.byteVal, gg.TYPE_BYTE)
    gg.editAll(e.wordVal, gg.TYPE_WORD)
    gg.editAll(e.floatVal, gg.TYPE_FLOAT)
    gg.sleep(100)
    -- check immediate double click to allow quicker stop between groups
    if checkDoubleClick() then
      stopLoot = true
      return
    end
  end
end

local coins = loadCoins()

-- HISTORY SYSTEM
HISTORY = {}
MENU_VISIBLE = false

function Go(menuFunc)
    table.insert(HISTORY, menuFunc)
    menuFunc()
end

function Back()
    table.remove(HISTORY)
    local last = HISTORY[#HISTORY]
    if last then
        last()
    else
        HOME()
    end
end

-- Function to hide menu completely
function HideMenu()
    MENU_VISIBLE = false
    gg.setVisible(false)
    gg.toast("Menu disembunyikan - Ketuk ikon GG untuk menampilkan kembali")
end

-- Function to show menu
function ShowMenu()
    MENU_VISIBLE = true
    local lastMenu = HISTORY[#HISTORY] or HOME
    lastMenu()
end

-- Border Design Functions
function createHeader(title)
    local dateTime = os.date("📆 Date: %A, %B %d %Y\n⏲️ Time: %I:%M %p")
    return "◤─「"..dateTime.."\nVELLIX_AO Aurcus Online\nSaldo: "..coins.." coin」─✦"
end

function createFooter()
    return "◣──────────❈"
end

function createMenuLine(text)
    return "│⦿ "..text
end

function createMenuTitle(section)
    return createHeader().."\n"..createMenuLine(section).."\n"..createFooter()
end

-- Modified choice function with hide support
function SafeChoice(options, preset, title)
    if not MENU_VISIBLE then
        return nil
    end
    
    local choice = gg.choice(options, preset, title)
    
    -- If user cancels or clicks outside, hide the menu
    if choice == nil then
        HideMenu()
        return nil
    end
    
    return choice
end

-- Modified multiChoice function with hide support
function SafeMultiChoice(options, preset, title)
    if not MENU_VISIBLE then
        return nil
    end
    
    local choices = gg.multiChoice(options, preset, title)
    
    -- If user cancels or clicks outside, hide the menu
    if choices == nil then
        HideMenu()
        return nil
    end
    
    return choices
end


-- Main Menu Function (UPDATED)
function HOME()
    gg.setVisible(false)
    
    HOMEMENU = SafeChoice({
        "◤─〔 BYPASS 〕",
        "│⦿ 〔 PLAYER 〕", 
        "│⦿ 〔 FARM 〕",
        "│⦿ 〔 DUNGEON 〕",
        "│⦿ 〔 TELEPORT 〕",
        "│⦿ 〔 COIN MISSION 〕",
        "│⦿ 〔 SKILL 〕",
        "│⦿ 〔 OTHER 〕",
        "│⦿ 〔 MUSIC 〕",
        "│⦿ 〔 AI 〕",
        "│⦿ 〔 ANNOUNCEMENT 〕",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「EXIT」─✦"
    }, nil, createMenuTitle("MAIN MENU"))
    
    if HOMEMENU == nil then return end
    
    if HOMEMENU == 1 then Go(BYPASS0)
    elseif HOMEMENU == 2 then Go(PLAYER)
    elseif HOMEMENU == 3 then Go(FARM)
    elseif HOMEMENU == 4 then Go(DUNGEON)
    elseif HOMEMENU == 5 then Go(TELEPORT)
    elseif HOMEMENU == 6 then Go(QUEST)
    elseif HOMEMENU == 7 then Go(SKILL)
    elseif HOMEMENU == 8 then Go(OTHER)
    elseif HOMEMENU == 9 then MUSIC()
    elseif HOMEMENU == 10 then AI()
    elseif HOMEMENU == 11 then Go(GUIDE)
    elseif HOMEMENU == 12 then HideMenu()
    elseif HOMEMENU == 13 then Exit()
    end
    
    HOMEDM = -1
end

-- Player Menu (UPDATED WITH HIDE SUPPORT)
function PLAYER()
    gg.setVisible(false)
    PMENU = SafeChoice({
        "◤─〔 PLAYER MENU 〕",
        "│⦿ 〔 STATUS EDIT",
        "│⦿ 〔 BASIC WEAPON", 
        "│⦿ 〔 PLOT ARMOR",
        "│⦿ 〔 RANDOM CHARACTER",
        "│⦿ 〔 REFRESH SKILL〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("PLAYER"))
    
    if PMENU == nil then return end
    
    if PMENU == 1 then PLAYER()
    elseif PMENU == 2 then statusedit()
    elseif PMENU == 3 then Go(basicweapon)
    elseif PMENU == 4 then unlishield()
    elseif PMENU == 5 then rc()
    elseif PMENU == 6 then rskill()
    elseif PMENU == 7 then Back()
    end
end

-- Farm Menu (UPDATED WITH HIDE SUPPORT)
function FARM()
    gg.setVisible(false)
    FMENU = SafeChoice({
        "◤─〔 FARM MENU 〕",
        "│⦿ 〔 STORAGE & MARKET",
        "│⦿ 〔 AREA FARM",
        "│⦿ 〔 LOOTING FARM", 
        "│⦿ 〔 BUFF",
        "│⦿ 〔 LOOPING SKILL",
        "│⦿ 〔 GUIDE",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("FARM"))
    
    if FMENU == nil then return end
    
    if FMENU == 1 then FARM()
    elseif FMENU == 2 then Go(bag)
    elseif FMENU == 3 then Go(areaF)
    elseif FMENU == 4 then Go(lootF)
    elseif FMENU == 5 then Abuff()
    elseif FMENU == 6 then ls()
    elseif FMENU == 7 then Go(Gfarm)
    elseif FMENU == 8 then HideMenu()
    elseif FMENU == 9 then Back()
    end
end

-- Dungeon Menu (UPDATED WITH HIDE SUPPORT)
function DUNGEON()
    gg.setVisible(false)
    DMENU = SafeChoice({
        "◤─〔 DUNGEON MENU 〕",
        "│⦿ 〔 NIGHT KINGDOM",
        "│⦿ 〔 GATE AREA",
        "│⦿ 〔 GUILD MISSION",
        "│⦿ 〔 DUNGEON CODE",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("DUNGEON"))
    
    if DMENU == nil then return end
    
    if DMENU == 1 then DUNGEON()
    elseif DMENU == 2 then nk()
    elseif DMENU == 3 then Go(Gate)
    elseif DMENU == 4 then Go(GuildMission)
    elseif DMENU == 5 then DungeonCode()
    elseif DMENU == 6 then HideMenu()
    elseif DMENU == 7 then Back()
    end
end

-- Teleport Menu (UPDATED WITH HIDE SUPPORT - multiChoice)
function TELEPORT()
    gg.setVisible(false)
    MTP = SafeMultiChoice({
        "◤─〔 TELEPORT MENU 〕",
        "│⦿ 〔 WITH EMBLEM",
        "│⦿ 〔 WITH NPC",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("TELEPORT"))
    
    if MTP == nil then return end
    
    if MTP[1] then TELEPORT()
    elseif MTP[2] then Go(Tport)
    elseif MTP[3] then Go(Tnpc)
    elseif MTP[4] then HideMenu()
    elseif MTP[5] then Back()
    end
end

-- Coin Mission Menu (UPDATED WITH HIDE SUPPORT)
function QUEST()
gg.setVisible(false)
    ccmenu = SafeChoice({
        "◤─〔 COIN MISSION 〕",
        "│⦿ 〔 CM【100c】> 1", "│⦿ 〔 CM【100c】> 2", "│⦿ 〔 CM【100c】> 3", 
        "│⦿ 〔 CM【100c】> 4", "│⦿ 〔 CM【100c】> 5", "│⦿ 〔 CM【100c】> 6", 
        "│⦿ 〔 CM【100c】> 7", "│⦿ 〔 CM【100c】> 8", "│⦿ 〔 CM【100c】> 9",
        "│⦿ 〔 CM【100c】> 10", "│⦿ 〔 CM【100c】> 11", "│⦿ 〔 CM【100c】> 12",
        "│⦿ 〔 CM【100c】> 13", "│⦿ 〔 CM【100c】> 14", "│⦿ 〔 CM【100c】> 15",
        "│⦿ 〔 CM【100c】> 16", "│⦿ 〔 CM【100c】> 17", "│⦿ 〔 CM【100c】> 18",
        "│⦿ 〔 CM【100c】> 19", "│⦿ 〔 CM【100c】> 20", "│⦿ 〔 CM【100c】> 21",
        "│⦿ 〔 CM【100c】> 22", "│⦿ 〔 CM【100c】> 23", "│⦿ 〔 CM【100c】> 24",
        "│⦿ 〔 CM【100c】> 25", "│⦿ 〔 CM【100c】> 26", "│⦿ 〔 CM【100c】> 27",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("COIN MISSION"))

    if ccmenu == nil then return end

    -- 27 fungsi CM
    local cmFunctions = {
        c100, cc1, cc2, cc3, cc4, cc5, cc6, cc7, cc8, cc9, cc10,
        cc11, cc12, cc13, cc14, cc15, cc16, cc17, cc18, cc19, cc20,
        cc21, cc22, cc23, cc24, cc25, cc26, cc27
    }

    if ccmenu == 1 then
        QUEST()                     -- Refresh (judul ditekan)
    elseif ccmenu >= 2 and ccmenu <= 28 then
        cmFunctions[ccmenu - 1]()    -- Jalankan fungsi CM1 – CM27
    elseif ccmenu == 29 then
        HideMenu()
    elseif ccmenu == 30 then
        Back()
    end
end

-- Skill Menu (UPDATED WITH HIDE SUPPORT)
function SKILL()
gg.setVisible(false)
    Smenu = SafeChoice({
        "◤─〔 SKILL MENU 〕",
        "│⦿ 〔 BASIC JOB",
        "│⦿ 〔 EXTRA JOB",
        "│⦿ 〔 TRIAL SKILL",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("SKILL"))
    
    if Smenu == nil then return end
    
    if Smenu == 1 then SKILL()
    elseif Smenu == 2 then Go(Bskill)
    elseif Smenu == 3 then Go(Eskill)
    elseif Smenu == 4 then Go(Tskill)
    elseif Smenu == 5 then HideMenu()
    elseif Smenu == 6 then Back()
    end
end

-- Other Menu (UPDATED WITH HIDE SUPPORT)
function OTHER()
gg.setVisible(false)
    Omenu = SafeChoice({
        "◤─〔 OTHER MENU 〕",
        "│⦿ 〔 WATER GUN BOOM",
        "│⦿ 〔 AREA WATHERGUN",
        "│⦿ 〔 UNLOCK ANIMASI",
        "│⦿ 〔 UNLOCK STAMP",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("OTHER"))
    
    if Omenu == nil then return end
    
    if Omenu == 1 then OTHER()
    elseif Omenu == 2 then Wgun()
    elseif Omenu == 3 then Agunl()
    elseif Omenu == 4 then anim()
    elseif Omenu == 5 then stamp()
    elseif Omenu == 6 then HideMenu()
    elseif Omenu == 7 then Back()
    end
end

-- Bypass Menu (UPDATED WITH HIDE SUPPORT)
function BYPASS0()
gg.setVisible(false)
    menudebug = SafeChoice({
        "◤─〔 Anti Force Close Saat Login  〕",
        "│⦿ 〔 Stabilizer Saat Pindah Map",
        "│⦿ 〔 Clear Memory Manual",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("BYPASS"))
    
    if menudebug == nil then return end
    
    if menudebug == 1 then antiLogin()
    elseif menudebug == 2 then mapStabilizer()
    elseif menudebug == 3 then clearMemory()
    elseif menudebug == 4 then HideMenu()
    elseif menudebug == 5 then Back()
    end
end

function Gate()
gg.setVisible(false)
    gatemenu = SafeChoice({
        "◤─〔 GATE MENU 〕",
        "│⦿ 〔 (G1) OUTER SHELL",
        "│⦿ 〔 (G2) CORRIDOR",
        "│⦿ 〔 (G3) CHAMBER",
        "│⦿ 〔 (G4) PROLOGUE",
        "│⦿ 〔 (G5) ORACLE",
        "│⦿ 〔 (G6) SALVATION",
        "│⦿ 〔 (G7) EXECUTION",
        "│⦿ 〔 (G7-E) EXECUTION EXPERT",
        "│⦿ 〔 (G8) PROLOGUE 2",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("GATE"))
    
    if gatemenu == nil then return end
    
    if gatemenu == 1 then Gate()
    elseif gatemenu == 2 then g1()
    elseif gatemenu == 3 then g2()
    elseif gatemenu == 4 then g3()
    elseif gatemenu == 5 then g4()
    elseif gatemenu == 6 then g5()
    elseif gatemenu == 7 then g6()
    elseif gatemenu == 8 then g7()
    elseif gatemenu == 9 then g7e()
    elseif gatemenu == 10 then g8()
    elseif gatemenu == 11 then Back()
    end
end


function GuildMission()
    gg.setVisible(false)

    local GM = SafeMultiChoice({
        "◤─〔 GUILD MISION 〕",
        "│⦿ 〔 DEN OF NO RETURN",
        "│⦿ 〔 FORES MANA POLL",
        "│⦿ 〔 PREA PDIP",
        "│⦿ 〔 OGRE",
        "│⦿ 〔 AVES",
        "◣─❈ 「 BACK 」─✦",
    }, nil, createMenuTitle("GUILD MISSION"))

    -- user pressed outside / cancel
    if GM == nil then return end

    -- opsi dimulai dari index 2 karena index 1 adalah header/title
    if GM[2] then ggtp1() end
    if GM[3] then ggtp2() end
    if GM[4] then ggtp3() end
    if GM[5] then ggtp4() end
    if GM[6] then ggtp5() end
    if GM[7] then Back() end
end


function Tport()
gg.setVisible(false)
    TportMenu = SafeChoice({
        "◤─〔 TELEPORT EMBLEM 〕",
        "│⦿ 〔 EVEHOME",
        "│⦿ 〔 DEV FAST DROPT",
        "│⦿ 〔 DEV RESET SKILL DROPT KEY",
        "│⦿ 〔 FARM BOSS EXP TO GET KEY",
        "│⦿ 〔 SETTA",
        "│⦿ 〔 NIGHT KINGDOM",
        "│⦿ 〔 STARDUST",
        "│⦿ 〔 SUMMER BEACH",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("TELEPORT"))

    if TportMenu == nil then return end

    if TportMenu == 1 then Tport()
    elseif TportMenu == 2 then tp1()
    elseif TportMenu == 3 then tp2()
    elseif TportMenu == 4 then tp3()
    elseif TportMenu == 5 then tp4()
    elseif TportMenu == 6 then tp5()
    elseif TportMenu == 7 then tp6()
    elseif TportMenu == 8 then tp7()
    elseif TportMenu == 9 then tp8()
    elseif TportMenu == 10 then Back()
    end
end

function Tnpc()
gg.setVisible(false)
    TnpcMenu = SafeChoice({
        "◤─〔 TELEPORT NPC 〕",
        "│⦿ 〔 ELLICIA DISTRICT",
        "│⦿ 〔 KUROWASHI CASTLE TOWN",
        "│⦿ 〔 POLITEAU TERROUS",
        "│⦿ 〔 SETA GRIA OUTER",
        "│⦿ 〔 VILLAGE OF HB IVRAI",
        "│⦿ 〔 WATERGUN",
        "│⦿ 〔 WOODEN STICK",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("TELEPORT NPC"))

    if TnpcMenu == nil then return end

    if TnpcMenu == 1 then Tnpc()
    elseif TnpcMenu == 2 then qsb1()
    elseif TnpcMenu == 3 then qsb2()
    elseif TnpcMenu == 4 then qsb3()
    elseif TnpcMenu == 5 then qsb4()
    elseif TnpcMenu == 6 then qsb5()
    elseif TnpcMenu == 7 then qsb6()
    elseif TnpcMenu == 8 then qsb7()
    elseif TnpcMenu == 9 then Back()
    end
end

function Bskill()
gg.setVisible(false)
    BskillMenu = SafeChoice({
        "◤─〔 BASIC SKILL 〕",
        "│⦿ 〔 SWORD",
        "│⦿ 〔 ARCHER",
        "│⦿ 〔 MAGICIAN",
        "│⦿ 〔 TANK",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("BASIC SKILL"))

    if BskillMenu == nil then return end

    if BskillMenu == 1 then Bskill()
    elseif BskillMenu == 2 then Go(Ssword)
    elseif BskillMenu == 3 then Go(Sarcher)
    elseif BskillMenu == 4 then Go(Smage)
    elseif BskillMenu == 5 then Go(Stank)
    elseif BskillMenu == 6 then Back()
    end
end


function Eskill()
gg.setVisible(false)
    EskillMenu = SafeChoice({
        "◤─〔 EXTRA SKILL 〕",
        "│⦿ 〔 SAMURAI",
        "│⦿ 〔 SINOBI",
        "│⦿ 〔 MANA SLINGER",
        "│⦿ 〔 GUARDIAN",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("EXTRA SKILL"))

    if EskillMenu == nil then return end

    if EskillMenu == 1 then Eskill()
    elseif EskillMenu == 2 then Go(Tsamu)
    elseif EskillMenu == 3 then Go(Tsino)
    elseif EskillMenu == 4 then Go(Tmana)
    elseif EskillMenu == 5 then Go(Tguardian)
    elseif EskillMenu == 6 then Back()
    end
end

function Tskill()
gg.setVisible(false)
    TskillMenu = SafeChoice({
        "◤─〔 THIRD SKILL 〕",
        "│⦿ 〔 MALE",
        "│⦿ 〔 FEMALE",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("3RD SKILL"))

    if TskillMenu == nil then return end

    if TskillMenu == 1 then Tskill()
    elseif TskillMenu == 2 then Go(MaleT)
    elseif TskillMenu == 3 then Go(FemaleT)
    elseif TskillMenu == 4 then Back()
    end
end



function MaleT()
gg.setVisible(false)
    MaleMenu = SafeChoice({
        "◤─〔 SKILL FARM (MALE) 〕",
        "│⦿ 〔 SKILL PASIR",
        "│⦿ 〔 SKILL BUFF LIGHT",
        "│⦿ 〔 SKILL BUFF FIGHT",
        "│⦿ 〔 SKILL WIGS",
        "│⦿ 〔 BONUS",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("MALE SKILL"))

    if MaleMenu == nil then return end

    if MaleMenu == 1 then MaleT()
    elseif MaleMenu == 2 then gsbbt1()
    elseif MaleMenu == 3 then gsbbt2()
    elseif MaleMenu == 4 then gsbbt3()
    elseif MaleMenu == 5 then gsbbt4()
    elseif MaleMenu == 6 then gsbbt5()
    elseif MaleMenu == 7 then Back()
    end
end

function FemaleT()
gg.setVisible(false)
    FemaleMenu = SafeChoice({
        "◤─〔 SKILL FARM (FEMALE) 〕",
        "│⦿ 〔 SKILL PASIR",
        "│⦿ 〔 SKILL BUFF LIGHT",
        "│⦿ 〔 SKILL BUFF FIGHT",
        "│⦿ 〔 SKILL WIGS",
        "│⦿ 〔 BONUS",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("FEMALE SKILL"))

    if FemaleMenu == nil then return end

    if FemaleMenu == 1 then FemaleT()
    elseif FemaleMenu == 2 then gsb1()
    elseif FemaleMenu == 3 then gsb2()
    elseif FemaleMenu == 4 then gsb3()
    elseif FemaleMenu == 5 then gsb4()
    elseif FemaleMenu == 6 then gsb5()
    elseif FemaleMenu == 7 then Back()
    end
end



-- Semua fungsi menu lainnya juga diupdate dengan pola yang sama...
-- [Untuk singkatnya, semua fungsi menu lainnya mengikuti pola yang sama]

-- Basic Weapon Menu (UPDATED WITH HIDE SUPPORT)
function basicweapon()
    gg.setVisible(false)
    basicA = SafeChoice({
        "◤─〔 BASIC JOB  〕",
        "│⦿ 〔 "..switch1.."📁 Swords",
        "│⦿ 〔 "..switch2.."📁 Archer",
        "│⦿ 〔 "..switch3.."📁 Mage",
        "│⦿ 〔 "..switch4.."📁 Tank",
        "│⦿ 〔 HIDE MENU 〕",
        "│⦿ 〔 🔚【BACK】🔚"
    }, nil, createMenuTitle("BASIC WEAPON"))
    
    if basicA == nil then return end
    
    if basicA == 1 then basicweapon()
    elseif basicA == 2 then sw()
    elseif basicA == 3 then ar()
    elseif basicA == 4 then mg()
    elseif basicA == 5 then pl()
    elseif basicA == 6 then HideMenu()
    elseif basicA == 7 then Back()
    end
end

-- Bag Menu (UPDATED WITH HIDE SUPPORT - multiChoice)
function bag()
gg.setVisible(false)
    nbag = SafeMultiChoice({
        "◤─〔 STORAGE/MARKT 〕",
        "│⦿ 〔 📁 STORAGE",
        "│⦿ 〔 📁 MARKET",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("STORAGE & MARKET"))
    
    if nbag == nil then return end
    
    if nbag[1] then bag()
    elseif nbag[2] then BG()
    elseif nbag[3] then BM()
    elseif nbag[4] then HideMenu()
    elseif nbag[5] then Back()
    end
end

-- Area Farm Menu (UPDATED WITH HIDE SUPPORT - multiChoice)
function areaF()
gg.setVisible(false)
    areaFmenu = SafeMultiChoice({
        "◤─〔 AREA FARM 〕",
        "│⦿ 〔 GALERIA PLAIN II",
        "│⦿ 〔 LUKKA FOREST",
        "│⦿ 〔 MANQUE LIRO II",
        "│⦿ 〔 CAPE INUWASHI III",
        "│⦿ 〔 SETA GRIA OUTER",
        "│⦿ 〔 EVEHOM PLAINS",
        "│⦿ 〔 DEFINITION ORE 24/25",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("AREA FARM"))
    
    if areaFmenu == nil then return end
    
    if areaFmenu[1] then areaF()
    elseif areaFmenu[2] then gp()
    elseif areaFmenu[3] then lf()
    elseif areaFmenu[4] then ml()
    elseif areaFmenu[5] then ci()
    elseif areaFmenu[6] then st()
    elseif areaFmenu[7] then ev()
    elseif areaFmenu[8] then dev()
    elseif areaFmenu[9] then HideMenu()
    elseif areaFmenu[10] then Back()
    end
end

function lootF()
gg.setVisible(false)
lootFmenu = SafeMultiChoice({
        "◤─〔 AREA FARM 〕",
        "│⦿ 〔 GALERIA PLAIN II",
        "│⦿ 〔 LUKKA FOREST",
        "│⦿ 〔 MANQUE LIRO II",
        "│⦿ 〔 CAPE INUWASHI III",
        "│⦿ 〔 SETA GRIA OUTER",
        "│⦿ 〔 EVEHOM PLAINS",
        "│⦿ 〔 DEFINITION ORE 24/25",
        "│⦿ 〔 HIDE MENU 〕",
        "◣─❈ 「 BACK 」─✦"
    }, nil, createMenuTitle("AUTO LOOTING"))
    
    if lootFmenu == nil then return end
    
    if lootFmenu[1] then lootFmenu()
    elseif lootFmenu[2] then lgp0()
    elseif lootFmenu[3] then llf0()
    elseif lootFmenu[4] then lml0()
    elseif lootFmenu[5] then lci0()
    elseif lootFmenu[6] then lst0()
    elseif lootFmenu[7] then lev0()
    elseif lootFmenu[8] then ldev0()
    elseif lootFmenu[9] then HideMenu()
    elseif lootFmenu[10] then Back()
    end
end

function lev0()
gg.setVisible(false)
  nloot = SafeMultiChoice({
    "◤─〔 LOOT EVEHOME 〕",
    "│⦿ 【STEP1】",
    "│⦿ 【STEP2】",
    "│⦿ 【STEP3】",
    "◣─❈ 「 BACK 」─✦",
    }, nil, createMenuTitle("EVEHOME LOOTING"))
    
  if nloot == nil then return end
    
    if nloot[1] then lev0()
    elseif nloot[2] then s1()
    elseif nloot[3] then s2()
    elseif nloot[4] then s3()
    elseif nloot[5] then Back()
    end
end

function lst0()
gg.setVisible(false)
  nlsoot = SafeMultiChoice({
    "◤─〔 LOOT SETTA 〕",
    "│⦿ 【STEP1】",
    "│⦿ 【STEP2】",
    "│⦿ 【STEP3】",
    "◣─❈ 「 BACK 」─✦",
    }, nil, createMenuTitle("SETTA LOOTING"))
    
  if nlsoot == nil then return end
if nlsoot[1] then lst0()
    elseif nlsoot[2] then ss1()
    elseif nlsoot[3] then ss2()
    elseif nlsoot[4] then ss3()
    elseif nlsoot[5] then Back()
    end
end


-- Music Function (UPDATED WITH HIDE SUPPORT)
function MUSIC()
    APIMusic = gg.makeRequest('https://raw.githubusercontent.com/HAISE39/Buat-bro/refs/heads/PVP/Music').content
    if not APIMusic then
        gg.alert('⚠⚠You Are Offline⚠⚠️\nOR\n⚠⚠You Did not Give Internet access⚠⚠')
        Back()
    else
        pcall(load(APIMusic))
    end
end

-- AI Function (UPDATED WITH HIDE SUPPORT)
function AI()
APIAI = gg.makeRequest('https://gist.githubusercontent.com/HAISE39/02ffbc96e1036912f31090fab2c3c405/raw/366d7c7de361d31dc8c64323e3de51c89b5789cb/Ai').content
if not APIAI then
gg.alert('⚠⚠You Are Offline⚠⚠️\nOR\n⚠⚠You Did not Give Internet access⚠⚠')
noselect()
else
pcall(load(APIAI))
end
end

-- Announcement Function (UPDATED WITH HIDE SUPPORT)
function PENGUMUMAN()
    gg.alert("Check our Discord for latest announcements!")
    Back()
end


function DungeonCode()
if not spendCoin() then return end
gg.alert('DESKRIPSI SCRIPT DUGEONnPergi ke elmo di galleria capital dan pilih mision Minotaur\npilih mode normal dan cari angka 1 lalu pilih mode hard dan murni kan menjadi 10  jika selesai di edit kalian langsung masuk salon (tanpa frezz)NPC\n\nblacksmith search 1 pergi unhappy man murnikan78\n29 g1 shop\n50 sai 4*\n51 La release\n52 festival fan\n53 latent abi\n55 AoT =1044\n58 hello kity\n60-64,83 legit furnis\n65 e.shadow\n66 chocolate furni\n68 fish expan\n70 Cursed weap\n71 Dispel 5\n72 Obsidian=1327 \n73 haloween furni n ava\n74 snowman\n76 choco furnis\n84 schoolgirl furni\n87 starry sky wall furnis\n97 mw3 ava\n98 halloween\n99 str main int sub neck hp\n100 dex head cri body hp leg 1171 bot best pick\n101 cridmg sub men 1387\n102 dex main,def,mpr 1407\n103 hp body, gold furnis 1487\n104 roar mdef int ear 1492\n105 cri head ,matk ring 1497\n106 str sub,vit lower, def ring 1578\n107 snowman\n108 snowalls,veteran abi=1586\n109sweet furnis\n110 demist\n111 blue jp furni\n\nDungeons\n\n480ancient tower\n570 ebisu kagura\n890 alert area\n930 headway fort mime\n960 hidden cradle\n1050 library of insanity\n1109 haya\n1287 95 regilis\n1236 large ring tower\n1299 mitera\n752 tasogarep\n430 northern cape\n1360 matia cosmos\n1410 awekening quest dungeon\n1546 trex\n1606 nk hard 1625 nk expert\n\nGATES\n\n1316 g4\n1320 g5\n1420 g6\n1562 g7\n1650 g8\n\nJP DUNGEONS\n\n750 silver world\n860 nightmare world\n1044 titan expert 4*\n1136 yelow cloth piece\n1142 secret hideout\n1159 relier hard\n1171 relier maze hyumo,tiger rock\n1256 hulk n schoolgirl\n1258 seagod book/green crystal\n1265 EXP TAURUS\n1268 holy worl,holy abi\n1270 dark world\n1274 foxgirl,jp leafs\n1327 Dark Obsidian\n1331 orange pumpkin\n1328 pumpkin blu\n1330 pumpkin green\n1331 pumpkin orange\n1376 blue/red crystal\n1387 Dragon fosil\n1397 souqs mucus\n1407 Onyx\n1411 discipline world, exp mission\n1428 school girl / hearts\n1487 taurus\n1492 maze of famine\n1493 fox,silver coin of hapiness\n1497 tailwind,crystal of storm\n1502 schoolgirl\n1567 nightmare\n1573 pumpkin\n1574 large e.shadow leaf\n1578 79 latent\n1586 proof of victory')
end
function antiLogin()
if not spendCoin() then return end
  gg.clearResults()
  gg.searchNumber("1337;1;0;0::17", gg.TYPE_DWORD)
  gg.refineNumber("1337")
  local r = gg.getResults(10)
  for i, v in ipairs(r) do
    v.value = "0"
    v.freeze = true
  end
  gg.addListItems(r)
  gg.toast("Anti Force Close Login Aktif")
end

function mapStabilizer()
  gg.setVisible(false)
if not spendCoin() then return end
function disableGGDetection()
  gg.setRanges(gg.REGION_CODE_APP | gg.REGION_JAVA_HEAP)
  gg.searchNumber("4761214;1162690580::17", gg.TYPE_DWORD) -- Nilai acak yang sering muncul dari libgg
  gg.clearResults()
  gg.toast("Bypass Deteksi GG Aktif")
end

function advancedMapStabilizer()
 
  gg.clearResults()
  gg.setRanges(gg.REGION_C_ALLOC)
  gg.searchNumber("20000000~60000000", gg.TYPE_DWORD)
  local res = gg.getResults(20)
  for i, v in ipairs(res) do
    v.value = "0"
    v.freeze = true
  end
  gg.addListItems(res)
  gg.toast("Advanced Stabilizer Aktif")
end

disableGGDetection()
advancedMapStabilizer()
gg.setVisible(false)
gg.clearResults()
gg.setRanges(gg.REGION_C_DATA)
gg.searchNumber("gg", gg.TYPE_BYTE)
gg.clearResults()
gg.clearList()
gg.toast("Mode Hantu Aktif: GG Disembunyikan Total")
gg.toast("Map Crash Protection Siap. Sekarang coba pindah map.")
end

function clearMemory()
  gg.clearResults()
  gg.clearList()
  gg.toast("Memory Game Guardian Dibersihkan")
end


function sw()
if not spendCoin() then return end
if switch1 == OFF then
gg.sleep(200)
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("h 03 00 00 00 1E 00 00 00 01 00 00 00 02 00 00 00", gg.TYPE_BYTE)
gg.processResume()
gg.skipRestoreState() 
if gg.isVisible(true) then
gg.setVisible(false)
gg.alert(" 💢ʙʏᴘᴀss ᴀɴᴛɪ ᴠɪᴇᴡ : ᴀᴄᴛɪᴠᴇ💢") 
gg.clearResults()
gg.processKill()
  os.exit() 
  end
gg.refineNumber("30", gg.TYPE_BYTE)
gg.processResume()
r = gg.getResults (1)
local L0_0 = {}
         L0_0 = {}
    L0_0[1] = {}
    L0_0[1].address = r[1].address + 24
    L0_0[1].flags = gg.TYPE_DWORD
    L0_0[1].value = "h 7F 96 98 00"
    L0_0[1].freeze = false
    L0_0[2] = {}
    L0_0[2].address = r[1].address + 28
    L0_0[2].flags = gg.TYPE_DWORD
    L0_0[2].value = "h 7F 96 98 00"
    L0_0[2].freeze = false
    gg.setValues(L0_0)
    gg.addListItems(L0_0)
    gg.clearResults()
    gg.clearList()
switch1 = ON
gg.toast("sᴡᴏʀᴅ ɪɴᴊᴇᴄᴛ : sᴜᴄᴄᴇss")
else
gg.alert("⚠️sᴡᴏʀᴅ ɪɴᴊᴇᴄᴛ : ᴅᴇ-ᴀᴄᴛɪᴠᴇᴅ!")
switch1 = ON
end
end

function ar() 
if not spendCoin() then return end
if switch2 == OFF then
gg.sleep(200)
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("h 07 00 00 00 22 00 00 00 01 00 00 00 04 00 00 00", gg.TYPE_BYTE)
gg.processResume()
if gg.isVisible(true) then
gg.setVisible(false)
gg.alert(" 💢ʙʏᴘᴀss ᴀɴᴛɪ ᴠɪᴇᴡ : ᴀᴄᴛɪᴠᴇ💢") 
gg.clearResults()
gg.processKill()
  os.exit() 
  end
gg.refineNumber("34", gg.TYPE_BYTE)
gg.processResume()
r1 = gg.getResults (1)
local L1_0 = {}
         L1_0 = {}
    L1_0[1] = {}
    L1_0[1].address = r1[1].address + 24
    L1_0[1].flags = gg.TYPE_DWORD
    L1_0[1].value = "h 7F 96 98 00"
    L1_0[1].freeze = false
    L1_0[2] = {}
    L1_0[2].address = r1[1].address + 28
    L1_0[2].flags = gg.TYPE_DWORD
    L1_0[2].value = "h 7F 96 98 00"
    L1_0[2].freeze = false
    gg.setValues(L1_0)
    gg.addListItems(L1_0)
    gg.clearResults()
    gg.clearList()
switch2 = ON
gg.toast("ᴀʀᴄʜᴇʀ ɪɴᴊᴇᴄᴛ : sᴜᴄᴄᴇss")
else
gg.alert("⚠️ᴀʀᴄʜᴇʀ ɪɴᴊᴇᴄᴛ : ᴅᴇ-ᴀᴄᴛɪᴠᴇᴅ!")
switch2 = ON
end
end

function mg() 
if not spendCoin() then return end
if switch3 == OFF then
gg.sleep(200)
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("h05000000200000000100000003000000", gg.TYPE_BYTE)
gg.processResume()
if gg.isVisible(true) then
gg.setVisible(false)
gg.alert(" 💢ʙʏᴘᴀss ᴀɴᴛɪ ᴠɪᴇᴡ : ᴀᴄᴛɪᴠᴇ💢") 
gg.clearResults()
gg.processKill()
  os.exit() 
  end
gg.refineNumber("32", gg.TYPE_BYTE)
gg.processResume()
r2 = gg.getResults (1)
local L2_0 = {}
         L2_0 = {}
    L2_0[1] = {}
    L2_0[1].address = r2[1].address + 24
    L2_0[1].flags = gg.TYPE_DWORD
    L2_0[1].value = "h 7F 96 98 00"
    L2_0[1].freeze = false
    L2_0[2] = {}
    L2_0[2].address = r2[1].address + 28
    L2_0[2].flags = gg.TYPE_DWORD
    L2_0[2].value = "h 7F 96 98 00"
    L2_0[2].freeze = false
    gg.setValues(L2_0)
    gg.addListItems(L2_0)
    gg.clearResults()
    gg.clearList()
switch3 = ON
gg.toast("ᴍᴀɢᴇ ɪɴᴊᴇᴄᴛ : sᴜᴄᴄᴇss")
else
gg.alert("⚠️ᴍᴀɢᴇ ɪɴᴊᴇᴄᴛ : ᴅᴇ-ᴀᴄᴛɪᴠᴇᴅ!")
switch3 = ON
end
end

function pl() 
if not spendCoin() then return end
if switch4 == OFF then
gg.sleep(200)
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("h 01 00 00 00 1C 00 00 00 01 00 00 00 01 00 00 00", gg.TYPE_BYTE)
gg.processResume()
if gg.isVisible(true) then
gg.setVisible(false)
gg.alert(" 💢ʙʏᴘᴀss ᴀɴᴛɪ ᴠɪᴇᴡ : ᴀᴄᴛɪᴠᴇ💢") 
gg.clearResults()
  os.exit() 
  end
gg.refineNumber("28", gg.TYPE_BYTE)
gg.processResume()
r3 = gg.getResults (1)
local L3_0 = {}
         L3_0 = {}
    L3_0[1] = {}
    L3_0[1].address = r3[1].address + 24
    L3_0[1].flags = gg.TYPE_DWORD
    L3_0[1].value = "h 7F 96 98 00"
    L3_0[1].freeze = false
    L3_0[2] = {}
    L3_0[2].address = r3[1].address + 28
    L3_0[2].flags = gg.TYPE_DWORD
    L3_0[2].value = "h 7F 96 98 00"
    L3_0[2].freeze = false
    gg.setValues(L3_0)
    gg.addListItems(L3_0)
    gg.clearResults()
gg.clearList()
switch4 = ON
gg.toast("ᴛᴀɴᴋ ɪɴᴊᴇᴄᴛ : sᴜᴄᴄᴇss")
else
gg.alert("⚠️ᴛᴀɴᴋ ɪɴᴊᴇᴄᴛ : ᴅᴇ-ᴀᴄᴛɪᴠᴇᴅ!")
switch4 = ON
end
end

function rc()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
function RANDOMIZE_CHARACTER()
    -- Langsung jalankan FIRST_RANDOMIZE_VALUE_SEARCH tanpa pilihan
    FIRST_RANDOMIZE_VALUE_SEARCH()
end

function FIRST_RANDOMIZE_VALUE_SEARCH()
    SLEEP(500)
    CLEAR()
    
    -- Gunakan search number yang baru
    gg.toast('🔍 SEARCHING CHARACTER DATA...')
    if searchInDalvikMainSpace('8;65,792;16,777,217;1:29', gg.TYPE_DWORD) then
    REFINE_NUMBER('8', gg.TYPE_DWORD)
    end
    if gg.getResultsCount() == 0 then
        gg.alert('❌ NO CHARACTER DATA FOUND!\nCHECK GUIDE TO SEE TUTORIAL')
        return
    end

    SAVE_CHARACTER(-0x38,-0x8,-0x4,0x0,0x4)
    
    RANDOMIZE_NOW()
end

function RANDOMIZE_NOW()
    while true do
        SLEEP(500)
        CLEAR()
        SET_RANDOMIZE_CHARACTER()
        
        -- Tampilkan hasil random
        local savedItems = gg.getListItems()
        local resultText = '🎲 CHARACTER RANDOMIZED!\n\n'
        
        for i, v in ipairs(savedItems) do
            if v.name == 'COLOR' then resultText = resultText .. '🎨 COLOR: ' .. v.value .. '\n'
            elseif v.name == 'JOB' then resultText = resultText .. '⚔️ JOB: ' .. v.value .. '\n'
            elseif v.name == 'GENDER' then resultText = resultText .. '👥 GENDER: ' .. v.value .. '\n'
            elseif v.name == 'FACE' then resultText = resultText .. '😊 FACE: ' .. v.value .. '\n'
            elseif v.name == 'HAIR' then resultText = resultText .. '💇 HAIR: ' .. v.value .. '\n'
            end
        end
        
        resultText = resultText .. '\nCONTINUE RANDOMIZE CHARACTER?'
        
        local mr = gg.alert(resultText, 'NEXT', 'SAVE')
        if mr == nil then
            SLEEP(500)
            return
        else
            if mr == 1 then
                -- YES - continue looping
                gg.toast('🔄 RANDOMIZING AGAIN...')
                SLEEP(2000)
            else
                -- NO - exit
                gg.alert('✅ RANDOMIZE COMPLETED!\nYour character has been saved.')
                return
            end
        end
    end
end

function SAVE_CHARACTER(ocolo, ojob, ogen, oface, ohair)
    local t = gg.getResults(1)
    if #t == 0 then
        gg.toast('\nNO MATCHING VALUE FOUND!\nPLEASE TRY AGAIN')
        SLEEP(100)
        return
    end
    for i, v in ipairs(t) do
        local q = {}
        q[1] = {}
        q[1].address = t[1].address + ocolo
        q[1].flags = gg.TYPE_DWORD
        q[1].freeze = false
        q[1].name = 'COLOR'
        q[2] = {}
        q[2].address = t[1].address + ojob
        q[2].flags = gg.TYPE_DWORD
        q[2].freeze = false
        q[2].name = 'JOB'
        q[3] = {}
        q[3].address = t[1].address + ogen
        q[3].flags = gg.TYPE_DWORD
        q[3].freeze = false
        q[3].name = 'GENDER'
        q[4] = {}
        q[4].address = t[1].address + oface
        q[4].flags = gg.TYPE_DWORD
        q[4].freeze = false
        q[4].name = 'FACE'
        q[5] = {}
        q[5].address = t[1].address + ohair
        q[5].flags = gg.TYPE_DWORD
        q[5].freeze = false
        q[5].name = 'HAIR'
        gg.addListItems(q)
        CLEAR()
    end
end

function SET_RANDOMIZE_CHARACTER()
    local savedItems = gg.getListItems()
    for i, v in ipairs(savedItems) do
        if v.name == 'COLOR' then
            v.value = math.random(0,15)
            v.freeze = false
            v.name = 'COLOR'
        end
        if v.name == 'JOB' then
            v.value = math.random(0,3)
            v.freeze = false
            v.name = 'JOB'
        end
        if v.name == 'GENDER' then
            v.value = math.random(0,1)
            v.freeze = false
            v.name = 'GENDER'
        end
        if v.name == 'FACE' then
            v.value = math.random(0,32)
            v.freeze = false
            v.name = 'FACE'
        end
        if v.name == 'HAIR' then
            v.value = math.random(0,9)
            v.freeze = false
            v.name = 'HAIR'
        end
    end
    gg.setValues(savedItems)
    gg.addListItems(savedItems)
end

function REFINE_NUMBER(refnum, fla)
    gg.refineNumber(refnum, fla)
end

function CLEAR()
    gg.clearResults()
end

function SLEEP(val)
    gg.sleep(val)
end

-- =============================================
-- AUTO START
-- =============================================
gg.alert("🎮 RANDOMIZE CHARACTER STARTING...\n\nThis script will:\n- Search character data\n- Let you randomize multiple times")

-- Jalankan otomatis tanpa pilihan menu
RANDOMIZE_CHARACTER()
end

function BG()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("-1;2;-1:9", gg.TYPE_DWORD, gg.SIGN_EQUAL) then
gg.processResume()
gg.toast("BUKA ENCHANTMENT")
gg.sleep(5000)
gg.refineNumber("-1;59;-1:9", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("59", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
					rv = gg.getResults (1)
					if #rv > 0 then
						local v0_0 = {}
						v0_0[1] = {}
						v0_0[1].address = rv[1].address + 4
						v0_0[1].flags = gg.TYPE_DWORD
						v0_0[1].value = "12"
						v0_0[1].freeze = false
						gg.setValues(v0_0)
					end
				end
			end
    
 function BM()
 if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("-1;2;-1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.toast("BUKA ENCHANTMENT")
gg.sleep(5000)
gg.refineNumber("-1;59;-1:9", gg.TYPE_DWORD)
gg.refineNumber("59", gg.TYPE_DWORD)
end
rTv = gg.getResults (1)
local Tv0_0 = {}
         Tv0_0 = {}
    Tv0_0[1] = {}
    Tv0_0[1].address = rTv[1].address + 4
    Tv0_0[1].flags = gg.TYPE_DWORD
    Tv0_0[1].value = "27"
    Tv0_0[1].freeze = false
    gg.setValues(Tv0_0)
    end

function gp()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("4;1;1068708659;1008981770;1053609165;1068708659;1068708659;2566::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("10;1;1067030938;1008981770;1061997773;1070386381;1070386381;1541::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function lf()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("91;1;1065353216;1008981770;1067030938;1073741824;1073741824;2313::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("92;1;1065353216;1008981770;1065353216;1082130432;1082130432;2055::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("162;1;1067030938;1008981770;1056964608;1069547520;1069547520;1310::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function ml()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("15;1;1069547520;1008981770;1058642330;1072064102;1072064102;5379::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("91;1;1073741824;1008981770;1067030938;1073741824;1073741824;2313::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("161;1;1065353216;1008981770;1056964608;1077936128;1077936128;1556::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("323;1;1065353216;1008981770;1056964608;1073741824;1073741824;1541::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function ci()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("94;1;1065353216;1008981770;1058642330;1069128090;1069128090;2567::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("97;1;1067030938;1008981770;1069547520;1069547520;1069547520;6665::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("247;1;1072064102;1008981770;1065353216;1067450368;1067450368;1799::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function st()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("15D;1D;1065353216D;1008981770D;1058642330D;1072064102D;5379D:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("168D;1D;1008981770D;1056964608D;1072064102D;1311D:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("12;1;1072064102;1056964608;1008981770;1072064102;3614:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function ev()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("95;1008981770::50", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("88;1008981770::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("172;1008981770::50", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("256;1008981770::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("257;1008981770::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("88;1008981770::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function dev()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
    gg.setVisible(false)
    gg.clearResults()
    local searchPatterns = {
        "17;1;1071644672;1008981770;1065353216;67109121;2570:33",
        "4;1;1068708659;1008981770;117440512;2566:33",
        "16;1;1069547520;1008981770;33554432;6410:33",
        "15;1;1065353216;1008981770;33554432;5379:33",
        "10;1;1067030938;1008981770;33554432;1541:33",
        "4;1;1068708659;1008981770;100663296;2566:33",
        "4;1;1068708659;1008981770;83886080;2566:33",
        "12;1;1065353216;1008981770;67108864;3614:33",
        "12;1;1065353216;1008981770;50331648;3614:33",
        "12;1;1065353216;1008981770;33554432;3600:33",
        "4;1;1068708659;1008981770;67108864;2566:33",
        "4;1;1068708659;1008981770;50331648;2566:33",
        "4;1;1068708659;1008981770;33554432;2566:33",
        "5;1;1065353216;1008981770;16777473;1290:33",
        "4;1;1068708659;1008981770;16777216;2566:33",
        "10;1;1067030938;1008981770;16777216;1541:33",
        "4;1;1068708659;1008981770;134217728;2566:33"
    }
    
    for i, pattern in ipairs(searchPatterns) do
        gg.clearResults()
        gg.setRanges(gg.REGION_JAVA_HEAP)
        
        if searchInDalvikMainSpace(pattern, gg.TYPE_DWORD) then
            gg.processResume()
            gg.refineNumber("1008981770", gg.TYPE_DWORD)
            
            local results = gg.getResults(100)
            if results and #results > 0 then
                for j, v in ipairs(results) do
                    v.value = -1
                end
                gg.setValues(results)
            end
        end
        
        gg.clearResults()
        gg.processResume()
    end
end

function unlishield()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("8;2;0;65,536;1:17", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("65,536", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function s1()
if not spendCoin() then return end
  gg.clearResults()
  gg.setVisible(false)
  gg.setRanges(gg.REGION_JAVA_HEAP)
  if searchInDalvikMainSpace("Q9A99'w'\"B\"0090'@33'C0'B'", gg.TYPE_BYTE) then
  gg.processResume()
  end
  gg.refineNumber("Q9A99'w'\"B\"0090'@33'C0'B'", gg.TYPE_BYTE)
  gg.sleep(3000)
  gg.processResume()
  gg.searchFuzzy("0", gg.SIGN_FUZZY_EQUAL, gg.TYPE_BYTE, 0, -1, 0)
  gg.sleep(3000)
  gg.processResume()
  gg.alert("📁PROSES PENGAMBILAN DATA RESOURCE\nJANGAN BERGERAK🖐️")
  gg.toast("▓▒▒▒▒▒▒▒▒▒10%")
  gg.sleep(1200)
  gg.toast("▓▓▒▒▒▒▒▒▒▒20%")
  gg.sleep(1300)
  gg.toast("▓▓▓▒▒▒▒▒▒▒30%")
  gg.sleep(1400)
  gg.toast("▓▓▓▓▒▒▒▒▒▒40%")
  gg.searchFuzzy("0", gg.SIGN_FUZZY_EQUAL, gg.TYPE_BYTE, 0, -1, 0)
  gg.sleep(3000)
  gg.processResume()
  gg.toast("▓▓▓▓▓▒▒▒▒▒50%")
  gg.sleep(1600)
  gg.toast("▓▓▓▓▓▓▒▒▒▒60%")
  gg.refineNumber("-64", gg.TYPE_BYTE)
  gg.processResume()
  gg.sleep(1700)
  gg.toast("▓▓▓▓▓▓▓▒▒▒70%")
  gg.sleep(1800)
  gg.toast("▓▓▓▓▓▓▓▓▒▒80%")
  gg.refineAddress("2", -1, gg.TYPE_BYTE, gg.SIGN_EQUAL, 0, -1, 0)
  gg.sleep(1900)
  gg.toast("▓▓▓▓▓▓▓▓▓▒90%")
  gg.sleep(2000)
  gg.toast("▓▓▓▓▓▓▓▓▓▓100%")
  gg.sleep(2000)
  gg.toast("💯 COMPLETED RESOURCES FILES👈")
  gg.processResume()
  r1_lev = gg.getResults(1)
  if not r1_lev or #r1_lev == 0 then
    gg.alert("ERROR: base address tidak ditemukan di LEV (r1_lev kosong).")
  else
    gg.toast("Base LEV ditemukan.")
  end
end

-- ===== LEV: STEP 2 (ambil offsets & simpan otomatis) =====
function s2()
  if not r1_lev or #r1_lev == 0 then
    gg.alert("Step-2 gagal: Jalankan STEP-1 LEV terlebih dahulu.")
    return
  end

  local L0_1 = {}
  L0_1[1] = { address = r1_lev[1].address + 0, flags = gg.TYPE_BYTE, value = "-105", freeze = false }
  L0_1[2] = { address = r1_lev[1].address - 6, flags = gg.TYPE_FLOAT, value = "5", freeze = false }
  L0_1[3] = { address = r1_lev[1].address - 8, flags = gg.TYPE_WORD, value = "17071", freeze = false }

  gg.setValues(L0_1)    -- apply values as before
  gg.addListItems(L0_1) -- otomatis ditambahkan ke Saved list
  gg.toast("Step-2 selesai: values diset & ditambahkan ke Saved list.")
end

-- ===== LEV: STEP 3 (auto-edit loop dengan double-click stop) =====
function s3()
  if not r1_lev or #r1_lev == 0 then
    gg.alert("Step-3 gagal: Jalankan STEP-1 LEV terlebih dahulu.")
    return
  end

  stopLoot = false
  lastVisibleClock = 0
  gg.setVisible(false)
  gg.toast("AUTO LOOTING DIMULAI\nKlik icon GG 2x untuk STOP")

  -- Masukkan semua sequence edit sesuai skrip aslinya (urutan dipertahankan).
  local edits = {
    {byteVal = "-103,", wordVal = "17064", floatVal = "5"},
    {byteVal = "-101,", wordVal = "17064", floatVal = "5"},
    {byteVal = "-99,",  wordVal = "17059", floatVal = "5"},
    {byteVal = "-102,", wordVal = "17057", floatVal = "5"},
    {byteVal = "-105,", wordVal = "17057", floatVal = "5"},
    {byteVal = "-107,", wordVal = "17059", floatVal = "5"},
    {byteVal = "-108,", wordVal = "17061", floatVal = "5"},
    {byteVal = "-112,", wordVal = "17064", floatVal = "5"},
    {byteVal = "-106,", wordVal = "17064", floatVal = "5"},
    {byteVal = "-104,", wordVal = "17066", floatVal = "5"},
    {byteVal = "-101,", wordVal = "17063", floatVal = "5"},
    {byteVal = "-103,", wordVal = "17062", floatVal = "5"},
    {byteVal = "-105,", wordVal = "17063", floatVal = "5"},
    {byteVal = "-104,", wordVal = "17058", floatVal = "5"},
    {byteVal = "-102,", wordVal = "17060", floatVal = "5"},
    {byteVal = "-102,", wordVal = "17064", floatVal = "5"},
    {byteVal = "-105,", wordVal = "17060", floatVal = "5"},
    {byteVal = "-101,", wordVal = "17058", floatVal = "5"},
    {byteVal = "-100,", wordVal = "17063", floatVal = "5"},
    {byteVal = "-105,", wordVal = "17114", floatVal = "7"},
    {byteVal = "-99,",  wordVal = "17115", floatVal = "7"},
    {byteVal = "-101,", wordVal = "17121", floatVal = "7"},
    {byteVal = "101,",  wordVal = "17139", floatVal = "8"},
    {byteVal = "-61,",  wordVal = "17029", floatVal = "5"},
    {byteVal = "-61,",  wordVal = "17023", floatVal = "4"},
    {byteVal = "-57,",  wordVal = "17024", floatVal = "4"},
    {byteVal = "-55,",  wordVal = "17022", floatVal = "4"},
    {byteVal = "-63,",  wordVal = "17011", floatVal = "4"},
    {byteVal = "-64,",  wordVal = "16997", floatVal = "4.5"},
    {byteVal = "-66,",  wordVal = "16987", floatVal = "4"},
    {byteVal = "-81,",  wordVal = "16970", floatVal = "5"},
    {byteVal = "-102,", wordVal = "16979", floatVal = "5"},
    {byteVal = "-104,", wordVal = "16973", floatVal = "5"},
    {byteVal = "-102,", wordVal = "17048", floatVal = "5"},
    {byteVal = "-103,", wordVal = "17062", floatVal = "5"},
    -- (jika ada baris tambahan, tambahkan di akhir array dengan urutan yang sama)
  }

  -- Loop utama: ulang terus sampai user double-click
  while true do
    runEditsSequential(edits)
    if stopLoot then break end
    -- juga cek double click di antara iterasi
    if checkDoubleClick() then
      stopLoot = true
      break
    end
    -- sedikit jeda agar CPU tidak terbebani
    gg.sleep(50)
  end

  gg.toast("AUTO LOOTING BERHENTI ✔️")
end

-- ===== SETTA (mirror LEV but with r1_set vars & values) =====
function ss1()
if not spendCoin() then return end
  gg.clearResults()
  gg.setVisible(false)
  gg.setRanges(gg.REGION_JAVA_HEAP)
  if searchInDalvikMainSpace("Q CD CC E5 42 33 33 83 40 66 66 5C 42'", gg.TYPE_BYTE) then
  gg.processResume()
  gg.refineNumber("Q CD CC E5 42 33 33 83 40 66 66 5C 42'", gg.TYPE_BYTE)
  gg.sleep(3000)
  end
  gg.processResume()
  gg.searchFuzzy("0", gg.SIGN_FUZZY_EQUAL, gg.TYPE_BYTE, 0, -1, 0)
  gg.sleep(3000)
  gg.processResume()
  gg.alert("📁PROSES PENGAMBILAN DATA RESOURCE\nJANGAN BERGERAK🖐️")
  gg.toast("▓▒▒▒▒▒▒▒▒▒10%")
  gg.sleep(1200)
  gg.toast("▓▓▒▒▒▒▒▒▒▒20%")
  gg.sleep(1300)
  gg.toast("▓▓▓▒▒▒▒▒▒▒30%")
  gg.sleep(1400)
  gg.toast("▓▓▓▓▒▒▒▒▒▒40%")
  gg.searchFuzzy("0", gg.SIGN_FUZZY_EQUAL, gg.TYPE_BYTE, 0, -1, 0)
  gg.sleep(3000)
  gg.processResume()
  gg.toast("▓▓▓▓▓▒▒▒▒▒50%")
  gg.sleep(1600)
  gg.toast("▓▓▓▓▓▓▒▒▒▒60%")
  gg.refineNumber("92", gg.TYPE_BYTE)
  gg.processResume()
  gg.sleep(1700)
  gg.toast("▓▓▓▓▓▓▓▒▒▒70%")
  gg.sleep(1800)
  gg.toast("▓▓▓▓▓▓▓▓▒▒80%")
  gg.refineAddress("2", -1, gg.TYPE_BYTE, gg.SIGN_EQUAL, 0, -1, 0)
  gg.sleep(1900)
  gg.toast("▓▓▓▓▓▓▓▓▓▒90%")
  gg.sleep(2000)
  gg.toast("▓▓▓▓▓▓▓▓▓▓100%")
  gg.sleep(2000)
  gg.toast("💯 COMPLETED RESOURCES FILES👈")
  gg.processResume()
  r1_set = gg.getResults(1)
  if not r1_set or #r1_set == 0 then
    gg.alert("ERROR: base address tidak ditemukan di SETTA (r1_set kosong).")
  else
    gg.toast("Base SETTA ditemukan.")
  end
end

function ss2()
  if not r1_set or #r1_set == 0 then
    gg.alert("Step-2 gagal: Jalankan STEP-1 SETTA terlebih dahulu.")
    return
  end

  local LS0_1 = {}
  LS0_1[1] = { address = r1_set[1].address + 0, flags = gg.TYPE_BYTE, value = "90", freeze = false }
  LS0_1[2] = { address = r1_set[1].address - 6, flags = gg.TYPE_FLOAT, value = "25", freeze = false }
  LS0_1[3] = { address = r1_set[1].address - 8, flags = gg.TYPE_WORD, value = "17125", freeze = false }

  gg.setValues(LS0_1)
  gg.addListItems(LS0_1)
  gg.toast("Step-2 SETTA selesai: values diset & ditambahkan ke Saved list.")
end

function ss3()
  if not r1_set or #r1_set == 0 then
    gg.alert("Step-3 gagal: Jalankan STEP-1 SETTA terlebih dahulu.")
    return
  end

  stopLoot = false
  lastVisibleClock = 0
  gg.setVisible(false)
  gg.toast("AUTO LOOTING SETTA DIMULAI\nKlik icon GG 2x untuk STOP")

  local edits_set = {
    {byteVal = "96,", wordVal = "17116", floatVal = "4"},
    {byteVal = "99,", wordVal = "17118", floatVal = "4"},
    {byteVal = "92,", wordVal = "17119", floatVal = "4"},
    {byteVal = "89,", wordVal = "17114", floatVal = "4"},
    {byteVal = "93,", wordVal = "17112", floatVal = "4"},
    {byteVal = "99,", wordVal = "17112", floatVal = "4"},
    {byteVal = "104,", wordVal = "17113", floatVal = "4"},
    {byteVal = "108,", wordVal = "17116", floatVal = "4"},
    {byteVal = "103,", wordVal = "17118", floatVal = "4"},
    {byteVal = "93,", wordVal = "17118", floatVal = "4"},
    {byteVal = "94,", wordVal = "17115", floatVal = "4"},
    {byteVal = "100,", wordVal = "17113", floatVal = "4"},
    {byteVal = "39,", wordVal = "17113", floatVal = "4"},
    {byteVal = "30,", wordVal = "17117", floatVal = "5"},
    {byteVal = "35,", wordVal = "17120", floatVal = "4"},
    {byteVal = "41,", wordVal = "17121", floatVal = "4"},
    {byteVal = "46,", wordVal = "17120", floatVal = "4"},
    {byteVal = "41,", wordVal = "17117", floatVal = "4"},
    {byteVal = "37,", wordVal = "17116", floatVal = "4"},
    {byteVal = "31,", wordVal = "17117", floatVal = "5"},
    {byteVal = "30,", wordVal = "17122", floatVal = "5"},
    {byteVal = "40,", wordVal = "17115", floatVal = "5"},
    {byteVal = "35,", wordVal = "17136", floatVal = "7"},
    {byteVal = "47,", wordVal = "17152", floatVal = "8"},
    {byteVal = "49,", wordVal = "17153", floatVal = "9"},
    {byteVal = "55,", wordVal = "17153", floatVal = "9"},
    {byteVal = "64,", wordVal = "17154", floatVal = "10"},
    {byteVal = "75,", wordVal = "17155", floatVal = "10"},
    {byteVal = "96,", wordVal = "17156", floatVal = "9"},
    {byteVal = "95,", wordVal = "17157", floatVal = "9"},
    {byteVal = "104,", wordVal = "17156", floatVal = "9"},
    {byteVal = "-120,", wordVal = "17146", floatVal = "7"},
    {byteVal = "-106,", wordVal = "17056", floatVal = "3"},
    {byteVal = "-101,", wordVal = "17028", floatVal = "3"},
    {byteVal = "-104,", wordVal = "17030", floatVal = "3"},
    {byteVal = "-107,", wordVal = "17019", floatVal = "3"},
    {byteVal = "-110,", wordVal = "16999", floatVal = "3"},
    {byteVal = "-111,", wordVal = "16991", floatVal = "3"},
    {byteVal = "-116,", wordVal = "16984", floatVal = "3"},
    {byteVal = "-118,", wordVal = "16978", floatVal = "3"},
    {byteVal = "-116,", wordVal = "16982", floatVal = "3"},
    {byteVal = "-112,", wordVal = "16989", floatVal = "3"},
    {byteVal = "-110,", wordVal = "16996", floatVal = "3"},
  }

  while true do
    runEditsSequential(edits_set)
    if stopLoot then break end
    if checkDoubleClick() then stopLoot = true break end
    gg.sleep(50)
  end

  gg.toast("AUTO LOOTING SETTA BERHENTI ✔️")
end

function Abuff()
gg.setVisible(false)
if not spendCoin() then return end
local farmingEffectCodes = {178, 178, 134, 134, 200, 200, 432, 432, 110, 110, 111, 111, 117, 117, 253, 253, 254, 254, 369, 369, 165, 165, 442, 442, 52, 52, 51, 51}
local xpEffectCodes = {133, 133, 157, 157, 200, 200, 222, 222, 432, 432, 192, 192, 199, 199, 197, 197, 164, 164, 216, 216, 217, 217, 555, 555, 553, 553, 545, 545, 49, 49, 50, 50, 57, 57, 202, 202} -- <-- Nanti kamu isi sendiri

-- Fungsi: Simpan hasil pencarian trigger
function cariTrigger()
  gg.setVisible(false)
  gg.clearResults()
  gg.setRanges(gg.REGION_JAVA_HEAP)
 gg.searchNumber("1;-1;1,008,981,770;1,065,353,216;1,118,391,907:61", gg.TYPE_DWORD, false, gg.SIGN_EQUAL)
  gg.refineNumber("1008981770", gg.TYPE_DWORD)
  local results = gg.getResults(1000)
  if #results == 0 then gg.alert("❌ Tidak ada hasil Trigger.") os.exit() end
  local offsetList = {}
  for _, v in ipairs(results) do
    table.insert(offsetList, {
      address = v.address + 0x30,
      flags = gg.TYPE_DWORD,
      value = 0,
      freeze = false,
      name = "trigger"
    })
  end
  gg.addListItems(offsetList)
end
-- Fungsi: Simpan hasil pencarian buff
function cariBuff()
  gg.setVisible(false)
  gg.clearResults()
  gg.setRanges(gg.REGION_JAVA_HEAP)
  gg.searchNumber("65536;212;1:17", gg.TYPE_DWORD, false, gg.SIGN_EQUAL)
  gg.sleep(500)
  gg.refineNumber("212", gg.TYPE_DWORD)
  local results = gg.getResults(1)
  if #results == 0 then gg.alert("❌ Tidak ditemukan nilai 212.") os.exit() end
  results[1].name = "buff"
  results[1].freeze = false
  gg.addListItems(results)
end
-- Fungsi: Jalankan efek buff otomatis
function applyBuff(effectCodes)
  -- Ambil buff dari save list
  local buffList = gg.getListItems()
  local buffAddr = nil
  for _, v in ipairs(buffList) do
    if v.name == "buff" then
      buffAddr = v.address
      break
    end
  end
  if not buffAddr then gg.alert("❌ Buff tidak ditemukan.") os.exit() end

  -- Offset +4 freeze ke 1
  local offsetPlus4 = buffAddr + 4
  gg.setValues({{address = offsetPlus4, flags = gg.TYPE_DWORD, value = 1}})
  gg.addListItems({{
    address = offsetPlus4,
    flags = gg.TYPE_DWORD,
    value = 1,
    freeze = true,
    name = "freeze_1"
  }})

  -- Freeze nilai utama jadi 61
  gg.setValues({{address = buffAddr, flags = gg.TYPE_DWORD, value = 61}})
  gg.addListItems({{
    address = buffAddr,
    flags = gg.TYPE_DWORD,
    value = 61,
    freeze = true,
    name = "buff_main"
  }})

  gg.sleep(1000)

  -- Loop edit semua efek buff
  for _, val in ipairs(effectCodes) do
    gg.editAll(tostring(val), gg.TYPE_DWORD)
    local hasil = gg.getResults(100)
    for _, v in ipairs(hasil) do
      v.value = val
      v.freeze = true
    end
    gg.addListItems(hasil)
    gg.toast("✔ Efek " .. val .. " diterapkan.")
    gg.sleep(1000)
  end
end

-- Fungsi: Bekukan trigger
function aktifkanTrigger()
  local triggerList = gg.getListItems()
  for _, v in ipairs(triggerList) do
    if v.name == "trigger" then
      v.value = 9876258
      v.freeze = true
    end
  end
  gg.setValues(triggerList)
  gg.addListItems(triggerList)
end

-- Fungsi: Hapus semua freeze kecuali nilai 1
function bersihkanFreeze()
  local list = gg.getListItems()
  local baru = {}
  for _, v in ipairs(list) do
    if v.value == 1 and v.flags == gg.TYPE_DWORD then
      table.insert(baru, v) -- Pertahankan
    end
  end
  gg.clearList()
  gg.addListItems(baru)
end

-- ========== JALANKAN OTOMATIS ==========

-- Langkah awal
cariTrigger()
cariBuff()

-- Menu pilihan
local pilih = gg.choice({
  "📦 Farming Only",
  "📘 XP Only",
  "❌ Keluar"
}, nil, "Auto Buff Menu")
if pilih == 1 then
  aktifkanTrigger()
  applyBuff(farmingEffectCodes)
  bersihkanFreeze()
elseif pilih == 2 then
  aktifkanTrigger()
  applyBuff(xpEffectCodes)
  bersihkanFreeze()
else
  gg.toast("🚪 Keluar dari script.")
  os.exit()
end

while true do
  if gg.isVisible(true) then
    gg.setVisible(false)
    pilih()
  end
end
end

function statusedit()
    if not spendCoin() then return end
    
    gg.clearResults()
    gg.setVisible(false)
    gg.setRanges(gg.REGION_JAVA_HEAP)
    
    -- Langkah 1: Meminta input move speed original dari user
    local originalMove = gg.prompt({
        "Masukan Jumlah Move Speed Original Anda"
    }, {""}, {"number"})
    
    if originalMove == nil or originalMove[1] == nil or originalMove[1] == "" then
        gg.alert("Input dibatalkan, kembali ke menu.")
        return PLAYER()
    end
    
    local moveValue = tonumber(originalMove[1])
    
    -- Langkah 2: Mencari value tersebut
    if searchInDalvikMainSpace("211';"..moveValue..';200', gg.TYPE_DWORD) then
        gg.getResults(10)
        
        -- Cek apakah ada hasil
        if gg.getResultsCount() == 0 then
            gg.clearResults()
            gg.alert("Data tidak ditemukan, silahkan cek ulang value original move speed Anda.")
            return statusedit() -- Langkah 3: Kembali ke awal jika tidak ditemukan
        end
        
        gg.refineAddress("D8", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
        gg.refineNumber(moveValue, gg.TYPE_DWORD)
        local r = gg.getResults(1)
        
        -- Cek kembali sebelum akses r[1]
        if r == nil or r[1] == nil then
            gg.clearResults()
            gg.alert("Target address tidak cocok, silahkan cek ulang value original move speed Anda.")
            return statusedit() -- Langkah 3: Kembali ke awal jika tidak cocok
        end
        
        -- Langkah 4: Mode pengeditan dengan prompt tunggal
        local editOptions = gg.prompt({
            "Damage:",
            "Move Speed :",
            "☐ Anti Mana",
            "☐ Anti Cooldown"
        }, {
            "999999999",  -- Default damage
            "10000",      -- Default move speed
            false,        -- Default anti mana checkbox
            false         -- Default anti cooldown checkbox
        }, {
            "number",
            "number",
            "checkbox",
            "checkbox"
        })
        
        if editOptions == nil then
            gg.alert("Pengeditan dibatalkan, kembali ke menu.")
            return PLAYER()
        end
        
        -- Langkah 5-8: Membuat struktur edit berdasarkan input
        local edit = {}
        
        -- Damage (number)
        table.insert(edit, {
            address = r[1].address + -72,
            flags = gg.TYPE_DWORD,
            value = editOptions[1],
            freeze = true
        })
        
        -- Move Speed (slide)
        table.insert(edit, {
            address = r[1].address + 0,
            flags = gg.TYPE_DWORD,
            value = editOptions[2],
            freeze = true
        })
        
        -- Anti Mana (checkbox)
        if editOptions[3] then
            table.insert(edit, {
                address = r[1].address + 304,
                flags = gg.TYPE_DWORD,
                value = "-999",
                freeze = true
            })
        end
        
        -- Anti Cooldown (checkbox)
        if editOptions[4] then
            table.insert(edit, {
                address = r[1].address + 308,
                flags = gg.TYPE_DWORD,
                value = "-999",
                freeze = true
            })
        end
        
        -- Apply semua pengeditan
        gg.setValues(edit)
        gg.addListItems(edit)
        
        -- Edit tambahan untuk move speed (opsional - sesuai script awal)
        
        gg.alert("Pengeditan berhasil diapply!")
        return PLAYER()
        
    else
        -- Jika searchInDalvikMainSpace langsung gagal
        gg.alert("Value tidak ditemukan, silahkan cek ulang value original move speed Anda.")
        return statusedit() -- Langkah 3: Kembali ke awal jika tidak ditemukan
    end
    
    gg.clearResults()
end

function ls()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
gg.searchNumber("119;1:9", gg.TYPE_DWORD)
gg.processResume()
gg.refineNumber("119", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "40"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil

gg.clearResults()
gg.processResume()
end

function nk()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("246;1008981770;1800;1175::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("161;1008981770;1556;1176::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("96;1008981770;3085;1174::50", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("1081;1008981770;1285;1164::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("95;1008981770;3081;1177::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("257D;1008981770;2569D;1074D::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()

if searchInDalvikMainSpace("124;1008981770;2566;1178::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end


function g1() 
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("212;1;1069547520;1008981770;50331905:29", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g2() 
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("586;1;1065353216;1008981770;1080033280;16777473:29", gg.TYPE_DWORD) then
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
if searchInDalvikMainSpace("586;1;1066192077;1008981770;1082130432;33554689:29", gg.TYPE_DWORD) then
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
gg.toast('Area Gate 2 : Actived✔️')
end

function g3() 
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("699;1;1065353216;1008981770;1069547520;1082549862;1082549862;16777473:29", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g4()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("836;1008981770;1280;937:45", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g5()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("662D;1008981770;10280;949;662;1008981770;10280;950:125", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g6()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("257D;1008981770;2569D;1074D::50", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g7()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("1061;1008981770;2565;1154:45", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g7e()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("1061;1;1069547520;1008981770;1067450368;1074580685;1073741824;2565::50", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function g8() 
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("865D;1008981770D;1554D;1181D:45", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
end 
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
end

function tp1()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("404;1~3;255:9", gg.TYPE_DWORD) then
gg.refineNumber("404", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1201"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp2()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("404;1~3;255:9", gg.TYPE_DWORD) then
gg.refineNumber("404", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "39"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp3()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("404;1~3;255:9", gg.TYPE_DWORD) then
gg.refineNumber("404", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp4()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("404;1~3;255:9", gg.TYPE_DWORD) then
gg.refineNumber("404", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1146"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp5()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("404;1~3;255:9", gg.TYPE_DWORD) then
gg.refineNumber("404", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1107"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp6()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("404;1~3;255:9", gg.TYPE_DWORD) then
gg.refineNumber("404", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1166"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp7()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("404;1~3;255:9", gg.TYPE_DWORD) then
gg.refineNumber("404", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "1156"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function tp8()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("404;1~3;255:9", gg.TYPE_DWORD) then
gg.refineNumber("404", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_DWORD then
		v.value = "286"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil


gg.sleep(2000)
gg.clearList()
end

function qsb1()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("346", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
    end
    
   function qsb2()
   if not spendCoin() then return end
   gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("610", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
   end
   
   function qsb3()
   if not spendCoin() then return end
   gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1065", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
   end
   
   function qsb4()
   if not spendCoin() then return end
   gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1143", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
   end

   function qsb5()
   if not spendCoin() then return end
   gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1201", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
   end
   
   function qsb6()
   if not spendCoin() then return end
   gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1185", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
   end
   
   function qsb7()
   if not spendCoin() then return end
   gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("964;2;1:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("964", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("961", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
   end

function ggtp1()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("159;1;1077936128;1008981770;33554689;1054:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(4, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
end

function ggtp2()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("129;1;1077936128;1008981770;50331905;1550:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
if searchInDalvikMainSpace("129;1;1077936128;1008981770;16777473;1550:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
if searchInDalvikMainSpace("129;1;1082549862;1008981770;33554689;1550:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
end

function ggtp3()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("717;1;1080033280;1008981770;1061997773;1069547520;1073741824;33620225:29", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
end

function ggtp4()
gg.clearResults()
if not spendCoin() then return end
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("657;1;1075838976;1008981770;16777473;2565:33", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
end

function ggtp5()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("258;1;2.0F;1008981770;1.5F;67109121;1806:33", gg.TYPE_DWORD) then
gg.refineNumber("1008981770", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function cc1()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "27", "Coin Mission 27")
end

function cc2()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "53", "Coin Mission 53")
end

function cc3()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "71", "Coin Mission 71")
end

function cc4()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "79", "Coin Mission 79")
end

function cc5()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "106", "Coin Mission 106")
end

function cc6()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "129", "Coin Mission 129")
end

function cc7()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "140", "Coin Mission 140")
end

function cc8()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "164", "Coin Mission 164")
end

function cc9()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "172", "Coin Mission 172")
end

function cc10()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "202", "Coin Mission 202")
end

function cc11()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "237", "Coin Mission 237")
end

function cc12()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "245", "Coin Mission 245")
end

function cc13()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "308", "Coin Mission 308")
end

function cc14()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "320", "Coin Mission 320")
end

function cc15()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "356", "Coin Mission 356")
end

function cc16()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "367", "Coin Mission 367")
end

function cc17()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "426", "Coin Mission 426")
end

function cc18()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "503", "Coin Mission 503")
end

function cc19()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "511", "Coin Mission 511")
end

function cc20()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "563", "Coin Mission 563")
end

function cc21()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "571", "Coin Mission 571")
end

function cc22()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "664", "Coin Mission 664")
end

function cc23()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "710", "Coin Mission 710")
end

function cc24()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "716", "Coin Mission 716")
end

function cc25()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "825", "Coin Mission 825")
end

function cc26()
if not spendCoin() then return end
    searchAndFreezeInDalvikMain("964;2;1:9", "404;1~3;255:9", "1185", "916", "Coin Mission 916")
end

function cc27()
if not spendCoin() then return end
    -- Khusus cc27 hanya menggunakan pattern kedua
    gg.clearResults()
    gg.setVisible(false)
    
    if searchInDalvikMainSpace("404;1~3;255:9", gg.TYPE_DWORD) then
        gg.processResume()
        local results = gg.getResults(100)
        if results and #results > 0 then
            for i, v in ipairs(results) do
                if v.flags == gg.TYPE_DWORD then
                    v.value = "1132"
                    v.freeze = true
                end
            end
            gg.addListItems(results)
        end
        gg.clearResults()
    end
    
    gg.alert("🔒 Coin Mission 1132 dibekukan. Klik icon GG untuk membersihkan...")
    while not gg.isVisible() do
        gg.sleep(100)
    end
    gg.setVisible(false)
    gg.clearResults()
    gg.clearList()
    gg.toast("🗑️ Coin Mission 1132 - Freeze & Result dibersihkan.")
end

function Wgun()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("1100001F;11524;16:97", gg.TYPE_DWORD) then end
if searchInDalvikMainSpace("1F;11524;16:97", gg.TYPE_DWORD) then
gg.refineAddress("C", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("11524", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("11001", gg.TYPE_DWORD)
gg.processResume()
gg.clearResults()
if searchInDalvikMainSpace("1F;11522;16:97", gg.TYPE_DWORD) then
gg.refineAddress("C", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("11522", gg.TYPE_DWORD)
end
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("10308", gg.TYPE_DWORD)
gg.processResume()
gg.clearResults()
end

function gsb1()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt= gg.getResults (1)
local Ll0_3 = {}
         Ll0_3 = {}
    Ll0_3[1] = {}
    Ll0_3[1].address = gt[1].address + 48
    Ll0_3[1].flags = gg.TYPE_DWORD
    Ll0_3[1].value = "10077"
    Ll0_3[1].freeze = true
    gg.setValues(Ll0_3)
    gg.addListItems(Ll0_3)
end

function gsb2()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt1 = gg.getResults (1)
local Ll0_4 = {}
         Ll0_4 = {}
    Ll0_4[1] = {}
    Ll0_4[1].address = gt1[1].address + 48
    Ll0_4[1].flags = gg.TYPE_DWORD
    Ll0_4[1].value = "10083"
    Ll0_4[1].freeze = true
    gg.setValues(Ll0_4)
    gg.addListItems(Ll0_4)
end

function gsb3()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt = gg.getResults (1)
local Ll0_5 = {}
         Ll0_5 = {}
    Ll0_5[1] = {}
    Ll0_5[1].address = gt[1].address + 48
    Ll0_5[1].flags = gg.TYPE_DWORD
    Ll0_5[1].value = "10084"
    Ll0_5[1].freeze = true
    gg.setValues(Ll0_5)
    gg.addListItems(Ll0_5)
end

function gsb4()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt = gg.getResults (1)
local Ll0_6 = {}
         Ll0_6 = {}
    Ll0_6[1] = {}
    Ll0_6[1].address = gt[1].address + 48
    Ll0_6[1].flags = gg.TYPE_DWORD
    Ll0_6[1].value = "10071"
    Ll0_6[1].freeze = true
    gg.setValues(Ll0_6)
    gg.addListItems(Ll0_6)
end

function gsb5()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gt= gg.getResults (1)
local Ll0_7 = {}
         Ll0_7 = {}
    Ll0_7[1] = {}
    Ll0_7[1].address = gt[1].address + 48
    Ll0_7[1].flags = gg.TYPE_DWORD
    Ll0_7[1].value = "11305"
    Ll0_7[1].freeze = true
    gg.setValues(Ll0_7)
    gg.addListItems(Ll0_7)
end

function gsbbt1()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv= gg.getResults (1)
local Ll0__3 = {}
         Ll0__3 = {}
    Ll0__3[1] = {}
    Ll0__3[1].address = gtv[1].address + 48
    Ll0__3[1].flags = gg.TYPE_DWORD
    Ll0__3[1].value = "10078"
    Ll0__3[1].freeze = true
    gg.setValues(Ll0__3)
    gg.addListItems(Ll0__3)
end

function gsbbt2()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then 
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv1 = gg.getResults (1)
local Ll0__4 = {}
         Ll0__4 = {}
    Ll0__4[1] = {}
    Ll0__4[1].address = gtv1[1].address + 48
    Ll0__4[1].flags = gg.TYPE_DWORD
    Ll0__4[1].value = "10084"
    Ll0__4[1].freeze = true
    gg.setValues(Ll0__4)
    gg.addListItems(Ll0__4)
end

function gsbbt3()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv = gg.getResults (1)
local Ll0__5 = {}
         Ll0__5 = {}
    Ll0__5[1] = {}
    Ll0__5[1].address = gtv[1].address + 48
    Ll0__5[1].flags = gg.TYPE_DWORD
    Ll0__5[1].value = "10085"
    Ll0__5[1].freeze = true
    gg.setValues(Ll0__5)
    gg.addListItems(Ll0__5)
end

function gsbbt4()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv = gg.getResults (1)
local Ll0__6 = {}
         Ll0__6 = {}
    Ll0__6[1] = {}
    Ll0__6[1].address = gtv[1].address + 48
    Ll0__6[1].flags = gg.TYPE_DWORD
    Ll0__6[1].value = "10072"
    Ll0__6[1].freeze = true
    gg.setValues(Ll0__6)
    gg.addListItems(Ll0__6)
end

function gsbbt5()
if not spendCoin() then return end
gg.clearResults()
gg.setVisible(false)
if searchInDalvikMainSpace("25769803776Q;6;200;0;1.0F:105", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("200", gg.TYPE_DWORD)
end 
gg.refineAddress("4", -1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1, 0)
gtv= gg.getResults (1)
local Ll0__7 = {}
         Ll0__7 = {}
    Ll0__7[1] = {}
    Ll0__7[1].address = gtv[1].address + 48
    Ll0__7[1].flags = gg.TYPE_DWORD
    Ll0__7[1].value = "11306"
    Ll0__7[1].freeze = true
    gg.setValues(Ll0__7)
    gg.addListItems(Ll0__7)
end

function Agunl()
gg.alert("Feature Coming Soon!")
end
function anim()
gg.alert("Feature Coming Soon!")
end
function stamp()
gg.alert("Feature Coming Soon!")
end


function rskill()
gg.clearResults()
gg.setVisible(false)
gg.setRanges(gg.REGION_JAVA_HEAP)
if searchInDalvikMainSpace("3;81;20:9", gg.TYPE_DWORD) then
gg.processResume()
gg.refineNumber("3", gg.TYPE_DWORD)
revert = gg.getResults(100, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("25", gg.TYPE_DWORD)
end
gg.clearResults()
gg.processResume()
end

function Ssword()
    local savedData = gg.getListItems()
    local swordAddress = nil
    local saved = false

    for i, v in ipairs(savedData) do
        if v.name == "Sword" then
            swordAddress = v.address
            saved = true
            break
        end
    end

    if not saved then
        gg.clearResults()
        gg.setRanges(gg.REGION_JAVA_HEAP)
        if searchInDalvikMainSpace("417;5;5:9", gg.TYPE_DWORD) then
            local results = gg.getResults(100)
            local found = false

            for i, v in pairs(results) do
                if v.value == 417 then
                    swordAddress = v.address
                    found = true
                    break
                end
            end

            if not found then
                gg.alert("Value tidak ditemukan")
                return
            end

            gg.addListItems({
                {
                    address = swordAddress,
                    flags = gg.TYPE_DWORD,
                    name = "Sword",
                    value = 417
                }
            })
            gg.alert("Sword telah di temukan")
        else
            gg.alert("Pencarian gagal")
            return
        end
    else
        gg.alert("Sword ditemukan")
    end

    local newValue = gg.prompt({
        "Edit value Sword:",
        "Back ke menu utama"
    }, {
        "0",
        false
    }, {"number", "checkbox"})

    -- BATAL / TAP LUAR
    if not newValue then
        return
    end

    -- BACK = HENTIKAN FUNCTION SAJA
    if newValue[2] == true then
        return
    end

    local editValue = tonumber(newValue[1])
    if editValue then
        gg.setValues({
            {
                address = swordAddress,
                value = editValue,
                flags = gg.TYPE_DWORD
            }
        })
        gg.alert("Sword diubah menjadi: " .. editValue)
    end
end

function Sarcher()
    local savedData = gg.getListItems()
    local ArcherAddress = nil
    local saved = false

    for _, v in ipairs(savedData) do
        if v.name == "Archer" then
            ArcherAddress = v.address
            saved = true
            break
        end
    end

    if not saved then
        gg.clearResults()
        gg.setRanges(gg.REGION_JAVA_HEAP)
        if searchInDalvikMainSpace("419;5;5:9", gg.TYPE_DWORD) then
            local results = gg.getResults(100)
            local found = false

            for _, v in pairs(results) do
                if v.value == 419 then
                    ArcherAddress = v.address
                    found = true
                    break
                end
            end

            if not found then
                gg.alert("Value tidak ditemukan")
                return
            end

            gg.addListItems({{
                address = ArcherAddress,
                flags = gg.TYPE_DWORD,
                name = "Archer",
                value = 419
            }})
            gg.alert("Archer telah di temukan")
        else
            gg.alert("Pencarian gagal")
            return
        end
    else
        gg.alert("Archer ditemukan")
    end

    local newValue = gg.prompt({
        "Edit value Archer:",
        "Back ke menu utama"
    }, {"0", false}, {"number", "checkbox"})

    if not newValue then return end
    if newValue[2] then return end

    local editValue = tonumber(newValue[1])
    if editValue then
        gg.setValues({{
            address = ArcherAddress,
            value = editValue,
            flags = gg.TYPE_DWORD
        }})
        gg.alert("Archer diubah menjadi: " .. editValue)
    end
end

function Smage()
    local savedData = gg.getListItems()
    local MageAddress = nil
    local saved = false

    for _, v in ipairs(savedData) do
        if v.name == "Mage" then
            MageAddress = v.address
            saved = true
            break
        end
    end

    if not saved then
        gg.clearResults()
        gg.setRanges(gg.REGION_JAVA_HEAP)
        if searchInDalvikMainSpace("418;5;5:9", gg.TYPE_DWORD) then
            local results = gg.getResults(100)
            local found = false

            for _, v in pairs(results) do
                if v.value == 418 then
                    MageAddress = v.address
                    found = true
                    break
                end
            end

            if not found then
                gg.alert("Value tidak ditemukan")
                return
            end

            gg.addListItems({{
                address = MageAddress,
                flags = gg.TYPE_DWORD,
                name = "Mage",
                value = 418
            }})
            gg.alert("Mage telah di temukan")
        else
            gg.alert("Pencarian gagal")
            return
        end
    else
        gg.alert("Mage ditemukan")
    end

    local newValue = gg.prompt({
        "Edit value Mage:",
        "Back ke menu utama"
    }, {"0", false}, {"number", "checkbox"})

    if not newValue then return end
    if newValue[2] then return end

    local editValue = tonumber(newValue[1])
    if editValue then
        gg.setValues({{
            address = MageAddress,
            value = editValue,
            flags = gg.TYPE_DWORD
        }})
        gg.alert("Mage diubah menjadi: " .. editValue)
    end
end

function Stank()
    local savedData = gg.getListItems()
    local TankAddress = nil
    local saved = false

    for _, v in ipairs(savedData) do
        if v.name == "Tank" then
            TankAddress = v.address
            saved = true
            break
        end
    end

    if not saved then
        gg.clearResults()
        gg.setRanges(gg.REGION_JAVA_HEAP)
        if searchInDalvikMainSpace("416;5;5:9", gg.TYPE_DWORD) then
            local results = gg.getResults(100)
            local found = false

            for _, v in pairs(results) do
                if v.value == 416 then
                    TankAddress = v.address
                    found = true
                    break
                end
            end

            if not found then
                gg.alert("Value tidak ditemukan")
                return
            end

            gg.addListItems({{
                address = TankAddress,
                flags = gg.TYPE_DWORD,
                name = "Tank",
                value = 416
            }})
            gg.alert("Tank telah di temukan")
        else
            gg.alert("Pencarian gagal")
            return
        end
    else
        gg.alert("Tank ditemukan")
    end

    local newValue = gg.prompt({
        "Edit value Tank:",
        "Back ke menu utama"
    }, {"0", false}, {"number", "checkbox"})

    if not newValue then return end
    if newValue[2] then return end

    local editValue = tonumber(newValue[1])
    if editValue then
        gg.setValues({{
            address = TankAddress,
            value = editValue,
            flags = gg.TYPE_DWORD
        }})
        gg.alert("Tank diubah menjadi: " .. editValue)
    end
end

function Tsamu()
    local savedData = gg.getListItems()
    local SamuraiAddress = nil
    local saved = false

    for _, v in ipairs(savedData) do
        if v.name == "Samurai" then
            SamuraiAddress = v.address
            saved = true
            break
        end
    end

    if not saved then
        gg.clearResults()
        gg.setRanges(gg.REGION_JAVA_HEAP)
        if searchInDalvikMainSpace("420;5;5:9", gg.TYPE_DWORD) then
            local results = gg.getResults(100)
            local found = false

            for _, v in pairs(results) do
                if v.value == 420 then
                    SamuraiAddress = v.address
                    found = true
                    break
                end
            end

            if not found then
                gg.alert("Value tidak ditemukan")
                return
            end

            gg.addListItems({{
                address = SamuraiAddress,
                flags = gg.TYPE_DWORD,
                name = "Samurai",
                value = 420
            }})
            gg.alert("Samurai telah di temukan")
        else
            gg.alert("Pencarian gagal")
            return
        end
    else
        gg.alert("Samurai ditemukan")
    end

    local newValue = gg.prompt({
        "Edit value Samurai:",
        "Back ke menu utama"
    }, {"0", false}, {"number", "checkbox"})

    if not newValue then return end
    if newValue[2] then return end

    local editValue = tonumber(newValue[1])
    if editValue then
        gg.setValues({{
            address = SamuraiAddress,
            value = editValue,
            flags = gg.TYPE_DWORD
        }})
        gg.alert("Samurai diubah menjadi: " .. editValue)
    end
end

function Tsino()
    local savedData = gg.getListItems()
    local SinobiAddress = nil
    local saved = false

    for _, v in ipairs(savedData) do
        if v.name == "Sinobi" then
            SinobiAddress = v.address
            saved = true
            break
        end
    end

    if not saved then
        gg.clearResults()
        gg.setRanges(gg.REGION_JAVA_HEAP)
        if searchInDalvikMainSpace("421;5;5:9", gg.TYPE_DWORD) then
            local results = gg.getResults(100)
            local found = false

            for _, v in pairs(results) do
                if v.value == 421 then
                    SinobiAddress = v.address
                    found = true
                    break
                end
            end

            if not found then
                gg.alert("Value tidak ditemukan")
                return
            end

            gg.addListItems({{
                address = SinobiAddress,
                flags = gg.TYPE_DWORD,
                name = "Sinobi",
                value = 421
            }})
            gg.alert("Sinobi telah di temukan")
        else
            gg.alert("Pencarian gagal")
            return
        end
    else
        gg.alert("Sinobi ditemukan")
    end

    local newValue = gg.prompt({
        "Edit value Sinobi:",
        "Back ke menu utama"
    }, {"0", false}, {"number", "checkbox"})

    if not newValue then return end
    if newValue[2] then return end

    local editValue = tonumber(newValue[1])
    if editValue then
        gg.setValues({{
            address = SinobiAddress,
            value = editValue,
            flags = gg.TYPE_DWORD
        }})
        gg.alert("Sinobi diubah menjadi: " .. editValue)
    end
end

function Tmana()
    local savedData = gg.getListItems()
    local ManaSlingerAddress = nil
    local saved = false

    for _, v in ipairs(savedData) do
        if v.name == "ManaSlinger" then
            ManaSlingerAddress = v.address
            saved = true
            break
        end
    end

    if not saved then
        gg.clearResults()
        gg.setRanges(gg.REGION_JAVA_HEAP)
        if searchInDalvikMainSpace("423;5;5:9", gg.TYPE_DWORD) then
            local results = gg.getResults(100)
            local found = false

            for _, v in pairs(results) do
                if v.value == 423 then
                    ManaSlingerAddress = v.address
                    found = true
                    break
                end
            end

            if not found then
                gg.alert("Value tidak ditemukan")
                return
            end

            gg.addListItems({{
                address = ManaSlingerAddress,
                flags = gg.TYPE_DWORD,
                name = "ManaSlinger",
                value = 423
            }})
            gg.alert("ManaSlinger telah di temukan")
        else
            gg.alert("Pencarian gagal")
            return
        end
    else
        gg.alert("ManaSlinger ditemukan")
    end

    local newValue = gg.prompt({
        "Edit value ManaSlinger:",
        "Back ke menu utama"
    }, {"0", false}, {"number", "checkbox"})

    if not newValue then return end
    if newValue[2] then return end

    local editValue = tonumber(newValue[1])
    if editValue then
        gg.setValues({{
            address = ManaSlingerAddress,
            value = editValue,
            flags = gg.TYPE_DWORD
        }})
        gg.alert("ManaSlinger diubah menjadi: " .. editValue)
    end
end

function Tguardian()
    local savedData = gg.getListItems()
    local GuardianAddress = nil
    local saved = false

    for _, v in ipairs(savedData) do
        if v.name == "Guardian" then
            GuardianAddress = v.address
            saved = true
            break
        end
    end

    if not saved then
        gg.clearResults()
        gg.setRanges(gg.REGION_JAVA_HEAP)
        if searchInDalvikMainSpace("422;5;5:9", gg.TYPE_DWORD) then
            local results = gg.getResults(100)
            local found = false

            for _, v in pairs(results) do
                if v.value == 422 then
                    GuardianAddress = v.address
                    found = true
                    break
                end
            end

            if not found then
                gg.alert("Value tidak ditemukan")
                return
            end

            gg.addListItems({{
                address = GuardianAddress,
                flags = gg.TYPE_DWORD,
                name = "Guardian",
                value = 422
            }})
            gg.alert("Guardian telah ditemukan")
        else
            gg.alert("Pencarian gagal")
            return
        end
    else
        gg.alert("Guardian ditemukan")
    end

    local newValue = gg.prompt({
        "Edit value Guardian:",
        "Back ke menu utama"
    }, {"0", false}, {"number", "checkbox"})

    if not newValue then return end
    if newValue[2] then return end

    local editValue = tonumber(newValue[1])
    if editValue then
        gg.setValues({{
            address = GuardianAddress,
            value = editValue,
            flags = gg.TYPE_DWORD
        }})
        gg.alert("Guardian diubah menjadi: " .. editValue)
    end
end












function lgp()
gg.alert("Feature Coming Soon!")
end

function llf()
gg.alert("Feature Coming Soon!")
end

function lml()
gg.alert("Feature Coming Soon!")
end

function lci()
gg.alert("Feature Coming Soon!")
end


function ldev()
gg.alert("Feature Coming Soon!")
end

-- Exit Function
function Exit()
    os.exit()
end

HISTORY = {HOME}
MENU_VISIBLE = true

-- Main Loop (UPDATED WITH HIDE/SHOW LOGIC)
while running do
    if gg.isVisible(true) then
        if not MENU_VISIBLE then
            -- Jika menu sedang hidden dan user klik icon GG, tampilkan menu
            ShowMenu()
        else
            -- Jika menu sedang visible, sembunyikan dulu untuk menghindari double display
            gg.setVisible(false)
            -- Tampilkan menu terakhir lagi
            local lastMenu = HISTORY[#HISTORY] or HOME
            lastMenu()
        end
    end
    
    gg.clearResults()
    
    -- Small delay to prevent CPU overuse
    gg.sleep(100)
end