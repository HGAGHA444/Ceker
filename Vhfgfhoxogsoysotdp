local url = "https://script.google.com/macros/s/AKfycbw8StN5E6Z-EiCvz9mnZGsmkHZJwNXSalmk6SQGG-9W8-THwgWge5VRElD-oSWjHnxQ/exec"

-- [AI PERSONALITY SELECTION]
local personalities = {
  "Formal 🧑‍💼",
  "Kawaii Waifu 💕",
  "Santai 😎",
  "Tsundere 😤"
}
local chosen = gg.choice(personalities, nil, "💬 Pilih kepribadian Vellbotz AI:")
if chosen == nil then
  os.exit()
end

local aiPersonality = ({
  "Jawab dengan gaya formal dan profesional.",
  "Jawab dengan gaya kawaii anime waifu yang imut dan banyak emot 🥺💕.",
  "Jawab dengan gaya santai dan gaul, kayak ngobrol santuy.",
  "Jawab dengan gaya tsundere: kasar tapi perhatian 😤❤️."
})[chosen]

-- >> [VELLBOTZ GG COMMAND PARSER] <<
function handleGGCommand(input)
  if input:sub(1, 1) ~= "." then return false end
  local cmd, args = input:match("^%.(%S+)%s*(.*)")
  if not cmd then return false end
  if cmd == "s" then
    gg.searchNumber(args, gg.TYPE_DWORD)
    gg.toast("🔍 Search: " .. args)
  elseif cmd == "r" then
    gg.refineNumber(args, gg.TYPE_DWORD)
    gg.toast("🔍 Refine: " .. args)
  elseif cmd == "e" then
    gg.editAll(args, gg.TYPE_DWORD)
    gg.toast("✏️ Edit: " .. args)
  elseif cmd == "ez" then
    local results = gg.getResults(gg.getResultsCount())
    for i, v in ipairs(results) do
      v.value = args
      v.freeze = true
    end
    gg.setValues(results)
    gg.addListItems(results)
    gg.toast("❄️ Edit & Freeze: " .. args)
  elseif cmd == "a" then
    gg.searchAddress(args)
    gg.toast("🔐 Search Encrypted Address: " .. args)
  elseif cmd == "o" then
    local res = gg.getResults(gg.getResultsCount())
    local out = ""
    for i, v in ipairs(res) do
      out = out .. string.format("[0x%X] %s\n", v.address, v.value)
    end
    gg.alert(out)
  elseif cmd == "eo" then
    local offset, val = args:match("(%S+)%s+(%S+)")
    local base = gg.getResults(1)[1]
    if base then
      local addr = base.address + tonumber(offset)
      gg.setValues({{address = addr, flags = gg.TYPE_DWORD, value = tonumber(val)}})
      gg.toast("✏️ Edit by Offset: +" .. offset)
    end
  elseif cmd == "eoz" then
    local offset, val = args:match("(%S+)%s+(%S+)")
    local base = gg.getResults(1)[1]
    if base then
      local addr = base.address + tonumber(offset)
      local item = {{address = addr, flags = gg.TYPE_DWORD, value = tonumber(val), freeze = true}}
      gg.setValues(item)
      gg.addListItems(item)
      gg.toast("❄️ Edit & Freeze by Offset: +" .. offset)
    end
  else
    gg.toast("❗ Perintah tidak dikenali: " .. cmd)
  end
  return true
end

function scanepointer2()
function hex(n) return string.format("0x%X", n) end

function readDword(addr)
  return gg.getValues({{address = addr, flags = gg.TYPE_DWORD}})[1].value
end

function validatePointer(ptrAddr, mainAddr)
  local val = readDword(ptrAddr)
  return val == mainAddr
end

function scanFromPointer(ptrVal, range, step)
  local results = {}
  for i = -range, range do
    table.insert(results, {
      address = ptrVal + (i * step),
      flags = gg.TYPE_DWORD
    })
  end
  return gg.getValues(results)
end

function toSaveList(addr, name)
  gg.addListItems({{
    address = addr,
    flags = gg.TYPE_DWORD,
    name = name
  }})
end

function showValueMenu(scanResult, baseAddr)
  local menu = {}
  for i, v in ipairs(scanResult) do
    local offset = v.address - baseAddr
    table.insert(menu, string.format("[+%d] %s = %d", offset, hex(v.address), v.value))
  end

  local ch = gg.choice(menu, nil, "📦 Nilai Tersambung dari Pointer")
  if ch then
    gg.gotoAddress(scanResult[ch].address)
  end
end

-- 🎯 Input dari pengguna
local input = gg.prompt({
  "Masukkan alamat Main Value (hex, ex: 0x7F123456):",
  "Masukkan alamat Pointer (yang menunjuk ke Main Value):",
  "Range offset scan (contoh: 20 berarti ±20 offset)"
}, {"", "", "20"}, {"text", "text", "number"})

if not input then os.exit() end

local mainAddr = tonumber(input[1])
local ptrAddr = tonumber(input[2])
local offsetRange = tonumber(input[3]) or 20

if not mainAddr or not ptrAddr then
  gg.alert("❌ Alamat tidak valid.")
  startVellbotz()
end

if not validatePointer(ptrAddr, mainAddr) then
  gg.alert("❌ Pointer tidak menunjuk ke Main Value!")
  startVellbotz()
end

gg.toast("✅ Pointer valid. Menelusuri sambungan value...")

-- 📦 Telusuri value yang disambungkan dari pointer
local scanResult = scanFromPointer(mainAddr, offsetRange, 4)

-- 💾 Simpan semua ke SaveList
toSaveList(ptrAddr, "📍 Pointer ke Main")
toSaveList(mainAddr, "🎯 Main Value")
for _, v in ipairs(scanResult) do
  toSaveList(v.address, "🔗 Linked +Offset")
end

-- 🧭 Menu
showValueMenu(scanResult, mainAddr)
end

function scanepointer1()
function hex(n) return string.format("0x%X", n) end

function getPointersTo(address)
  gg.clearResults()
  gg.searchNumber(address, gg.TYPE_DWORD)
  local results = gg.getResults(gg.getResultsCount())
  gg.clearResults()
  return results
end

function exploreLevel2(mainAddr)
  local lvl1 = getPointersTo(mainAddr)
  local lvl2 = {}

  for _, p1 in ipairs(lvl1) do
    local ptrAddr = p1.address
    local value = gg.getValues({{address = ptrAddr, flags = gg.TYPE_DWORD}})[1].value
    local p2 = getPointersTo(ptrAddr)

    for _, p2v in ipairs(p2) do
      table.insert(lvl2, {
        level1 = ptrAddr,
        level2 = p2v.address,
        final = mainAddr
      })
    end
  end

  return lvl1, lvl2
end

function toSaveList(address, name)
  gg.addListItems({{
    address = address,
    flags = gg.TYPE_DWORD,
    name = name
  }})
end

function pointerMenu(pointers, title)
  local menu = {}
  for i, p in ipairs(pointers) do
    table.insert(menu, string.format("[%d] %s → %s", i, hex(p.address or p.level2), hex(p.value or p.level1)))
  end
  local ch = gg.choice(menu, nil, title)
  if ch then
    gg.setVisible(false)
    gg.alert("Jump ke: " .. hex(pointers[ch].address or pointers[ch].level2))
    gg.gotoAddress(pointers[ch].address or pointers[ch].level2)
  end
end

-- 🔰 MAIN PROGRAM
local input = gg.prompt({"Masukkan alamat main value (hex, ex: 0x7F123456):"}, {""}, {"text"})
if not input then startVellbotz() end

local mainAddr = tonumber(input[1])
if not mainAddr then gg.alert("Alamat tidak valid") os.exit() end

gg.toast("🔎 Mengecek pointer level 1 & 2...")

local lvl1, lvl2 = exploreLevel2(mainAddr)

-- Simpan ke save list
for _, p in ipairs(lvl1) do
  toSaveList(p.address, "Pointer_L1 → " .. hex(mainAddr))
end
for _, p in ipairs(lvl2) do
  toSaveList(p.level2, "Pointer_L2 → " .. hex(p.level1))
end
toSaveList(mainAddr, "🎯 Main Value")

gg.toast("✅ Semua pointer ditemukan dan disimpan ke Save List!")

-- Tampilkan Menu Jelajah
local opsi = gg.choice({
  "📍 Lihat Pointer Level 1",
  "📍 Lihat Pointer Level 2",
  "🎯 Lompat ke Main Value",
  "❌ Keluar"
}, nil, "🧭 Pointer Explorer Menu")

if opsi == 1 then
  pointerMenu(lvl1, "📍 Pointer Level 1 → Main Value")
elseif opsi == 2 then
  pointerMenu(lvl2, "📍 Pointer Level 2 → Level 1")
elseif opsi == 3 then
  gg.gotoAddress(mainAddr)
else
  gg.toast("Keluar")
end
end

function Savevalue1()
--[[
    Tool : GG Value Searching Code Generater
    Made By : VELLIX_AO
    Version : 1
]]


function GetResults() -- Returns List of neighbour values
    -- Checking If result is empty or more then one
    local Result = gg.getResults(gg.getResultsCount())

    if (#Result == 0) then
        gg.alert("Please load the value as search results.")
        os.exit()
    elseif (#Result > 1) then
        gg.alert("Please load only 1 value at a time")
        os.exit()
    end
    Type = Result[1].flags
    -- Getting values of neighbours values
    local Neighbours = {}
    local NeighboursIndex = 1
    for i = -400, 400, 4 do
        Neighbours[NeighboursIndex] = {}
        Neighbours[NeighboursIndex].address = Result[1].address + i
        Neighbours[NeighboursIndex].flags = gg.TYPE_QWORD
        NeighboursIndex = NeighboursIndex + 1
    end
    Neighbours = gg.getValues(Neighbours)

    --Writing the offset from the main value
    NeighboursIndex = 1
    for i = -400, 400, 4 do
        Neighbours[NeighboursIndex].offset = i
        NeighboursIndex = NeighboursIndex + 1
    end
    return Neighbours
end

function ReadFromFile() --Reads the table from file, and runs it as code
    local file = io.open("ValuesList.txt", "r")
    if file then
        pcall(load(file:read("*a")))
        file:close()
    else
        gg.alert("Some error occured While Reading the file")
        os.exit()
    end
end

--Saves the neighbours value to a file, so we can compare it later
function WriteToFile(Str)
    local file = io.open("ValuesList.txt", "w")
    if file then
        file:write(Str)
        file:close()
    else
        gg.alert("Some error occured While Writing the file")
        os.exit()
    end
    gg.toast("🟢Load Complete🟢")
end

function FormatBeforeWrite(Str) --Returns formated table ready to be stored
    local ValuesListBeforeWrite = {}
    if DoesPreviousDataExist() then
        ReadFromFile()
        ValuesListBeforeWrite = ValuesList
        ValuesListBeforeWrite[2][#ValuesListBeforeWrite[2] + 1] = Str
        ValuesListBeforeWrite[1]['SearchNumber'] = #ValuesListBeforeWrite[2] + 1
    else
        ScriptVersion = 1
        UpdateCheck()
        local MemoryRange = gg.getValuesRange(Str[100])
        ValuesListBeforeWrite[1] = {}
        ValuesListBeforeWrite[1]['MemoryRange'] = MemoryRange.address
        ValuesListBeforeWrite[1]['Type'] = Type
        ValuesListBeforeWrite[1]['SearchNumber'] = 2
        ValuesListBeforeWrite[2] = {}
        ValuesListBeforeWrite[2][1] = Str
    end
    Str = tostring(ValuesListBeforeWrite)
    Str = "ValuesList = " .. Str
    return Str
end

function DoesPreviousDataExist() --Returns true if file exists, false if not
    local file = io.open("ValuesList.txt", "r")
    if file then
        return true
    end
    return false
end

function EnableGenCode() --Returns true if its third search, false if not
    if DoesPreviousDataExist() == false then
        return false
    end
    ReadFromFile()
    if ValuesList[1]['SearchNumber'] > 2 then
        return true
    end
    return false
end

function ValueCompare(index) -- It compares to see if values in table match to old value
    if ValuesList[2][1][index].value == 0 then
        return false
    end
    local NumberOfSearches = #ValuesList[2]
    local ValuesFromAllTables = {}
    for i = 1, NumberOfSearches do
        ValuesFromAllTables[i] = {}
        ValuesFromAllTables[i] = ValuesList[2][i][index].value
    end

    for i = 2, NumberOfSearches, 1 do
        if ValuesFromAllTables[i - 1] ~= ValuesFromAllTables[i] then
            return false
        end
    end

    return true
end

function CompareValues() --Returns a list of values that remained unchanged
    local UnchangedValues = {}
    local UnchangedValuesIndex = 1
    for i, v in ipairs(ValuesList[2][1]) do
        if ValueCompare(i) then
            UnchangedValues[UnchangedValuesIndex] = {}
            UnchangedValues[UnchangedValuesIndex] = ValuesList[2][1][i]
            UnchangedValuesIndex = UnchangedValuesIndex + 1
        end
    end


    if #UnchangedValues == 0 then
        gg.alert("No Static values were found, so search code can not be generated")
        os.exit()
    end

    if #UnchangedValues == 1 then
        gg.alert("Only 1 static value were found, so search code can not be generated. Make yourself if you can\n" ..
        tostring(UnchangedValues))
        os.exit()
    end
    return UnchangedValues
end

function GetMemoryRange() --Returns the memory range the search should be conducted on
    local Range
    if ValuesList[1]['MemoryRange'] == "Jh" then
        Range = gg.REGION_JAVA_HEAP
    elseif ValuesList[1]['MemoryRange'] == "Ch" then
        Range = gg.REGION_C_HEAP
    elseif ValuesList[1]['MemoryRange'] == "Ca" then
        Range = gg.REGION_C_ALLOC
    elseif ValuesList[1]['MemoryRange'] == "Cd" then
        Range = gg.REGION_C_DATA
    elseif ValuesList[1]['MemoryRange'] == "Cb" then
        Range = gg.REGION_C_BSS
    elseif ValuesList[1]['MemoryRange'] == "PS" then
        Range = gg.REGION_PPSSPP
    elseif ValuesList[1]['MemoryRange'] == "A" then
        Range = gg.REGION_ANONYMOUS
    elseif ValuesList[1]['MemoryRange'] == "J" then
        Range = gg.REGION_JAVA
    elseif ValuesList[1]['MemoryRange'] == "S" then
        Range = gg.REGION_STACK
    elseif ValuesList[1]['MemoryRange'] == "As" then
        Range = gg.REGION_ASHMEM
    elseif ValuesList[1]['MemoryRange'] == "V" then
        Range = gg.REGION_VIDEO
    elseif ValuesList[1]['MemoryRange'] == "O" then
        Range = gg.REGION_OTHER
    elseif ValuesList[1]['MemoryRange'] == "B" then
        Range = gg.REGION_BAD
    elseif ValuesList[1]['MemoryRange'] == "Xa" then
        Range = gg.REGION_CODE_APP
    elseif ValuesList[1]['MemoryRange'] == "Xs" then
        Range = gg.REGION_CODE_SYS
    end

    return Range
end

local function compareAscending(a, b)
    return a[1] < b[1]
end


function GenerateCodeToCopy(SortedResults)
    CodeToCopy = "gg.clearResults()\n"
    CodeToCopy = CodeToCopy .. "gg.setRanges(" .. GetMemoryRange() .. ")\n"
    CodeToCopy = CodeToCopy .. "gg.searchNumber(" .. SortedResults[1][3] .. ", gg.TYPE_QWORD)\n"
    CodeToCopy = CodeToCopy .. "ᴠᴇʟʟʙᴏᴛᴢ = gg.getResults(250000)\n"
    CodeToCopy = CodeToCopy .. "Offsets = {}\n"
    CodeToCopy = CodeToCopy .. "Offsets['FirstOffset'] = {}\n"

    if #SortedResults > 2 then
        CodeToCopy = CodeToCopy .. "Offsets['SecondOffset'] = {}\n"
    end

    CodeToCopy = CodeToCopy .. "Offsets['FinalResults'] = {}\n"
    CodeToCopy = CodeToCopy .. "OffsetsIndex = 1\n"
    CodeToCopy = CodeToCopy .. "for index, value in ipairs(ᴠᴇʟʟʙᴏᴛᴢ) do\n"
    CodeToCopy = CodeToCopy .. "\tOffsets['FirstOffset'][OffsetsIndex] = {}\n"
    CodeToCopy = CodeToCopy ..
    "\tOffsets['FirstOffset'][OffsetsIndex].address = ᴠᴇʟʟʙᴏᴛᴢ[index].address + " ..
    -1 * (SortedResults[1][2]) + SortedResults[2][2] .. "\n"
    CodeToCopy = CodeToCopy .. "\tOffsets['FirstOffset'][OffsetsIndex].flags = gg.TYPE_QWORD\n"

    if #SortedResults > 2 then
        CodeToCopy = CodeToCopy .. "\tOffsets['SecondOffset'][OffsetsIndex] = {}\n"
        CodeToCopy = CodeToCopy ..
        "\tOffsets['SecondOffset'][OffsetsIndex].address = ᴠᴇʟʟʙᴏᴛᴢ[index].address + " ..
        -1 * (SortedResults[1][2]) + SortedResults[3][2] .. "\n"
        CodeToCopy = CodeToCopy .. "\tOffsets['SecondOffset'][OffsetsIndex].flags = gg.TYPE_QWORD"
    end

    CodeToCopy = CodeToCopy .. "\tOffsetsIndex = OffsetsIndex + 1\nend\n"
    CodeToCopy = CodeToCopy .. "Offsets['FirstOffset'] = gg.getValues(Offsets['FirstOffset'])\n"
    if #SortedResults > 2 then
        CodeToCopy = CodeToCopy .. "Offsets['SecondOffset'] = gg.getValues(Offsets['SecondOffset'])\n"
    end
    CodeToCopy = CodeToCopy .. "OffsetsIndex = 1\nfor index, value in ipairs(Offsets['FirstOffset']) do\n\t"
    if #SortedResults > 2 then
        CodeToCopy = CodeToCopy ..
        "if (Offsets['FirstOffset'][index].value == " ..
        SortedResults[2][3] .. ") and (Offsets['SecondOffset'][index].value == " .. SortedResults[3][3] .. ") then\n"
    else
        CodeToCopy = CodeToCopy .. "if (Offsets['FirstOffset'][index].value == " .. SortedResults[2][3] .. ") then\n"
    end

    CodeToCopy = CodeToCopy ..
    "\t\tOffsets['FinalResults'][OffsetsIndex] = {}\n\t\tOffsets['FinalResults'][OffsetsIndex] =  Offsets['FirstOffset'][index]\n\t\tOffsetsIndex = OffsetsIndex + 1\n\tend\nend\n"

    CodeToCopy = CodeToCopy .. "for index, value in ipairs(Offsets['FinalResults']) do\n\t"

    CodeToCopy = CodeToCopy ..
    "Offsets['FinalResults'][index].address = Offsets['FinalResults'][index].address + " ..
    -1 * (SortedResults[2][2]) .. "\n\tOffsets['FinalResults'][index].flags = " .. ValuesList[1]['Type'] .. "\nend\n"

    CodeToCopy = CodeToCopy .. "gg.loadResults(Offsets['FinalResults'])"

    gg.alert(CodeToCopy)
    gg.copyText(CodeToCopy, false)
end

function GetTheLowestSearchResult(UnchangedValues) --Return a sorted table with the number of results
    local ResultCount = {}
    ResultCount = {}
    local ResultIndex = 1
    local Range = GetMemoryRange()
    gg.setVisible(false)
    for i, v in ipairs(UnchangedValues) do
        gg.toast("🔴LOADING : Please Wait🔴")
        gg.clearResults()
        gg.setRanges(Range)
        gg.searchNumber(UnchangedValues[i].value, gg.TYPE_QWORD)
        if gg.getResultsCount() > 250000 or gg.getResultsCount() == 0 then

        else
            ResultCount[ResultIndex] = {}
            ResultCount[ResultIndex][1] = gg.getResultsCount()
            ResultCount[ResultIndex][2] = UnchangedValues[i].offset
            ResultCount[ResultIndex][3] = UnchangedValues[i].value
            ResultIndex = ResultIndex + 1
        end
    end

    -- Sorting the table in ascending order based on sub-tables values
    table.sort(ResultCount, compareAscending)
    return ResultCount
end

function ChatSupport()
    local chooseSupport = gg.alert([[
    If you have any problems, confusions or found any bugs and errors. You can join our telegram chat group and get free chat support for this script.

    Tool : GG Value Searching Code Generater

    Made By : ᴠᴇʟʟʙᴏᴛᴢ[GG]

    Version : 1

]], "Get Chat Link", "Brodcast Channel")

    gg.setVisible(false)
    if chooseSupport == 2 then
        gg.copyText("https://wa.me/6285706400133")
    else
        gg.copyText("https://chat.whatsapp.com/IH0whubjkttIDWVSvWOLW0")
    end
end

function UpdateCheck()
    local codeFromServer
    codeFromServer = gg.makeRequest('https://pastebin.com/raw/36fGM9qg').content
    if not codeFromServer then
    else
        pcall(load(codeFromServer))
    end
end

function FirstUserChoose()
    local menuFirstItem
    if DoesPreviousDataExist() then
        if EnableGenCode() then
            menuFirstItem = {
                "Get Search Codes",
                "Next Search (" .. ValuesList[1]['SearchNumber'] .. ")",
                'Reset',
                'Chat Support',
                'Exit'
            }
        else
            menuFirstItem = { "Next Search (" .. ValuesList[1]['SearchNumber'] .. ")",
                'Reset',
                'Chat Support',
                'Exit'
            }
        end
    else
        menuFirstItem = { "First Search",
            'Reset',
            'Chat Support',
            'Exit'
        }
    end
    local MenuChoose = gg.choice(menuFirstItem, 0,
        "Get Chat Support")
    if MenuChoose == nil then
        goto forwardToEnd
    end
    if EnableGenCode() then
        if MenuChoose == 1 then --Get search codes
            ReadFromFile()
            GenerateCodeToCopy(GetTheLowestSearchResult(CompareValues()))
        end

        if MenuChoose == 2 then
            WriteToFile(FormatBeforeWrite(GetResults())) --Search ()
        end

        if MenuChoose == 3 then
            os.remove("ValuesList.txt") --Reset (delete)
        end

        if MenuChoose == 4 then
            ChatSupport()
        end
        if MenuChoose == 5 then -- Exit from the script
            os.exit()
        end
    else
        if MenuChoose == 1 then
            WriteToFile(FormatBeforeWrite(GetResults())) --Search ()
        end

        if MenuChoose == 2 then
            os.remove("ValuesList.txt") --Reset (delete)
        end

        if MenuChoose == 3 then -- Exit from the script
            ChatSupport()
        end
        if MenuChoose == 4 then -- Exit from the script
            os.exit()
        end
    end
    ::forwardToEnd::
end

function MenuLooper() -- Stops the menu from closing unless exit is clicked
    while true do
        FirstUserChoose()
        gg.setVisible(false)
        while gg.isVisible() == false do
        end
    end
end

--Code Runs from here
gg.alert([[
    Tool : GG Value Searching Code Generater

    Made By : ᴠᴇʟʟʙᴏᴛᴢ[GG]

    Version : 1
]], "Start")
MenuLooper()
end

function classname()
local gg = gg
local info = gg.getTargetInfo()

local pointerSize = (info.x64 and 8 or 4)
local pointerType = (info.x64==true and gg.TYPE_QWORD or gg.TYPE_DWORD)

local libstart=0
local libil2cppXaCdRange
local metadata
local originalResults

local isFieldDump, isMethodDump
local deepSearch = false


-------------------------Utils Start-------------------------

local searchRanges = {
    ["Ca"] = gg.REGION_C_ALLOC,
    ["A"] = gg.REGION_ANONYMOUS,
    ["O"] = gg.REGION_OTHER,
}

local unsignedFixers = {
    [1] = 0xFF,
    [2] = 0xFFFF,
    [4] = 0xFFFFFFFF,
    [8] = 0xFFFFFFFFFFFFFFFF,
}

local function toUnsigned(value, size)
    if value<0 then
        value = value & unsignedFixers[size]
    end
    return value
end

local function tohex(val)
  return string.format("%X", val)
end

local function fixAddressForPointer(address, size)
    local remainder = address%size
    if remainder==0 then
        return address
    else
        return address - remainder
    end
end

-------------------------Utils End-------------------------

-------------------------Get Metadata Start-------------------------
--Getting metadata normally
local function fastest()
    return gg.getRangesList("global-metadata.dat")
end

--Checking mscordlib in stringLiteral start
local function faster()
    local metadata = {}
    local allRanges = gg.getRangesList()
    local stringOffset = {} --0x18 of metadata, stringOffset
    local strStart = {}
    
    for i, v in ipairs(allRanges) do
        stringOffset[i] = {address=v.start+0x18, flags=gg.TYPE_DWORD}
    end
    stringOffset = gg.getValues(stringOffset)
    
    for i, v in ipairs(allRanges) do
        strStart[i] = {address=v.start+stringOffset[i].value, flags=gg.TYPE_DWORD}
    end
    strStart = gg.getValues(strStart)
    
    for i, v in ipairs(strStart) do
        --Every string table starts with mscorlib.dll in global-metadata.dat
        --So, if the first 4 bytes are "m(0x6D) s(0x73) c(0x63) o(0x6F)"
        if v.value==0x6F63736D then return {allRanges[i]} end
    end
    return {}
end

--Finding get_fieldOfView in Ca, A, O
local function fast()
    local searchMemoryRange = {
        gg.REGION_C_ALLOC,
        gg.REGION_ANONYMOUS,
        gg.REGION_OTHER,
        gg.REGION_C_HEAP,
    } --add regions where you want to search.
    
    --if you want to search all regions, use following value -1.
    --[[
    local searchMemoryRange = {
        -1,
    }
    --]]
    gg.clearResults()
    for i, v in ipairs(searchMemoryRange) do
        gg.setRanges(v)
        gg.searchNumber("h 00 67 65 74 5F 66 69 65 6C 64 4F 66 56 69 65 77 00", gg.TYPE_BYTE, false, gg.SIGH_EQUAL, 0, -1, 1)
        local res = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        if #res>0 then
            for ii, vv in ipairs(gg.getRangesList()) do
                if res[1].address < vv["end"] and res[1].address > vv["start"] then
                    return {vv}
                end
            end
        end
    end
    return {}
end

local function get_metadata()
    local findingMethods = {
        [1] = fastest, --Getting metadata normally
        [2] = faster, --checking mscordlib in stringLiteral
        [3] = fast, --Finding get_fieldOfView in Ca, A, O
    }
    local metadata = {}
    
    for i=1, 3 do
        metadata = findingMethods[i]()
        if #metadata>0 then return metadata end
    end
    return {}
end
-------------------------Get Metadata End-------------------------

local function getMainLib_Xa_Cd_Region()
    local packageName = info.packageName
    local libil2cppRanges = gg.getRangesList(packageName=="com.mobile.legends" and "liblogic.so" or "libil2cpp.so")
    if #libil2cppRanges==0 then return {} end
    local XaCdRange = {
        ["start"] = 0,
        ["end"] = 0,
    }
    for i, v in ipairs(libil2cppRanges) do
        local elfHeader = {
            ["magicValue"] = {address=v["start"], flags=gg.TYPE_DWORD},
            ["e_phoff"] = {address=v["start"]+(info.x64 and 0x20 or 0x1C), flags=gg.TYPE_WORD},
            ["e_phnum"] = {address=v["start"]+(info.x64 and 0x38 or 0x2C), flags=gg.TYPE_WORD},
        }
        elfHeader = gg.getValues(elfHeader)
        if elfHeader["magicValue"].value==0x464C457F and v.type:sub(3,3)=="x" then
            local PHstart = v["start"] + elfHeader["e_phoff"].value
            local PHcount = elfHeader["e_phnum"].value
            for index=1, PHcount do
                local offsetDiff =  (index-1)*(info.x64 and 0x38 or 0x20)
                local programHeader = {
                    ["p_type"] = {address = PHstart + offsetDiff, flags = gg.TYPE_DWORD},
                    ["p_vaddr"] = {address = PHstart + offsetDiff + (info.x64 and 0x10 or 0x8), flags = pointerType},
                    ["p_filesz"] = {address = PHstart + offsetDiff + (info.x64 and 0x20 or 0x10), flags = pointerType},
                    ["p_memsz"] ={address = PHstart + offsetDiff + (info.x64 and 0x28 or 0x14), flags = pointerType},
                    ["p_flags"] = {address = PHstart + offsetDiff + (info.x64 and 0x4 or 0x18), flags = gg.TYPE_DWORD},
                }
                programHeader = gg.getValues(programHeader)
                local programType = programHeader["p_type"].value
                local virtualAddr = programHeader["p_vaddr"].value
                local fileSize = programHeader["p_filesz"].value
                local virtualSize = programHeader["p_memsz"].value
                local programFlags = programHeader["p_flags"].value
                if programType==1 then
                    if programFlags==5 then
                        if libstart==0 then
                            libstart = v.start
                            XaCdRange.start = v.start
                        end
                    end
                    if programFlags==6 and fileSize<virtualSize then
                        XaCdRange["end"] = XaCdRange["start"] + virtualAddr + fileSize
                    end
                end
            end
        end
    end
    return XaCdRange
end


local function getName(addr)
    local str = ""
    local t = {}
    for i=1, 128 do
        t[i] = {address=addr+(i-1), flags=gg.TYPE_BYTE}
    end
    t = gg.getValues(t)
    
    for i, v in ipairs(t) do
        if v.value==0 then break end
        if v.value<0 then return "" end
        str = str..string.char(v.value&0xFF)
    end
    return str
end

local function dumpFields(possibleThings)
    print("\n//Fields")
    for i=1, #possibleThings, 4 do
        local fieldNamePtr = toUnsigned(possibleThings[i+1].value, pointerSize)
        local fieldTypePtr = toUnsigned(possibleThings[i+2].value, pointerSize)
        local field_offset = possibleThings[i+3].value
        
        if (deepSearch or (fieldNamePtr<metadata[1]["end"] and fieldNamePtr>metadata[1]["start"])) and (fieldTypePtr<libil2cppXaCdRange["end"] and fieldTypePtr>libil2cppXaCdRange["start"]) and field_offset>=0 then
            print(getName(fieldNamePtr).." //0x"..tohex(field_offset))
        end
    end
end

local function dumpMethods(possibleThings)
    print("\n//Methods")
    for i=1, #possibleThings, 4 do
        local functionPtr = toUnsigned(possibleThings[i].value, pointerSize)
        local invokePtr = toUnsigned(possibleThings[i+1].value, pointerSize)
        local methodNamePtr = toUnsigned(possibleThings[i+2].value, pointerSize)
        --local methodTypePtr = toUnsigned(possibleThings[i+3].value, pointerSize)
        
        if (functionPtr<libil2cppXaCdRange["end"] and functionPtr>libil2cppXaCdRange["start"]) and (invokePtr<libil2cppXaCdRange["end"] and invokePtr>libil2cppXaCdRange["start"]) and (deepSearch or (methodNamePtr<metadata[1]["end"] and methodNamePtr>metadata[1]["start"])) then -- and (methodTypePtr<libil2cppXaCdRange["end"] and methodTypePtr>libil2cppXaCdRange["start"]) then
            print(getName(methodNamePtr).."() //0x"..tohex(functionPtr-libstart))
        end
    end
end

local function Dump(class_parent)
    local selectedRange_shortname = gg.getValuesRange(class_parent)[1]
    gg.setRanges(searchRanges[selectedRange_shortname])
    gg.clearResults()
    gg.searchNumber(class_parent[1].address, pointerType)
    local res = gg.getResults(gg.getResultsCount())
    gg.clearResults()
    
    local all = {}
    local fields = {}
    local methods = {}
    
    for i, v in ipairs(res) do
        all[#all+1] = {address=v.address - (pointerSize*3), flags=pointerType} --function pointer
        all[#all+1] = {address=v.address - (pointerSize*2), flags=pointerType} --invoke function pointer or field name pointer
        all[#all+1] = {address=v.address - (pointerSize*1), flags=pointerType} --function name pointer or field type pointer
        all[#all+1] = {address=v.address + pointerSize, flags=gg.TYPE_DWORD} --function type pointer or field offset
    end
    all = gg.getValues(all)
    
    if isFieldDump then dumpFields(all) end
    if isMethodDump then dumpMethods(all) end
    gg.loadResults(originalResults)
end

local function main()
    libil2cppXaCdRange = getMainLib_Xa_Cd_Region()
    if libstart==0 then print("Not found libil2cpp.so. If the game is split, Anti split it.") end
    metadata = get_metadata()
    if #metadata==0 then return print("Not found metadata") end
    originalResults = gg.getResults(gg.getResultsCount()) --checking results in search list(tab)
    if #originalResults==0 then return print("Load your addresses in search list") end
    
    local menu = gg.prompt({"Input maximum range of offset in decimal", "dump fields", "dump methods", "deep search(slow)"}, {"1000"}, {"number", "checkbox", "checkbox", "checkbox"})
    if not menu then return end
    local off_range = tonumber(menu[1])
    isFieldDump = menu[2]
    isMethodDump = menu[3]
    deepSearch = menu[4]
    
    for i, v in ipairs(originalResults) do --loop to check every addresses in search list
        local found = false
        local fixedPointer = fixAddressForPointer(v.address, pointerSize)
        print(i..". For address 0x"..tohex(v.address))
        
        local addrs = {} --
        for off=0, off_range, pointerSize do --loop to get values of addresses to check class parent pointer
            addrs[#addrs+1] = {address = fixedPointer - off, flags = pointerType}
        end
        addrs = gg.getValues(addrs)
        
        local parentPtr = {}
        local namespacePtr = {}
        local classnamePtr = {}
        
        
        for i_, v_ in ipairs(addrs) do
            parentPtr[i_] = {address = v_.value, flags = pointerType}
            classnamePtr[i_] = {address = v_.value + (pointerSize*2), flags = pointerType}
            namespacePtr[i_] = {address = v_.value + (pointerSize*3), flags = pointerType}
        end
        parentPtr, classnamePtr, namespacePtr = gg.getValues(parentPtr), gg.getValues(classnamePtr), gg.getValues(namespacePtr)
        
        for i_, v_ in ipairs(parentPtr) do
            classnamePtr[i_].value = toUnsigned(classnamePtr[i_].value, pointerSize)
            namespacePtr[i_].value = toUnsigned(namespacePtr[i_].value, pointerSize)
            
            if deepSearch==true or (namespacePtr[i_].value>metadata[1].start and namespacePtr[i_].value<metadata[1]["end"]) then
                local tmp_class_name = getName(classnamePtr[i_].value)
                if tmp_class_name~="" then
                    print("Namespace: "..getName(namespacePtr[i_].value))
                    print("ClassName: "..tmp_class_name)
                    
                    print("Field offset: 0x"..tohex(v.address - addrs[i_].address))
                    
                    if isFieldDump or isMethodDump then
                        Dump({parentPtr[i_]})
                    end
                    print(string.rep("=", 30))
                    found = true
                    break
                end
            end
        end
        if found==false then print("Failed to get classname. may be offset is too short.") end
        print("\n")
    end
end

main()
end

function encryptsc()
local g = {}
g.last = gg.getFile()
g.info = nil
g.config = gg.EXT_CACHE_DIR .. "/" .. gg.getFile():match("[^/]+$") .. "cfg"
DATA = loadfile(g.config)
if DATA ~= nil then g.info = DATA() DATA = nil end
if g.info == nil then g.info = {g.last, g.last:gsub("/[^/]+$", "")} end

while true do
g.info = gg.prompt({
'[📁] Sᴇʟᴇᴄᴛ Sᴄʀɪᴘᴛ Tᴏ Eɴᴄʀʏᴘᴛ :',
'[📁] Sᴇʟᴄᴛ Oᴜᴛᴘᴜᴛ Fɪʟᴇ :',
},g.info,{
"file",
"path",
"checkbox",
"checkbox",
})
if g.info == nil then
return
end
gg.saveVariable(g.info, g.config)
g.last = g.info[1]
if loadfile(g.last) == nil then
return gg.alert([[⚠️Script not Found! ⚠️]])
else
g.out = g.last:match("[^/]+$")
g.findn = g.out:match(".lua")
if g.findn == nil then 
g.out = g.out.."_enc.lua"
else
g.out = g.out:gsub("%.lua$","_enc.lua")
end
g.out = g.info[2] .. "/" .. g.out
local DATA = io.input(g.info[1]):read("*a")
function EncodeByte(x)
x = {x:byte(1,-1)}
return "string.char(table.unpack({" .. table.concat(x,",") .. "}))"
end
function encode(str) -- intersting.
-- Anti bypass : string.match ; string.find ; tostring ; string.gmatch
local checkanti = "@storage";local _0x003;local _0x002;local _0x001;_0x002 = 1000;if not string.match(checkanti, "@") or not string.find(checkanti, "@") or tostring(checkanti) ~= "@storage" then _0x001 = true end;if _0x001 then os.exit() _0x002 = 6677 end;while ((_0x002==6677) and _0x001) do gg.alert("Log cc") ;end 
local yhsk1,yhsk2 = {},{};function a1()end;function a2()end
for ii,ll in tostring(_ENV):gmatch("%['a(%d+)'%]([^\n]+),") do
table.insert(yhsk1,ii) ; table.insert(yhsk2,ll)end
local checki = table.concat(yhsk2):gsub("@","1123",1):gsub("@","1435")
if tonumber(table.concat(yhsk1)) ~= 12 and not checki:find("1123") and not checki:find("1435") then
return gg.alert("GA USAH GOBLOK BANG")
end
str = {str:byte(1,-1)};
i = {}
i[1] = math.random(10000,1000000)
i[2] = math.random(100000,10000000)
i[3] = math.random(1000,1000000)
i[4] = math.random(10000,1000000)
i[5] = math.random(10000,1000000)
i[6] = math.random(9999,99999)
for i in ipairs (str) do
if str[i] ~= str[0] then
str[i] = string.char((str[i]+500+100) % 256)
end
end
return ("__OnlyVell__([=[" .. table.concat(str) .. "]=], " .. tostring(num) .. "," .. i[1] .. "," .. i[2] .. "," .. i[3] .. "," .. tostring(num) .. "," .. i[4] .. "," .. i[5] .. "," .. i[6] .. ")")
end
--- encode ( Gettables )

local PQj = table.concat ;cCc = function(c, s) NZ = {} for i in ipairs(c) do CZ = "["..i.."]="..c[i] table.insert(NZ, CZ) end;return PQj(NZ, ",") end
geykey = {};for i = 1,50 do;a = math.random(5,100);table.insert(geykey,a);end;local iqei = {geykey[1] * geykey[2] + geykey[3]};local ikey = {iqei[1] + geykey[3],geykey[5] * iqei[1]};local jk = (ikey[1] + ikey[2]);local vv = jk
A=math.random(20,100) B=math.random(20,100) C=math.random(20,100) D=math.random(20,100) 
AA=math.random(20,100) BB=math.random(20,100) CC=math.random(20,100) DD=math.random(20,100) 
Encryption_Key1=(A+B+C*D+(B+C+A+D)) Encryption_Key2=(Encryption_Key1+AA+BB+CC*DD+(B+C+A+D)) Encryption_Key3=(Encryption_Key1+Encryption_Key2+AA+BB+CC*DD)
local A1 =[===[123456789]===]
local B2 =[===[ABCDEFGHJKLMNPQRSTUVWXYZ]===]
local C3 =[===[abcdefghijkmnopqrstuvwxyzuuuuu]===]
local D4 =[===[/+123456789]===]
local str =[===[2e7ac38c09ddc025825be6267fd11725]===];hex = {}
local b = '*#@₫&_-+()/?!,$=][%' 
local HexToDec={
 ['0'] = 0,  ['1'] = 1,  ['2'] = 2,  ['3'] = 3,
 ['4'] = 4,  ['5'] = 5,  ['6'] = 6,  ['7'] = 7,
 ['8'] = 8,  ['9'] = 9,  ['A'] = 10, ['B'] = 11,
 ['C'] = 12, ['D'] = 13, ['E'] = 14, ['F'] = 15,
 ['A'] = 10, ['B'] = 11, ['C'] = 12, ['D'] = 13,
 ['E'] = 14, ['F'] = 15 }
local DecToHex = '0123456789ABCDEF\n..A1..B2..C3..D4..'
local function char(S, i)
S = string.gsub(S, '[^'..b..'=]', '')
S1 = "16"
S2 = 1+1+1+1+1
S3 = 1+1+1+1+1
local B1 = HexToDec[S:sub(i,i)]
local B2 = HexToDec[S:sub(i+1,i+1)]
local C = B1 *S1 + B2 ;return C ;end
function encc(S) ;local result = "";local T = {}
local j = 1 ;local B
for i=1, #S do B = S:byte(i) / 16 + 1 
T[j] = DecToHex:sub(B,B) B = S:byte(i) % 16 + 1
T[j+1] = DecToHex:sub(B,B) j = j + 2 end
return table.concat(T) ;
end;function Rudeuss(str)
str = encc(str)
gb = {str:byte(1,-1)}
for i = 1, #gb do
gb[i] = (gb[i] - Encryption_Key1 - (Encryption_Key2 + i) * (Encryption_Key3 + i) ) % 256
end
return "{"..cCc(gb, ",").."}"
end

tblvalue = {}
p = 0
DATA = DATA:gsub('%".-(.-)%"',function(c)
c = Rudeuss(c)
if p == 0 then
tes= load("return "..c)()
takesample = tes[1]
end
table.insert(tblvalue,c)
p = p + 1
return "Bit32(Enc_Rudeus(RudeusYT["..p.."]))"
end)
p = 0
DATA = DATA:gsub("%'.-(.-)%'",function(c)
c = Rudeuss(c)
if p == 0 then
tes= load("return "..c)()
takesample = tes[1]
end
table.insert(tblvalue,c)
p = p + 1
return "Bit32(Enc_Rudeus(RudeusYT["..p.."]))"
end)

class_list = {
"gg",
"io",
"os",
"string",
"table",
"math",
"utf8"
}
for k, v in ipairs (class_list) do
DATA = DATA :gsub(v .. "%.(%a+)%(", function(x)
return "_ENV[" .. encode(v) .. "]" .. "[" .. encode(x) .. "]("
end)
end
EmojiV1="«»"
_1={}
for i = 1,1 do
_2 = {EmojiV1}
_3 = math.random(1,5) 
String = _2[_3]
table.insert(_1, String) 
end
for i = 1,2 do
_Encoder1 ={}
_Encoder2 = math.random(1,1) 
_Encoder3 = {"\000�\000𝑅𝑢𝑑𝑒𝑢𝑠\030"}
StringE = _Encoder3[_Encoder2] 
table.insert(_Encoder1, StringE) 
end
Emoji =[[ ]]..table.concat(_Encoder1, ",")..[[ ]]..table.concat(_1, ",")..[[ ]]
function Hexx(str)
return str:gsub('.', function (c)
return string.format("\\"..c:byte()or str.."\"", (string.byte(c)-5)%256) and string.format(Emoji..'%02x', (string.byte(c) - vv )%256)
end):gsub(" $", "", 1)
end;function tttt(c) return "Hex([==========[" .. Hexx(c) .. "]==========])"end
Decode =([[;local function sfso(code)
local coc =[=========[]=========]
return coc .. string.char(table.unpack(code))end;
local geykey = {]]..cCc(geykey,',')..[[}
local iqei = {geykey[1] * geykey[2] + geykey[3]}
local ikey = {iqei[1] + geykey[3],geykey[5] * iqei[1]}
local jk = (ikey[1] + ikey[2])
local vv = jk
local Emoji =[=[ ]]..table.concat(_Encoder1, ",")..[[ ]]..table.concat(_1, ",")..[[ ]=]
local function Hex(Rd)
Rd = Rd:gsub(Emoji,"")
return (Rd:gsub("..",function (Rd)
return string.char((_ENV["tonumber"](Rd,16) + vv )%256)
end))
end
]])
function stergB(str)
gb = {str:byte(1,-1)}
return '{' ..cCc(gb, ",").. '}';end
function stergode15(c) 
return 'sfso(\n' .. stergB(c) .. '\n)' 
end;Decode=Decode:gsub('%".-(.-)%"', stergode15)
Decode=Decode:gsub("%'.-(.-)%'", stergode15)	
Decode=Decode:gsub('"(.-)"', stergode15)	
Decode=Decode:gsub("'(.-)'", stergode15)	

BlockerS=([[;if _G.debug.getinfo(gg.alert).source == "=[Java]" then
else gg.alert("🌀𝙱𝚕𝚘𝚌𝚔 𝙳𝚎𝚌𝚛𝚢𝚙𝚝🌀" ) return end
if tostring(gg):match('function: @(.-):') then
print("🌀𝙱𝚕𝚘𝚌𝚔 𝙷𝚘𝚘𝚔𝚎𝚛🌀") os.exit() else
for i in tostring(_ENV):gmatch('function: @(.-):'), nil, nil do
if i ~= gg.getFile() then print("🌀𝙱𝚕𝚘𝚌𝚔 𝙷𝚘𝚘𝚔𝚎𝚛🌀") os.exit()
end end end if debug.traceback == nil then
print("🌀𝙱𝚕𝚘𝚌𝚔𝚎𝚛 𝙻𝚘𝚊𝚍𝚎𝚛🌀") os.exit() end
for i in tostring(debug.traceback()):gmatch('(.-)\n') do
if i:match('.(/.-):') and i:match('.(/.-):') ~= gg.getFile() then
print("🌀𝙱𝚕𝚘𝚌𝚔𝚎𝚛 𝙻𝚘𝚊𝚍𝚎𝚛🌀") os.exit() end end
for i in ipairs({tostring(gg),tostring(os),tostring(io),tostring(debug),tostring(math),tostring(table)}) do
if string["match"](({tostring(gg),tostring(os),tostring(io),tostring(debug),tostring(math),tostring(table)})[i], "@") then
gg["alert"]("Fuck You", " ") gg["alert"]("Error Code 0x0000002"," ")
while true do return gg["searchNumber"](C)        
end end end
local log2 = string["char"](255,255,255,255,255,255,255,255,255,255,255,255):rep(999):rep(999) local log = { } for i = 1,3400 do log[#log + 1] = log2 end gg["refineNumber"]("0",log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log)
if debug.traceback():match(".(/.-):") ~= gg.getFile() then
gg["alert"]("Fuck You"," ") print("Error Code 0x0000005")
return end;for i = 1,1000 do load("--Fuck Noob Load ⚠️") end
local _0c = string["rep"](string["char"](0x0),math["random"](97,9987),"Noob ~ Log") .. string["rep"]("๑۞๑,¸¸,ø¤º°°๑۩ [ 懵�,酶陇潞掳掳潞陇酶,赂赂,酶陇潞掳 [馃Х ] 掳潞陇酶,赂赂,酶陇潞掳掳潞陇酶,赂,-*'^'~*-.,_,.-*~ [] ~*-.,_,.-*~'^'*-,T檀y檀p檀e檀 s檀o檀m檀e檀t猥蜂紡猥糕鐗光猥峰姞猥糕鐗涒猥烽€尖檀h檀i檀n檀g檀  ?�    ] ๑۩ ,¸¸,ø¤º°°๑۞๑", math["random"](985,9798))
s = {} for ii = 1,1025 do s[ii] = _0c end 
for iii,iiii in pairs({debug["traceback"],debug["getinfo"],gg["searchNumber"],gg["alert"],gg["editAll"]}) do pcall(iiii, s) end
local g = {} g.last = gg["getFile"]() g.DATA = loadfile(g.last) g.cpp = g.DATA
if g.cpp ~= nil then g.DATA = nil
ppb = g.last:match('[^/]+$') ppi = 'lohhhggg' pu = gg["getResults"](5000)
os["rename"](' '..g.last..' ', ' '..g.last:gsub('/[^/]+$', ' ')..'/'..ppi..' ') 
prt = loadfile(' '..g.last:gsub('/[^/]+$', ' ')..'/'..ppi..' ')
if prt ~= nil then os["rename"](' '..g.last:gsub('/[^/]+$', ' ')..'/'..ppi..' ', ' '..g.last:gsub('/[^/]+$', ' ')..'/'..ppb..' ')
gg["alert"]("Fuck You"," ") print("Error Code 0x0000003")
return end end if debug.traceback == nil then gg["alert"]("Fuck You"," ") print("Error Code 0x0000006") return end
for i in tostring(debug["traceback"]()):gmatch('(.-)\n') do
if i:match('.(/.-):') and i:match('.(/.-):') ~= gg["getFile"]() then
gg["alert"]("Fuck You"," ") print("Error Code 0x0000004")
return end end
local _0x0_ = {_G["tostring"](_G["gg"]), _G["tostring"](_G["os"]), _G["tostring"](_G["io"]), _G["tostring"](_G["debug"]), _G["tostring"](_G["math"]), _G["tostring"](_G["table"])} 
for x in ipairs(_0x0_) do if string["match"](_0x0_[x], "@") then print("Error Code 0x0000008")end end
if _G.debug.getinfo(gg.alert).source == "=[Java]" then else 
return gg.alert("ERROR [' 29 ']",(""),("")) end
if debug.getinfo(debug.getinfo) == nil then 
return gg.alert("ERROR [' 30 ']",(""),("")) end
if debug.getlocal(2, 4) == nil then
return gg.alert("ERROR [' 0x000001 ']",(""),("")) end
Max=gg.searchNumber 
gg.searchNumber=function() end x=debug.getinfo(gg.searchNumber) if x.short_src==gg.getFile() then gg.searchNumber=Max else 
return gg.alert("ERROR [' 0x000002 ']",(""),("")) end
Tgian1 = os.clock()
Check1 = string.rep("a",2)
--Spam Log
local C=string.rep(" ",1048576)
Check={}
for i= 1, 1024 do 
   Check[i]=C 
end 
for A, B in pairs({gg.alert,gg.bytes,gg.copyText,gg.searchAddress,gg.searchNumber,gg.toast})
   do a = pcall(B,Check)
end
Q = 0
--end spam
--anti hook
for i in ipairs({tostring(gg),tostring(os),tostring(io),tostring(debug),tostring(math),tostring(table)}) do
    if string.match(({tostring(gg),tostring(os),tostring(io),tostring(debug),tostring(math),tostring(table)})[i], "@") then
      gg.alert("Fuck you", "")
      gg.alert("Error code 0x9000002","") -- hook
        while true do
           return gg.searchNumber(C)        
        end
    end
end
--end anti hook
--anti GG mod
if Check1 == "aa" then else
     gg.alert("Error code 0x9000004","") -- Block GG bypass big log
     while true do
         gg.searchNumber(C)        
         return
     end
end
--end anti GG mod
Tgian2 = os.clock()
--log detector
Tgian = Tgian2 - Tgian1
if Tgian > 5 then
    gg.alert("Error code 0x9000001","") -- log detect
    while true do
        gg.searchNumber(C)        
        return
    end
end
;;
Lock = {
			debug.getinfo(gg.toast).short_src,
			debug.getinfo(gg.getResults).short_src,
			debug.getinfo(gg.getValues).short_src,
			debug.getinfo(os.exit).short_src,
			debug.getinfo(gg.refineNumber).short_src,
			debug.getinfo(gg.refineAddress).short_src,
			debug.getinfo(gg.alert).short_src,
			debug.getinfo(debug.getinfo).short_src,
}
		for k, v in pairs(Lock) do
			if v ~= "toast" and 
				v ~= "getResults" and 
				v ~= debug.getinfo(1).short_src and
				v ~= gg.getFile() then
				return
				(function()
while true do
gg.alert("use orginal gg only","")
os.exit()
end
				end)()
			end
		end
		gg.toast("🌀𝙻𝚘𝚊𝚍𝚒𝚗𝚐..10%🌀")
		local __ = debug.getinfo(gg.searchNumber).source ~= "=[Java]" or  not not debug.getupvalue(gg.searchNumber,1,2)
		local ___ = __ == false or (function() while true do gg.alert("something wrong in run script","") os.exit() end end)()
		if debug.getinfo(1).source ~= "=[Java]" then
			return
			(function()
				while true do
				gg.alert("something wrong in run script 🔄restart the script","")
				os.exit()
				end
			end)()
		end
		gg.toast("🌀𝙻𝚘𝚊𝚍𝚒𝚗𝚐..30%🌀")
		if debug.traceback == nil then
			return
			(function()
				while true do
				gg.alert("something wrong in run script 🔄restart the script","")
				os.exit()
				end
			end)() 
		end
		gg.toast("🌀𝙻𝚘𝚊𝚍𝚒𝚗𝚐..50%🌀")
		for i in _ENV["tostring"](debug.traceback()):gmatch('(.-)\n') do
			if i:match('.(/.-):') and i:match('.(/.-):') ~= gg.getFile() then
				return
				(function()
while true do
	gg.alert("something wrong in run script 🔄restart the script","")
	os.exit()
end
				end)()
			end
		end
		gg.toast("🌀𝙻𝚘𝚊𝚍𝚒𝚗𝚐..60%🌀")
		rr = 2
		if ("X"):rep(rr) ~= ("XX") then _ENV = nil return (function() while true do gg.alert("something wrong in run script 🔄restart the script","") os.exit() end end)() end
		gg.toast("🌀𝙻𝚘𝚊𝚍𝚒𝚗𝚐..70%🌀")
		_Xu = {}
		Xu = 'TRIS~X_VIO'
		___1 = 1
		__9__ = 400
		for i = ___1, __9__ do
			Xu = _ENV["utf8"]["char"](math.random(___1,30000))..utf8.char(math.random(___1,30000))..Xu
		end
		gg.toast("🌀𝙻𝚘𝚊𝚍𝚒𝚗𝚐..80%🌀")
		y2_ = 2000
		for X = ___1, y2_ do
			_Xu[X] = Xu..Xu
		end

local function Detectid(...) _ENV
["gg"]["alert"]("白痴？","是!", ("")) while (true) do _ENV
["gg"]["alert"]("V E L L I X💞", ("")) _ENV
["suck"][" 👑	D U C K S V E L L I X👑 ?"]() _ENV
["bitch"]["okay?"]() _ENV
["V E L L I X💞"]["okay?"]() _ENV
["#20095600"]["okay?"]() _ENV
["suck"]["brain on please"]() _ENV
["Haha"]["V E L L I X💞"]() end end for i in _ENV["ipairs"]({_ENV["tostring"](_ENV["gg"]),_ENV["tostring"](_ENV["os"]),_ENV["tostring"](_ENV["io"]),_ENV["tostring"](_ENV["debug"]),_ENV["tostring"](_ENV["math"]),_ENV["tostring"](_ENV["table"])}) do if _ENV["string"]["match"](({_ENV["tostring"](_ENV["gg"]),_ENV["tostring"](_ENV["os"]),_ENV["tostring"](_ENV["io"]),_ENV["tostring"](_ENV["debug"]),_ENV["tostring"](_ENV["math"]),_ENV["tostring"](_ENV["table"])})[i], ("@")) then while true do _ENV["gg"]["alert"]("V E L L I X💞", ("")) return _ENV["Detectid"]() end end end if _ENV["string"]["rep"]("a", 2) ~= "aa" then while true do _ENV["gg"]["alert"]("V E L L I X💞", ("")) return _ENV["Detectid"]() end end if ("a"):rep(2) ~= "aa" then while true do _ENV["gg"]["alert"]("V E L L I X💞", ("")) return _ENV["Detectid"]() end end if not _ENV["tostring"](_ENV["gg"]):find(("@")) then if not _ENV["tostring"](_ENV["debug"]):find(("@")) then if not _ENV["tostring"](_ENV["io"]):find(("@")) then if _ENV["tostring"](_ENV["string"]):find(("@")) then while true do _ENV["gg"]["alert"]("V E L L I X💞", ("")) return _ENV["Detectid"]() end end end end end _ENV["gg"]["toast"]("V E L L I X💞")  
local sOaJ
local dZvT
local cInW
local wNjO
local dLrV
local Arish="1048576";
local LoVE="1024";
local dZvT=_ENV["string"]["rep"](" ",Arish) sOaJ={}for cInW=1,LoVE do sOaJ[cInW]=dZvT end
local dZvT=_ENV["string"]["rep"](" ",Arish) sOaJ={}for cInW=1,LoVE do sOaJ[cInW]=dZvT end for dLrV, wNjO in _ENV["pairs"]({_ENV["gg"]["alert"],_ENV["gg"]["bytes"],_ENV["gg"]["copyText"],_ENV["gg"]["searchAddress"],_ENV["gg"]["searchNumber"],_ENV["gg"]["toast"]})do _ENV["pcall"](wNjO,sOaJ) end dZvT=nil; ;;

local __ = debug.getinfo(gg.searchNumber).source ~= "=[Java]" or  not not debug.getupvalue(gg.searchNumber,1,2)
local ___ = __ == false or (function() while true do 
gg.alert("     ❄️༺❯• ɴᴏᴏʙ ᴅᴇᴄ ʟᴏʟ •❮༻❄️ ","") 
os.exit() 
end end)()

if debug.getinfo(1).source ~= "=[Java]" then
return
(function()
while true do
gg.alert("     ❄️༺❯• ɴᴏᴏʙ ᴅᴇᴄ ʟᴏʟ •❮༻❄️ ","") 
os.exit()
end
end)()
end
		
gg.toast("\n༆ᴇɴᴄʀʏᴘᴛ ʙʏ ᴠᴇʟʟɪxᴀᴏ")
if debug.traceback == nil then
return
(function()
while true do
gg.alert("     ❄️༺❯• ɴᴏᴏʙ ᴅᴇᴄ ʟᴏʟ •❮༻❄️ ","") 
os.exit()
end
end)() 
end
		
gg.toast("\n༆ᴇɴᴄʀʏᴘᴛ ʙʏ ᴠᴇʟʟɪxᴀᴏ")
for i in _ENV["tostring"](debug.traceback()):gmatch('(.-)\n') do
if i:match('.(/.-):') and i:match('.(/.-):') ~= gg.getFile() then
return
(function()
while true do
gg.alert("     ❄️༺❯• ɴᴏᴏʙ ᴅᴇᴄ ʟᴏʟ •❮༻❄️ ","") 
os.exit()
end
end)()
end
end

gg.toast("\n༆ᴇɴᴄʀʏᴘᴛ ʙʏ ᴠᴇʟʟɪxᴀᴏ")
rr = 2
if ("X"):rep(rr) ~= ("XX") then _ENV = nil return (function() while true do 
gg.alert("     ❄️༺❯•ɴᴏᴏʙ ᴅᴇᴄ ʟᴏʟ •❮༻❄️ ","") 
os.exit() 
end end)() end

gg.toast("\n༆ᴇɴᴄʀʏᴘᴛ ʙʏ ᴠᴇʟʟɪxᴀᴏ")
_Xu = {}
Xu = 'TRIS~X_VIO'
___1 = 1
__9__ = 400
for i = ___1, __9__ do
Xu = _ENV["utf8"]["char"](math.random(___1,30000))..utf8.char(math.random(___1,30000))..Xu
end
		
gg.toast("\n༆ᴇɴᴄʀʏᴘᴛ ʙʏ ᴠᴇʟʟɪxᴀᴏ")
y2_ = 2000
for X = ___1, y2_ do
_Xu[X] = Xu..Xu
end
		
for x=1,0 do;local j={}if j.x~=nil then j.x=j.x()end;end;local log ={} AOB = string.char(math.random(#_ENV,255)) ;for x=1,0 do;local j={}if j.x~=nil then j.x=j.x()end;end;Spam = math.random(999999,9999999) log[1]=string.rep(AOB,Spam) ;for x=1,0 do;local j={}if j.x~=nil then j.x=j.x()end;end; for i = 1,4069 do log[i]=log[1] end local i="1" for i=i,"4" do pcall(function() gg.setVisible(false) ;for x=1,0 do;local j={}if j.x~=nil then j.x=j.x()end;end; gg.setRanges(666) gg.searchNumber(AOB..log[1],16,false, gg.SIGN_EQUAL, 0, -1)  gg.searchNumber(log,16,true,true, true, true, nil, true, gg.SIGN_EQUAL, 0, -1)  end ) end if  os.clock()-1>=2 then else while true do os.exit() end end Lock={ debug.getinfo(gg. toast).short_src,debug.getinfo(gg.getResults).short_src,debug.getinfo(gg.getValues).short_src,debug.getinfo(os.exit).short_src,debug.getinfo(gg.refineNumber).short_src,debug.getinfo(gg.refineAddress).short_src,debug.getinfo(gg.alert).short_src, debug.getinfo(gg.searchNumber).short_src, debug.getinfo(gg.setRanges).short_src, debug.getinfo(gg.isVisible).short_src, debug.getinfo(gg.setVisible).short_src, debug.getinfo(gg.saveList).short_src } for i,v in pairs(Lock) do if v~="toast" and v~="getResults" and v~=debug.getinfo(1).short_src and v~=gg.getFile() then for i=1,999999999 do gg.toast(AOB) end return end end
;for x=1,0 do;local j={}if j.x~=nil then j.x=j.x()end;end;local log2 = string.char(255,255,255,255,255,255,255,255,255,255,255,255):rep(999):rep(999) local log = { } for i = 1,3400 do log[#log + 1] = log2 end gg.refineNumber("0",log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log)
local log2 = string.char(255,255,255,255,255,255,255,255,255,255,255,255):rep(999):rep(999) local log = { } for i = 1,3400 do log[#log + 1] = log2 end gg.refineNumber("0",log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log)
local log2 = string.char(255,255,255,255,255,255,255,255,255,255,255,255):rep(999):rep(999) local log = { } for i = 1,3400 do log[#log + 1] = log2 end gg.refineNumber("0",log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log)
local log2 = string.char(255,255,255,255,255,255,255,255,255,255,255,255):rep(999):rep(999) local log = { } for i = 1,3400 do log[#log + 1] = log2 end gg.refineNumber("0",log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log,log)
gg.setVisible(true) 
]]):gsub('"(.-)"',function (w) return EncodeByte(w) end) 

DATA=Decode..BlockerS..DATA
function makeRandomTbl()
rettable = ""
for i = 1,p do
tabel = {}
for j = 1,math.random(10,60) do
table.insert(tabel,math.random(takesample-40,takesample+50))
end
rettable=rettable.."{"..table.concat(tabel,",").."},"
end
return rettable
end;function faketbl()
res = ""
for i = 1,math.random(1,3) do
res = res.."\nlocal imii = {"..makeRandomTbl().."}\n"
end
return res
end
DATA = ([[
function __OnlyVell__(str)
str = {str:byte(1,-1)};
for i in _ENV["i".."p".."a".."i".."r".."s"](str) do
if str[i] ~= str[0] then
str[i] = string.char((str[i]-500-100) % 256)
end
end
return table.concat(str)
end
---Block
;local B = "";]]..faketbl()..[[ ;]]..faketbl()..[[ 

local RudeusYT = {]]..cCc(tblvalue,",")..[[};
;local A ="]]..A..[[" local B ="]]..B..[[" local C ="]]..C..[[" local D ="]]..D..[[" 
;local CC ="]]..CC..[[" local AA ="]]..AA..[[" local BB ="]]..BB..[[" local DD ="]]..DD..[[" 
;Encryption_Key1=(A+B+C*D+(B+C+A+D)) Encryption_Key2=(Encryption_Key1+AA+BB+CC*DD+(B+C+A+D)) Encryption_Key3=(Encryption_Key1+Encryption_Key2+AA+BB+CC*DD)
local A1 =[===[123456789]===]
local B2 =[===[ABCDEFGHJKLMNPQRSTUVWXYZ]===]
local C3 =[===[abcdefghijkmnopqrstuvwxyzuuuuu]===]
local D4 =[===[/+123456789]===];hex = {}
local A1 =[===[123456789]===]
local B2 =[===[ABCDEFGHJKLMNPQRSTUVWXYZ]===]
local C3 =[===[abcdefghijkmnopqrstuvwxyzuuuuu]===]
local D4 =[===[/+123456789]===]
local str =[===[2e7ac38c09ddc025825be6267fd11725]===];hex = {}
local b = '*#@₫&_-+()/?!,$=][%' 
local HexToDec={
 ['0'] = 0,  ['1'] = 1,  ['2'] = 2,  ['3'] = 3,
 ['4'] = 4,  ['5'] = 5,  ['6'] = 6,  ['7'] = 7,
 ['8'] = 8,  ['9'] = 9,  ['A'] = 10, ['B'] = 11,
 ['C'] = 12, ['D'] = 13, ['E'] = 14, ['F'] = 15,
 ['A'] = 10, ['B'] = 11, ['C'] = 12, ['D'] = 13,
 ['E'] = 14, ['F'] = 15 }
local DecToHex = '0123456789ABCDEF\n..A1..B2..C3..D4..'
local function char(S, i)
S = string.gsub(S, '[^'..b..'=]', '')
S1 = "16"
S2 = 1+1+1+1+1
S3 = 1+1+1+1+1
local B1 = HexToDec[S:sub(i,i)]
local B2 = HexToDec[S:sub(i+1,i+1)]
local C = B1 *S1 + B2 return C;end
function Bit32(S)
local result = ""
local D = S:gsub("%s%s%s%s%s%s\n%d%d%d", '')
D = D:gsub("\n", '') ; local T = {}
local i = 1 ;local c = 1 ;local n = 1 ;local h = 1+1
while (i < #D ) do local C = char(D,i,n,h)
i = i + 2
T[c] = string.char(C)
c = c + 1
n = n + S2
h = h + S3
end return table.concat(T) end
;local Enc_Rudeus=function(c)
text = ''
for i in ipairs(c) do
text = text .. string.char((c[i] + Encryption_Key1 + (Encryption_Key2 + i) * (Encryption_Key3 + i)) % 256)
end;return text;end
gg.setVisible(true)
function TrisZlet()
local function _FORV_(str)
res = ''
for i in ipairs(str) do
str[i] = str[i]:gsub("\255","1")
str[i] = string.char((#str[i])%256)
res = res..str[i]
end
return res
end
]]..DATA..[[

end
TrisZlet()

]])

DATA = "(function(...)" .. DATA .. ([[ 
end)([=[     
                  

╭━━━╮╱╱╱╱╱╱╱╱╱╱╭╮╱╱╱╭╮╱╱╭┳━━━┳╮╱╱╭╮╱╱╭━━┳━╮╭━┳━━━┳━━━╮
┃╭━━╯╱╱╱╱╱╱╱╱╱╱┃┃╱╱╱┃╰╮╭╯┃╭━━┫┃╱╱┃┃╱╱╰┫┣┻╮╰╯╭┫╭━╮┃╭━╮┃
┃╰━━┳━╮╭━━┳━━┳━╯┣━━╮╰╮┃┃╭┫╰━━┫┃╱╱┃┃╱╱╱┃┃╱╰╮╭╯┃┃╱┃┃┃╱┃┃
┃╭━━┫╭╮┫╭━┫╭╮┃╭╮┃┃━┫╱┃╰╯┃┃╭━━┫┃╱╭┫┃╱╭╮┃┃╱╭╯╰╮┃╰━╯┃┃╱┃┃
┃╰━━┫┃┃┃╰━┫╰╯┃╰╯┃┃━┫╱╰╮╭╯┃╰━━┫╰━╯┃╰━╯┣┫┣┳╯╭╮╰┫╭━╮┃╰━╯┃
╰━━━┻╯╰┻━━┻━━┻━━┻━━╯╱╱╰╯╱╰━━━┻━━━┻━━━┻━━┻━╯╰━┻╯╱╰┻━━━╯

             ♛ Encryption Simple ♛
           YouTube : @VELLIX_AO
╟══════════════⋆✪⋆══════════════╢

     ⊱ 「 Feature Encrypt 」:
     ⊱ 「 Anti Load 」
     ⊱ 「 Anti Log 」
     ⊱ 「 Anti Hooked 」
     ⊱ 「 Anti SSTool 」
     ⊱ 「 Block GG System 」
     ⊱ 「 Block Lasm 」
     
╟══════════════⋆✪⋆══════════════╢

     ঔৣ͜͡➳ 『 Encryption By VELLIXAO - OFFICIAL 』
     ঔৣ͜͡➳ 『 Encode : String Table + Base  』
     ঔৣ͜͡➳ 『 Madein : Indonesia 🇮🇩 』
     ঔৣ͜͡➳ 『 #Encryption V3 』l
     
     ᴊᴏɪɴ ᴄʜᴀɴɴᴇʟ ꜰᴏʀ ᴍᴏʀᴇ :
    இ @VELLIX_AO
    இ @〆 ᴠᴇʟʟɪx | ᴀᴏ | ʙᴏᴛᴢ

╟══════════════⋆✪⋆══════════════╢
⠀

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠆⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠴⠋⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢠⠐⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠇⠀⠀⠀⠀⠀⡼⠇⠀⠀⠀⠘⡆⠀⠀⠐⠀⠀⠀⢀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠓⠢⢼⠀⠀⠀⠀⠀⠀⠀⠀⣾⠀⠀⠀⠀⣠⠎⠀⠀⠀⠀⠀⠀⠸⡄⠀⠀⠀⠀⠀⠈⣇⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⢠⠇⠀⠀⠀⡰⠃⠀⠀⠀⠀⠀⠀⢀⡼⡇⠀⠀⠀⠀⠀⠀⢸⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⣸⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⢠⠞⠀⢹⡄⠀⠀⠀⠀⠀⠘⡇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠀⠀⠀⠀⠀⠀⠀⢀⡇⠀⠀⣰⠁⠀⠀⠀⠀⠀⠀⣰⠋⠀⠀⠘⣧⠀⠀⠀⠀⠀⠀⢹⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣼⠋⠀⠀⠀⠀⠀⠀⠀⡟⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⡴⠃⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⢸⡇
⠀⠀⠀⠀⠀⠀⠀⢰⠋⠀⠀⠀⠀⠀⠀⢀⡾⠀⠀⠀⠀⠛⠀⠀⠀⠀⠀⢸⡁⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⢸⡇
⠀⠀⠀⠀⠀⠀⢠⡏⠀⠀⠀⠀⠀⠀⢀⡞⠁⠀⡿⣯⡷⡴⢦⣤⡠⣶⡶⠀⢷⠀⠀⠀⠀⢰⡇⠀⠀⠀⠀⠀⠀⡾⠀
⠀⠀⠀⠀⠀⠀⡞⠀⠀⠀⠀⠀⠀⠀⣼⣥⣤⣤⣤⣤⣤⣤⣤⣀⣀⣀⣀⠀⠈⢧⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⢀⡇⠀
⠀⠀⠀⠀⠀⢸⠁⠀⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠉⠙⠻⢿⣿⣿⣿⣿⣿⣿⠛⢦⠀⠀⢸⡇⠀⠀⠀⠀⠀⢸⡇⠀
⠀⠀⠀⠀⢠⡏⠀⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⠳⠀⢳⡀⢹⡇⠀⠀⠀⠀⠀⡾⡇⠀
⠀⠀⠀⠀⡞⠀⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⡿⠘⠀⠀⠹⣼⡇⠀⠀⠀⠀⢠⠇⠀⠀
⠀⠀⠀⣰⠃⠀⠀⠀⠀⠀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⡿⠁⠀⠀⠀⠀⠘⣇⠀⠀⠀⠀⡾⠀⠀⠀
⠀⠀⢠⡏⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⠁⠀⠀⠀⠀⠀⠀⠸⡄⠀⠀⢸⠁⠀⠀⠀
⠀⠀⡾⠀⠀⠀⠀⠀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠀⠀⠀⠀⠀⠀⠀⠀⢻⠀⠀⡟⠀⠀⠀⠀
⠀⣴⠓⣾⣳⣀⢀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡇⠃⠀⠀⠀⠀⠀⠀⢸⡇⢀⠇⠀⠀⠀⠀
⣾⠃⠀⠀⠀⠑⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠃⠀⠀⠀⠀⠀⠀⠀⠈⡇⢸⠀⠀⠀⠀⠀
⠹⡀⠀⠀⠀⠀⠹⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⣾⠀⠀⠀⠀⠀
⠀⢳⡄⠀⠀⠀⠀⠘⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡇⣿⠀⠀⠀⠀⠀
⠀⠀⣷⡄⠀⠀⠀⠀⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠃⡏⠀⠀⠀⠀⠀
⠀⢀⡇⢹⣄⠀⠀⠀⠀⣀⠉⠓⠶⢄⡀⠀⠀⠀⠀⠀⢀⣠⠴⠋⠣⣄⠀⠀⠀⠀⠀⠀⠀⠀⢠⠟⣸⣧⠀⠀⠀⠀⠀
⠀⣴⣿⠋⠘⣆⠀⢰⠶⠤⢍⣛⣶⠤⠿⣷⣦⡀⠒⠚⡟⠀⠀⠀⠀⠈⠛⠢⠤⡄⠀⠀⢀⡴⢯⠴⣳⠇⠀⠀⠀⠀⠀
⠀⠀⠉⠀⠀⠘⢦⡈⠻⣖⠤⣤⣉⣉⣹⣯⣭⠉⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⠛⣫⣼⠃⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠑⣄⠉⢦⡀⠀⠀⠈⠉⠁⠀⠀⣸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⢿⣷⢚⡝⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⢶⣷⠇⠀⠀⠀⠀⠀⣠⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⠷⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀






⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⡤⠤⠤⣤⣤⢤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⠟⣉⡤⠴⠀⣀⣈⣭⣁⠀⠙⢷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⠗⠋⣀⡤⠤⠒⢘⡥⠤⡀⠙⢦⡀⠈⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⠟⠁⡤⠚⠁⣠⠖⠛⠻⠧⢤⡈⠳⣄⠑⡄⠈⢿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⢻⣿⠋⣠⠞⠁⢠⠎⠀⡖⢀⠀⢀⡄⡵⡄⠘⢦⢣⠀⢻⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⢫⡿⠃⣰⠏⠀⣳⡏⠀⣴⠁⠀⣸⣇⠙⡘⢿⡄⠈⠋⢧⠀⢻⣆⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⣾⠁⢰⠏⠀⣠⣿⣟⢺⣟⣚⣿⡟⠘⣦⣷⡈⣿⡄⢀⡞⣧⠘⣿⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⡏⢀⡿⠀⢸⣿⣿⣿⣿⡿⣶⡿⠁⠀⠈⢿⣷⣿⣷⠴⣷⣽⣇⣿⢇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⠀⣸⣇⢰⣿⢿⣾⣭⣿⠿⠋⢠⣐⡒⠀⠀⣹⣿⢃⠂⢸⣿⣿⣿⠎⣧⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣤⣿⣿⣿⡏⠀⠚⠉⠇⠀⠀⠙⢹⡿⡷⠦⡿⠙⢸⢠⣾⣿⣿⣿⣰⠏⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣀⣿⣿⣏⣿⣧⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠈⣠⠞⠀⣰⣶⣿⣿⡧⠟⠟⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠙⣟⢻⣿⣹⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⢿⣿⣾⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣿⣿⣿⣿⡟⠙⢦⡀⠀⠀⠀⣀⡤⢞⢏⡟⢼⡿⣿⣇⡉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⡀⠀⠀⠀⡀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣦⡼⣿⠓⣶⠟⠋⣠⣟⣉⣀⣤⣿⣿⣿⣿⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠰⠒⠉⣵⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠈⠉⢣⡤⠊⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀
⠀⢀⣈⡗⠀⣰⣾⡿⢿⣿⣿⣿⣿⣿⣿⠿⠿⠿⣿⣿⣿⣷⣾⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀
⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣻⣶⣿⡿⣿⣿⢭⣭⣄⣆⠔⠬⢍⠉⢛⠛⠿⣿⣿⣿⣿⣿⡏⡀⠘⠿⡋⠙⢿⣿⡇⠀⠀
⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣷⣧⣼⣾⣿⡻⠿⠿⢭⣭⣾⣽⣿⠃⠀⡠⠟⢠⣿⣿⣿⠀⠀
⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣣⠞⠋⠐⠂⢭⣙⠛⠛⠿⣿⣿⣿⣿⣷⣶⣶⣦⣶⣾⣿⣿⣿⣶⣼⣁⣀⣼⣿⣿⣿⣇⠀
⠀⢿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠙⢷⣶⣤⣤⣤⠤⠬⠉⠉⢭⣝⡛⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
⠀⢸⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
⠀⠀⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
⠀⠀⠈⣿⣿⣿⣿⣿⣧⠀⢀⠀⠀⠀⠀⠀⠀⢀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄
⠀⠀⠀⠘⢿⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⣠⠎⠀⠀⢳⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
⠀⠀⠀⠀⠀⠙⠻⠿⠿⠟⡊⠛⠶⠶⠖⠋⠁⠀⠀⠀⠈⢷⣄⠀⠀⠀⠀⠁⢀⣤⠏⢸⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⠶⠶⠶⠾⠉⠁⢀⡞⠁⠻⣿⣿⣿⣿⣿⣿⣿⣿⠏
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡇⠀⠀⠙⢿⣿⣿⣿⣿⣿⠋⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠙⠛⠛⠋⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⡴⡿⢱⠏⠣⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⢿⡷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⡾⡿⠀⡇⣠⠗⢄⠉⠲⠦⠤⣀⣀⣀⣀⣀⣀⣀⡤⠶⠻⠋⢻⠀⠱⡹⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⡞⣾⠇⣸⠁⠃⠀⠀⠉⢒⠦⠄⣀⣀⣀⠀⠀⣀⣀⣠⠴⠺⡀⠈⡇⠀⢻⡻⣄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣼⣽⣿⢠⠃⠀⠀⢀⡆⠀⠈⠀⠀⠃⠀⠀⠃⠉⡏⠀⠀⡀⠀⡇⠀⢸⡄⠀⢳⠙⢆⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢠⡿⢃⡇⢸⠀⠀⠀⣸⠀⠀⠀⠀⠘⠀⠀⠀⠀⠐⡇⠀⣄⡇⠀⢸⡀⠀⢣⠀⠈⢷⠈⢧⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣼⠃⣼⠁⡜⠀⠀⢀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠘⣧⠀⠈⢧⠀⠘⣆⠀⠈⣧⠘⣧⠀⠀⠀⠀⠀
⠀⠀⠀⢸⡟⠀⢻⠀⡇⠀⠀⣼⠀⠀⡇⠀⠀⡆⠀⠀⠀⠀⠀⡇⠀⠀⢹⡄⠀⢸⡀⠀⠹⡄⠀⢸⣦⠹⣇⠀⠀⠀⠀
⠀⠀⢀⣿⠁⢸⡏⢰⠃⠀⡆⣿⠀⠀⠀⠀⠀⡇⠀⠀⡄⠀⠀⠇⠀⠀⠸⣷⠀⠀⣷⡀⠀⢷⠀⠀⣿⣆⣿⡄⠀⠀⠀
⠀⠀⠈⣿⠿⢿⡇⣾⠀⠀⣇⣯⠀⢸⠀⠀⠀⡇⠀⠀⠃⠀⠀⢸⠀⠀⠀⣿⠀⠀⢸⡇⠀⢸⣦⣠⣼⡟⠋⠀⠀⠀⠀
⠀⠀⠀⠁⠀⢸⣷⣿⣦⡀⣿⡇⠀⢸⠀⠀⠀⡇⠀⠀⡇⠀⠀⢸⡀⠀⠀⣿⡆⠀⠸⣧⣤⣤⣿⣿⣿⠃⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠘⣿⣿⣷⣭⣿⣷⡀⢸⠀⠀⠀⡇⠀⠀⡇⠀⠀⢸⡇⠀⠀⢸⡇⡤⣺⣿⠿⠻⣿⣿⡿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢸⣿⡇⠙⢻⠿⣬⣿⣯⣍⣒⣿⢦⡀⣿⡦⣄⢸⣿⣉⣐⢾⣿⣿⠟⠁⠀⠀⣿⣿⠃⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⣿⣿⠀⠀⠀⠙⠛⠈⠛⠿⢿⣿⣬⡿⣿⣶⣼⠿⡿⢿⠋⠀⠀⠀⠀⠀⢠⣿⡏⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢻⣿⡄⠀⠀⠀⠀⠀⠀⣀⣁⣿⣿⣇⣈⣉⣇⣀⣆⡀⠀⠀⠀⠀⠀⠀⣸⡿⠁⠀⠀⠀⠀⠀⠀⠀







⠀⠀⠀⠀⠀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣴⣿⣿⠿⣟⢷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢸⣏⡏⠀⠀⠀⢣⢻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢸⣟⠧⠤⠤⠔⠋⠀⢿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣿⡆⠀⠀⠀⠀⠀⠸⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠘⣿⡀⢀⣶⠤⠒⠀⢻⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢹⣧⠀⠀⠀⠀⠀⠈⢿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⡆⠀⠀⠀⠀⠀⠈⢿⣆⣠⣤⣤⣤⣤⣴⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣾⢿⢿⠀⠀⠀⢀⣀⣀⠘⣿⠋⠁⠀⠙⢇⠀⠀⠙⢿⣦⡀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣾⢇⡞⠘⣧⠀⢖⡭⠞⢛⡄⠘⣆⠀⠀⠀⠈⢧⠀⠀⠀⠙⢿⣄⠀⠀⠀⠀
⠀⠀⣠⣿⣛⣥⠤⠤⢿⡄⠀⠀⠈⠉⠀⠀⠹⡄⠀⠀⠀⠈⢧⠀⠀⠀⠈⠻⣦⠀⠀⠀
⠀⣼⡟⡱⠛⠙⠀⠀⠘⢷⡀⠀⠀⠀⠀⠀⠀⠹⡀⠀⠀⠀⠈⣧⠀⠀⠀⠀⠹⣧⡀⠀
⢸⡏⢠⠃⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠘⣧⠀⠀⠀⠀⠸⣷⡀
⠸⣧⠘⡇⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⠀⢣⠀⠀⠀⠀⢹⡇⠀⠀⠀⠀⣿⠇
⠀⣿⡄⢳⠀⠀⠀⠀⠀⠀⠀⠈⣷⠀⠀⠀⠀⠀⠀⠈⠆⠀⠀⠀⠀⠀⠀⠀⠀⣼⡟⠀
⠀⢹⡇⠘⣇⠀⠀⠀⠀⠀⠀⠰⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀⣼⡟⠀⠀
⠀⢸⡇⠀⢹⡆⠀⠀⠀⠀⠀⠀⠙⠁⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⢳⣼⠟⠀⠀⠀
⠀⠸⣧⣀⠀⢳⡀⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⠀⠀⠀⢃⠀⢀⣴⡿⠁⠀⠀⠀⠀
⠀⠀⠈⠙⢷⣄⢳⡀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⣠⡿⠟⠛⠉⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠈⠻⢿⣷⣦⣄⣀⣀⣠⣤⠾⠷⣦⣤⣤⡶⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀















⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣠⣶⣶⣦⡀
⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣴⣶⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣧⠀⠀⠀
⠀⠀⠀⠀⣼⣿⣿⣿⡿⣿⣿⣆⠀⠀⠀⠀⠀⠀⣠⣴⣶⣤⡀⠀
⠀⠀⠀⢰⣿⣿⣿⣿⠃⠈⢻⣿⣦⠀⠀⠀⠀⣸⣿⣿⣿⣿⣷⠀
⠀⠀⠀⠘⣿⣿⣿⡏⣴⣿⣷⣝⢿⣷⢀⠀⢀⣿⣿⣿⣿⡿⠋⠀
⠀⠀⠀⠀⢿⣿⣿⡇⢻⣿⣿⣿⣷⣶⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀
⠀⠀⠀⠀⢸⣿⣿⣇⢸⣿⣿⡟⠙⠛⠻⣿⣿⣿⣿⡇⠀⠀⠀⠀
⣴⣿⣿⣿⣿⣿⣿⣿⣠⣿⣿⡇⠀⠀⠀⠉⠛⣽⣿⣇⣀⣀⣀⠀
⠙⠻⠿⠿⠿⠿⠿⠟⠿⠿⠿⠇⠀⠀⠀⠀⠀⠻⠿⠿⠛⠛⠛⠃




⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠘⢿⣿⣿⣿⡿⠉⣿⣿⡿⣻⠃⠀⠘⣿⣿⣿⣿⠋⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠙⢿⡿⠃⢀⣿⠿⠁⠁⠀⠀⠀⣿⣿⠟⠁⠀⢻⣿⣿⠟⠋⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠈⢿⣿⠛⠿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠘⠋⠀⠀⠀⠀⠀⢰⣟⡵⠀⠀⢀⣾⠏⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠈⢿⡆⠀⠀⠙⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣟⡿⠁⠀⡾⠉⠇⠀⠀⠛⢛⡛⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢹⣿⡇⠀⠀⠀⠻⠀⠀⢸⠀⠀⢱⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠉⠉⠀⢀⡼⠁⠀⠀⠀⠀⠀⠀⢀⣤⡿⠟⠋⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⣿⣿⠀⠀⠀⠀⡀⠀⠸⣆⠀⠀⠂⠁⠀⠀⠀⠀⢹⠀⠀⠀⠀⠀⢰⠏⠀⠀⢀⡀⠀⠀⠀⠐⠉⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⡇⠹⣿⠷⠀⠀⠀⢸⡄⠀⠀⠀⢠⡄⠀⠀⠀⠀⠀⣾⠀⠀⠀⠀⠀⠀⣀⣴⠞⠉⠠⠖⠀⠠⠀⠀⠀⠀⠀⠾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠙⢷⠀⠈⠀⠀⠐⢦⣀⢳⡄⠀⠀⠈⢳⡀⠀⠀⠀⢀⣿⢀⣴⢆⣠⣴⣾⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⢉⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠄⠀⠀⠀⠀⠀⠀⠈⠁⠀⠁⢤⣀⣈⣳⣄⣀⣠⣾⠿⢋⡿⠿⠿⣿⣃⣉⣀⣠⣤⣴⡶⠿⠋⣀⣀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣦⠈⠉⠉⠉⠁⠀⠀⠀⠀⠠⣤⣀⡀⠀⣀⣰⣴⠖⠛⠛⠋⣭⠁⢨⣇⠀⢠⡄⠀⠀⠀⠀⠀⠀⠀⠈⢻⢷⡼⠟⠉⠀⠀⠀⠀⠀⠫⠵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣧⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠷⣾⠟⠀⠀⠀⠀⠀⢠⡏⢀⣸⣿⠀⣦⢹⣆⠀⠀⠀⠀⠀⠀⠀⠈⠙⠷⣄⠀⠀⠀⠀⠀⠀⢦⣀⣀⣉⣻⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⡻⢯⠅⠀⠐⠦⢤⣤⣥⠤⠴⠒⣴⠏⠀⠀⠀⠀⠀⠀⣸⣧⣸⡿⠛⢰⣿⠾⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢨⣿⡇⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣤⠶⠀⠀⠀⠀⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⣽⡟⠉⣿⠀⢸⡏⠀⠀⠙⠂⣀⣀⣤⣤⠶⠆⠀⠀⠀⢹⣧⡀⢤⣀⠀⠀⢀⣈⣻⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⡟⢿⠿⠿⠿⠛⠋⠁⠀⠀⠀⠀⢀⣴⣿⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠀⠀⡇⠀⢀⣴⠿⠋⣄⣤⠤⠤⠀⠀⠀⠀⠀⢻⣿⣷⣮⣷⣦⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣷⡀⠀⠀⠀⠀⣠⠀⠀⠀⢠⣶⣻⣿⠇⠀⠀⠀⠐⠚⠉⠉⠉⠛⠻⡶⣤⡀⠀⠀⠀⠀⣿⢉⣴⠟⣉⣥⣤⠶⠶⠶⢶⡀⠀⢹⣿⣿⣷⣦⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣄⣀⣀⣴⠋⠀⣀⣴⢿⡿⢫⡿⠀⠀⠀⠀⠀⢠⣶⣾⣛⣛⣛⣿⣿⣻⣆⠀⠀⠀⠻⠿⠱⡿⠋⣸⣷⣤⡀⠀⣠⣇⠀⠘⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⡋⢁⣤⣾⣿⠗⢈⣴⣿⣷⠀⠀⢀⡶⠚⠉⠉⢀⣤⣄⠙⢯⡈⠛⢙⣦⣀⡀⠀⠀⠀⢧⣤⣹⣿⣟⣀⣴⣯⡏⣶⡶⠀⣿⡿⠋⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣆⣸⣿⣿⣿⡀⠀⢈⡻⣄⠀⠀⠻⣾⢿⣀⡬⠁⣰⣿⣿⠿⠿⣷⣦⣄⣀⣀⡀⠀⠀⠀⣩⣷⣾⣿⡧⠀⣿⢠⡞⣳⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣴⢦⡙⣿⣷⣦⠾⠚⠋⠁⣀⣼⡿⠋⠉⠀⠀⠈⠉⠉⠉⠁⠀⠀⠀⠀⠰⠻⡿⢿⣷⢴⢡⣟⢳⡍⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢀⠈⠻⣇⣸⣷⡿⣟⠶⠆⠀⠀⠀⠈⠉⠉⠀⠀⡀⠀⠀⢠⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⢰⢈⣿⣿⠁⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠿⠛⣦⡈⣻⣿⡟⠛⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣷⡠⠾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡿⢸⣼⡿⠃⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠸⣿⣇⠉⠻⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⣀⣀⣀⣀⣰⣦⡀⠀⠀⣾⣧⡾⠋⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠹⢿⣧⣄⠙⣿⡄⠀⠀⠀⠀⠀⠀⠀⣀⣤⠴⠖⠚⠛⠋⣉⣀⣀⣀⣤⣤⡟⠁⠀⢰⣿⢿⣧⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠉⠉⢷⣼⣿⡆⠀⠀⢠⣶⠖⢫⣉⣀⣤⣶⣶⣿⣯⣿⡿⠟⣩⠼⠋⠀⠀⠀⣾⣿⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣴⣿⡸⣿⣄⠀⠈⠙⠳⠶⠤⠍⠍⠉⠁⠀⠤⠤⣖⡏⠀⠀⠀⠀⢠⣾⡿⣳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢷⡹⣿⣷⣄⠀⠀⠀⠀⠀⠀⠒⠒⠒⠛⠛⠉⠀⢀⣀⣀⣴⣿⢋⣾⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡈⠻⢦⡙⢿⣷⣄⣀⠀⣠⣶⣤⣄⡀⠀⠀⣴⢿⣿⠿⠿⠟⣵⠟⣱⠏⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠙⠳⣭⣛⠿⠿⠛⠛⣷⣽⡆⠀⢀⣯⡼⠃⠀⣠⡾⠃⣴⠃⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠉⠛⠦⣤⣀⠈⠻⠛⠀⠀⠀⠀⣠⡾⠋⣀⣴⡇⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⣀⣄⠀⠀⠀⠀⠀⠉⠛⠓⠒⠒⠒⠒⠛⠁⣠⡞⢹⣿⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢀⡞⢻⣹⠀⠀⠀⠀⠀⠰⡄⠀⠀⠀⠀⠀⢠⡾⠉⠀⢸⣿⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠘⡿⣧⠀⠀⠀⠀⠀⢻⡄⠀⠀⠀⣴⠏⠀⠀⠀⣸⡏⠀⠀⢸⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢻⡇⠀⠀⢹⣽⡀⠀⠀⠀⠀⠈⢳⣦⣀⡾⠃⠀⠀⠀⠀⣿⠃⠀⠀⢸⠀⠈⠉⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣁⣀⣸⡇⠀⠀⠈⢿⣇⠀⠀⠀⠀⠀⠀⠸⢿⠁⠀⠀⠀⠀⠀⣿⠀⠀⠀⢸⡇⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠉⠉⠻⣿⠀⠀⠀⠘⣿⡆⢸⡛⠳⣤⡀⠀⠸⡇⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⡄⠀⠀⠀⢻⣇⢸⡇⠀⠀⠙⠻⠾⠃⠀⠀⠀⠀⢰⡇⠀⠀⠀⢧⠀⠀⠀⠀⠀⠀⠘⢿⠿⠿⠿⠿⠇⠈⠛⠿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⢡⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⢀⡇⠀⠀⠀⠀⢻⡦⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠁⠀⠀⠀⢸⣆⠀⠀⠀⠀⠀⠀⠘⣤⣤⣤⣤⣤⣄⠀⠀⠀
⣿⣿⣿⣿⣿⣿⠿⠛⠉⠀⠀⠾⠟⠛⠉⠉⠀⠀⠀⠀⠀⠀⢠⣿⠀⠀⠀⠀⠀⠀⢹⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⠀⠀⢸⣿⣦⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⡀⠀⠀
⠿⠛⠋⠀⠀⠀⣀⣤⠀⠀⣠⣤⣤⣶⣶⣿⠇⠀⠀⠀⠀⣰⣿⣿⠀⠀⠀⠀⠀⠀⠀⢻⣿⠀⠀⠀⠀⠀⠀⠀⠀⣾⠁⠀⠀⠀⠀⢸⢿⠘⠷⣄⣀⣀⣀⣀⣨⣿⡿⠿⠟⠛⣛⣀⠀
⠀⠀⠀⠀⠀⠾⣯⣄⡀⢠⣿⣿⣿⣿⣿⡟⠀⠀⠀⣠⡾⣿⠏⣿⠀⠀⠀⠀⠀⠀⠀⠀⢿⣷⡀⠀⠀⠀⠀⠀⢠⠇⠀⣀⣀⣤⣤⠾⠞⠓⠊⠉⠉⠉⠉⠀⠀⠀⢷⣶⣿⣿⣿⣿⡆
⠀⠀⠀⠀⠀⠀⠀⠀⠉⢉⣙⣛⠻⠿⠿⠧⠤⠴⢿⣯⣿⠃⠀⣿⣀⣀⣀⣀⠀⠀⠀⠀⠀⢻⣷⣦⣀⠀⢀⣴⣿⡔⠋⠁⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿




]=])
]])
--

one = '  (function() ' 
two ='   end)()   '
pain='\n\n\n'
one=one:rep(75)
two=two:rep(75)
DATA=pain..one..pain..DATA
DATA=DATA..pain..two..pain

local emoji=function(len)
    len=len or 6
    local Table1={'😅', '😡', '👿', '🎃', '😁', '🥶', '🤡', '👹', '😎', '🥶', '🤩'}
    local emoji=''
    for i=1,len do
        emoji=emoji..Table1[math.random(1,#Table1)]
    end
    return emoji
end
g.hxcode = ' while ""=="RlRlRR" do RlRlRR="RlRlRR" end '
g.hxcode = string.rep(g.hxcode,2000)
DATA = g.hxcode .. DATA
DATA = 'if nil then(function()end)("lRlRlR")end ' .. DATA

DATA=string.dump(load(DATA),true)

Lasm = "LOADBOOL v0 0\nTEST v0 0\nNEWTABLE v0 2 0\nLOADNIL v1..v1\nLOADNIL v2..v2\nSETLIST v0..v2 1\nGETTABLE v1 v0 v1\nLEN v2 v0\nEQ 1 v1 v2\nUNM v1 v0\nLEN v2 v0\nGETTABLE v2 v0 v2\nLOADBOOL v0 0\nTEST v0 0\nNEWTABLE v0 2 0\nLOADNIL v1..v1\nLOADNIL v2..v2\nSETLIST v0..v2 1\nGETTABLE v1 v0 v1\nLEN v2 v0\nEQ 1 v1 v2\nUNM v1 v0\nLEN v2 v0\nGETTABLE v2 v0 v2\nLOADK v0 CONST[262143]  ; Next OP after LOADKX not EXTRAARG ; garbage\nSETTABUP u0 v18 v116  ; variable v116 out of stack (.maxstacksize = 39 for this func) ; garbage\nMOVE v0 v0\nLOADBOOL v0 0\nTEST v0 0\nNEWTABLE v0 2 0\nLOADNIL v1..v1\nLOADNIL v2..v2\nLEN v2 v0\nEQ 1 v1 v2\nUNM v1 v0\nLEN v2 v0\nGETTABLE v2 v0 v2\nTEST v0 0\nLOADBOOL v0 0\nLOADNIL v1..v1\nUNM v2 v2\nMOD v2 v2 nil\nLEN v2 v0\nEQ 1 v1 v2\nBNOT v3 v0\nCALL v2..v2 v2..v2\nMOVE v0 v0\nLOADBOOL v0 0\nTEST v0 0\nNEWTABLE v0 2 0\nLOADNIL v1..v1\nLOADNIL v2..v2\nLEN v2 v0\nEQ 1 v1 v2\nUNM v1 v0\nLEN v2 v0\nGETTABLE v2 v0 v2\nTEST v0 0\nLOADBOOL v0 0\nLOADNIL v1..v1\nUNM v2 v2\nMOD v2 v2 nil\nLEN v2 v0\nEQ 1 v1 v2\nBNOT v3 v0\nCALL v2..v2 v2..v2\nLOADK v0 CONST[262143]  ; Next OP after LOADKX not EXTRAARG ; garbage\nSETTABUP u0 v18 v116  ; variable v116 out of stack (.maxstacksize = 39 for this func) ; garbage\nMOVE v0 v0\nLOADBOOL v0 0\nTEST v0 0\nNEWTABLE v0 2 0\nLOADNIL v1..v1\nLOADNIL v2..v2\nLEN v2 v0\nEQ 1 v1 v2\nUNM v1 v0\nLEN v2 v0\nGETTABLE v2 v0 v2\nTEST v0 0\nLOADBOOL v0 0\nLOADNIL v1..v1\nUNM v2 v2\nMOD v2 v2 nil\nLEN v2 v0\nEQ 1 v1 v2\nBNOT v3 v0\nCALL v2..v2 v2..v2\nMOVE v0 v0\nLOADBOOL v0 0\nTEST v0 0\nNEWTABLE v0 2 0\nLOADNIL v1..v1\nLOADNIL v2..v2\nLEN v2 v0\nEQ 1 v1 v2\nUNM v1 v0\nLEN v2 v0\nGETTABLE v2 v0 v2\nTEST v0 0\nLOADBOOL v0 0\nLOADNIL v1..v1\nUNM v2 v2\nMOD v2 v2 nil\nLEN v2 v0\nEQ 1 v1 v2\nBNOT v3 v0\nCALL v2..v2 v2..v2\n"
Lasm = Lasm.."\n"

--------
tmp = "/sdcard/tmp.obf"

gg.internal2(load(DATA),tmp)

DATA = io.open(tmp,"r"):read("*a")
DATA = DATA:gsub("\t", ""):gsub(".numparams %d*", ".numparams 250"):gsub(".is_vararg %d*", ".is_vararg 250"):gsub(".maxstacksize %d*", ".maxstacksize 250")

FakeKey=[=[
.upval u1 "" ; u1
.upval u9 "" ; u2
.upval u10 "" ; u3
.upval u0 "" ; u4
.upval v0 "" ; u5
.upval u11 "" ; u6
.upval u12 "" ; u7
.upval u13 "" ; u8
.upval u14 "" ; u9
.upval u15 "" ; u10
.upval u16 "" ; u11
]=]

FakeKey1=[=[
.upval u1 "" ; u1
.upval u9 "" ; u2
.upval u10 "" ; u3
.upval u7 "" ; u4
.upval u6 "" ; u5
.upval u11 "" ; u6
]=]
DATA = DATA:gsub("upval%s*v0*%s*nil%s*;%s*%w*","upval v0 nil ; u0\n"..FakeKey,1)
DATA=DATA:gsub("upval%s*u0*%s*nil%s*;%s*%w*","upval u0 nil ; u0\n"..FakeKey1,1)

DATA = DATA:gsub('RETURN  ; garbage', Lasm)

DATA=DATA:gsub("LOADK[^\n]*\n\nCALL[^\n]*",function(x)
loadk=x:gsub("CALL[^\n]*","")
call=x:gsub("LOADK[^\n]*\n\n", "")

forcall = math.random(1,50000000)
forloadk = math.random(1,50000000)
hz = math.random(1,50000000)

v = "JMP :goto_"..forcall
en = "\n\n"
got = ":goto_"..forcall

sp = "\n"
vv = "JMP :goto_"..forloadk
get = ":goto_"..forloadk

vvv = "JMP :goto_"..hz
vvvv = ":goto_"..hz

return v..en..get..sp..call..en..vvv..en..got..sp..loadk..vv..en..vvvv
end)

DATA=DATA:gsub("GETTABUP[^\n]*\n\nGETTABLE[^\n]*",function(x)
gettable=x:gsub("GETTABUP[^\n]*\n\n","")
gettabup=x:gsub("\n\nGETTABLE[^\n]*", "")
enter="\n\n"

r1=math.random(1,50000000)
r2=math.random(1,50000000)
r3=math.random(1,50000000)

jmp1="\nJMP :goto_"..r1.."\n\n"
jmp2="\n\nJMP :goto_"..r2
jmp3="\n\nJMP :goto_"..r3

goto1=":goto_"..r1.."\n"
goto2=":goto_"..r2.."\n"
goto3="\n\n:goto_"..r3..""

return jmp1..goto2..gettable..jmp3..enter..goto1..gettabup..jmp2..goto3
end)


DATA=DATA:gsub("LOADK", function(x)
opjmp = math.random(1,9999999999)
GenOP = "\nJMP :goto_"..opjmp.."\n\nOP["..math.random(1, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."LOADK"
end)


DATA=DATA:gsub("GETTABUP",function(x) 
opjmp = math.random(1,9999999999)
GenOP = "JMP :goto_"..opjmp.."\n\nOP["..math.random(100, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."GETTABUP"
end)

DATA=DATA:gsub("NEWTABLE", function(x)
opjmp = math.random(1,9999999999)
GenOP = "JMP :goto_"..opjmp.."\n\nOP["..math.random(100, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."NEWTABLE"
end)

DATA=DATA:gsub("GETTABLE", function(x)
opjmp = math.random(1,9999999999)
GenOP = "\nJMP :goto_"..opjmp.."\n\nOP["..math.random(1, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."GETTABLE"
end)


DATA=DATA:gsub("SETUPVAL", function(x)
opjmp = math.random(1,9999999999)
GenOP = "JMP :goto_"..opjmp.."\n\nOP["..math.random(100, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."SETUPVAL"
end)

DATA=DATA:gsub("SETTABUP", function(x)
opjmp = math.random(1,9999999999)
GenOP = "JMP :goto_"..opjmp.."\n\nOP["..math.random(100, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."SETTABUP"
end)

DATA=DATA:gsub("GETUPVAL", function(x)
opjmp = math.random(1,9999999999)
GenOP = "JMP :goto_"..opjmp.."\n\nOP["..math.random(100, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."GETUPVAL"
end)

DATA=DATA:gsub("CLOSURE", function(x)
opjmp = math.random(1,9999999999)
GenOP = "JMP :goto_"..opjmp.."\n\nOP["..math.random(100, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."CLOSURE"
end)

DATA=DATA:gsub("RETURN", function(x)
opjmp = math.random(1,9999999999)
GenOP = "JMP :goto_"..opjmp.."\n\nOP["..math.random(100, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."RETURN"
end)

DATA=DATA:gsub("NEWTABLE", function(x)
opjmp = math.random(1,9999999999)
GenOP = "JMP :goto_"..opjmp.."\n\nOP["..math.random(100, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."NEWTABLE"
end)

DATA=DATA:gsub("\nCALL", function(x)
opjmp = math.random(1,9999999999)
GenOP = "\nJMP :goto_"..opjmp.."\n\nOP["..math.random(1, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."CALL"
end)

DATA=DATA:gsub("SELF", function(x)
opjmp = math.random(1,9999999999)
GenOP = "\nJMP :goto_"..opjmp.."\n\nOP["..math.random(1, 900).."] 0xf3e"..math.random(1, 900).."\n\n:goto_"..opjmp.."\n\n"
return GenOP.."SELF"
end)

DATA = string.dump(load(DATA), true, false)
randomly_strings = function(...)
return (math.random(128, 255))
end
really_hex = {
[1] = string.char(0x00, 0x63, 0x01, 0xff, 0x7f, 0x17),
[2] = string.char(0x80, 0x00, 0x1f, 0x00, 0x80)}
modified_hex = {
[1] = string.char(0x00, randomly_strings(), randomly_strings(), randomly_strings(), randomly_strings(), randomly_strings()),
[2] = string.char(0x80, 0x00, 0xe4, 0x00, 0x80)}
pairs_are = {
[1] = 0x00,
[2] = 0x01}
for i in ipairs(pairs_are) do
DATA = string.gsub(DATA, really_hex[i], modified_hex[i])
end
DATA = string.gsub(DATA, string.char(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFA, 0xFA, 0xFA),
              string.char(0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFA, 0xFA, 0xFA))

DATA = string.gsub(DATA, string.char(0x01, 0x00, 0x00, 0x00, 0x1f, 0x00, 0x80, 0x00),
              string.char(0x00, 0x00, 0x00, 0x00), 1)

DATA = string.gsub(DATA, string.char(0x04, 0x07, 0x00, 0x00, 0x00, 0x6C, 0x52, 0x6C, 0x52, 0x6C, 0x52, 0x00),
              string.char(0x04, 0x00, 0x00, 0x00, 0x00), 1)

DATA = string.gsub(DATA, string.char(0x04, 0x07, 0x00, 0x00, 0x00, 0x52, 0x6C, 0x52, 0x6C, 0x52, 0x6C),
              string.char(0x04, 0xF1, 0x00, 0x00, 0x00) .. emoji(60))

DATA = string.gsub(DATA, string.char(0x04, 0x07, 0x00, 0x00, 0x00, 0x52, 0x6C, 0x52, 0x6C, 0x52, 0x52),
              '\4\161\134\1\0'.. emoji(25000))

g.qukuai = string.char(0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFA, 0xFA, 0xFA) ..
                string.rep(string.char(0), 32)
DATA = DATA:gsub(g.qukuai,
              string.char(0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFA, 0xFA, 0xFA) ..
                  string.rep(string.char(0), 24) .. string.char(0x36, 0xB2, 0xBF, 0xFF, 0x83, 0x2B, 0xD8, 0xFF))

io.open(g.out,"w"):write(DATA):close()
return
end 
end
end 

gg.setVisible(false)

function run_offset_tester()
gg.setVisible(false) 
apex=0
-- 🌟 Modernized [Xa]-EDIT-v21--<{OFFSET TESTER}> UI 🌟

gg.setVisible(false) apex = 0

-- 🗓️ Date and Version 
xDATEx = "5-Jun-2025" xVERx = "v1" xDVx = xDATEx .. "  " .. xVERx

-- 🔧 Update Info 
xUPDATEINFOx = "New server link\nImproved speed" xNOTEx = "📌 Update Info\n━━━━━━━━━━━━━━━━━━━━\nLast Update: " .. xDATEx .. "  " .. xVERx .. "\n" .. xUPDATEINFOx

-- 🧾 Metadata 
line = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" xTAGx = "💀 Welcome For Offset Tester💀" xMOTOx = "⚔️ Hacking is the Game ⚔️" xLINKx = "🔗 https://t.me/VELLIX_AO" xLUAx = "📄 VellBotz.lua"

-- 🖨️ Display Header 
print("\n" .. line) print("🌟 " .. xTAGx .. " 🌟") print(xMOTOx) print(xLINKx) print(xLUAx) print("📅 Updated on: " .. xDATEx) print(line) print("🤖 your assistant") print(line)


---------------------------------------------------------------------
gg.require("101.1") 
v=gg.getTargetInfo()

    if v==nil then 
        print("×× ERROR ××\nINVALID PROCESS SELECTED OR NO ROOT ACCESS")
        gg.setVisible(true) 
        fuckshit() 
        return
    end 

vprocess=v.processName
vlabel=v.label
vversion=v.versionName
is64=v.x64 
if is64 then vbit="x64" else vbit="x32" end
---------------------------------------------------------------------
-- first alert 
gg.toast(xDATEx)  
local idiot=gg.alert(xTAGx.."\n"..xMOTOx.."\n"..xLINKx.."\n"..xLUAx.."\n-Access full Fitur (list fitur) -\n\n"..xNOTEx.."\n\n",xDATEx,nil,"[ √ ]") 
    if idiot~=3 then 
    print("Goodbye") 
    print(line) 
    gg.setVisible(true) 
    os.exit()
    fuckshit() 
    return
    end  
---------------------------------------------------------------------
AlPg = gg.multiChoice({
    "🧠 Allocate Memory Page (Recommended)",
    "🚫 Skip Allocation (Advanced Users)"
}, {[1]=true}, "🔧 Memory Settings")
secondmethod=0
if AlPg==nil then print("Cancelled at Allocate") gg.setVisible(true) return end 
if not AlPg[2] then allocpage=gg.allocatePage(7) end
if AlPg[2] then allocpage=nil end 
    if allocpage==nil or #(tostring(allocpage))==0 or type(allocpage)~="number" then
        print("Unable to Allocate New Page") 
        print("( "..tostring(allocpage).." )") 
        print(line) 
        y={} 
            for i, v in ipairs(gg.getRangesList()) do
                if v.state=="O" and v.type=="rw-p" then 
                c=0
                    for a=1,15 do 
                    y[a]={}
                    y[a].address=v["end"]-c
                    y[a].flags=4      
                    c=c+4 
                    end
                z=0
                x=gg.getValues(y) 
                    for a=1,15 do
                        if x[a].value~=0 then
                            z=1
                        end
                    end 
                    if z==0 then 
                        allocpage=x[5].address
                        secondmethod=1 
                        print("Alternate Method Successful")
                        print(line)  
                        break 
                    end
                end            
            end 
            if secondmethod==0 then 
                print("×× ERROR ××\nAlternate method to find a useable writable page failed.")
                print(line)  
                gg.toast("Please Wait...") 
                gg.clearResults()
                gg.setRanges(gg.REGION_CODE_APP) 
                gg.searchNumber("0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0::77",4) 
                    if gg.getResultsCount()==0 then
                    print(line) 
                    print("×× ERROR ××\nThird Attempt Failed")
                    print(line) 
                    gg.setVisible(true) 
                   
                    fuckshit()
                    return
                   end 
                allocpage=gg.getResults(1,10) 
                allocpage=allocpage[1].address 
                gg.getResults(gg.getResultsCount())
                gg.clearResults() 
                print("Third Attempt Successful")
                print(line)  
            end 
        else
            print("Allocate New Page Successful")
            print(line) 
        end 
gg.setVisible(false)  
AP={} o=0
INTX={}
INTX[1]={}
INTX[1].address=allocpage
INTX[1].flags=4
INTX=gg.getValues(INTX) 
FLOATX={} 
FLOATX[1]={}
FLOATX[1].address=allocpage
FLOATX[1].flags=16
FLOATX=gg.getValues(FLOATX) 
DOUBLEX={} 
DOUBLEX[1]={}
DOUBLEX[1].address=allocpage
DOUBLEX[1].flags=64
DOUBLEX=gg.getValues(DOUBLEX) 
QWORDX={} 
QWORDX[1]={}
QWORDX[1].address=allocpage
QWORDX[1].flags=32
QWORDX=gg.getValues(QWORDX)  
    for i = 1,4 do 
    AP[i]={}
    AP[i].address=allocpage+o
    AP[i].flags=2
    o=o+2
    end
AP=gg.getValues(AP) 
o=nil 

---------------------------------------------------------------------

--███████████████████████
libresult=0
xxxxxxxxxx=0
liblist = gg.getRangesList()
    if #(liblist)==0 then 
    print("×× LIB ERROR #01 ××\nNo Libs Found\nTry a Different Virtual Environment \nor Try a Better Game Installation Method\nor Download Game From 'apkcombo.com' ")
    gg.setVisible(true)
    end

xpk = v.packageName
liblist = gg.getRangesList(xpk.."*.so")
ll=1 listlib={} listname={} 
    for i, v in ipairs(liblist) do
        if liblist[i].state=="Xa" then 
        listlib[ll]=liblist[i].name:gsub(".*/", "") 
        listname[ll]=liblist[i].name:gsub(".*/", "")
        ll=ll+1        
        libresult=1 
        end   
    end -- loop liblist 

xsapkx=1
    if libresult==0 then
    xsapk={}
    liblist=gg.getRangesList()
        for i, v in ipairs(liblist) do
            if liblist[i].state=="Xa" and string.match(liblist[i].name,"split_config") then
            xsapk[xsapkx]=liblist[i]["end"]-liblist[i].start 
            xsapkx=xsapkx+1 
            listlib[ll]=liblist[i].name:gsub(".*/", "") 
            listname[ll]=liblist[i].name:gsub(".*/", "")
            ll=ll+1        
            libresult=2 
            end            
        end 
    end 

    if libresult==2 then
        lislitb=nil listlib={} 
        APEXQ=math.max(table.unpack(xsapk))
        for i, v in ipairs(liblist) do              
            if liblist[i].state=="Xa" and liblist[i]["end"]-liblist[i].start==APEXQ then              
            listlib[1]=liblist[i].start
            libresult=3 
            end
        end
    end 

    if libresult==2 then gg.alert("Split Apk Detected\nScript Error\nUnable to Locate Correct Start Address")
    gg.setVisible(true) return
    end 

    if libresult==0 then 
    print("×× LIB ERROR #02 ××\nNo Libs Found\nTry a Different Virtual Environment \nor Try a Better Game Installation Method\nor Download Game From 'apkcombo.com' ")
    gg.setVisible(true) return 
    end   

::CHLIB::
if libresult == 1 then 
    xchlibx = 0
    listlibl = #(listlib) 
    gg.toast("📦 OFFSET TESTER - Memuat daftar library...")  

    chlib = gg.multiChoice(listlib, {}, 
        "🧩 OFFSET TESTER\n\n📌 Pilih library untuk dianalisis:")

    if chlib == nil then 
        gg.setVisible(true) 
        return 
    end 

    for i, v in ipairs(listlib) do
        if chlib[i] then xchlibx = 1 end
    end 
    
    if xchlibx == 0 then goto CHLIB end 

    for i, v in ipairs(listlib) do
        if chlib[i] then 
            libzz = tostring(listlib[i])
            xxzyzxx = gg.getRangesList(libzz)  
        end
    end 

    region = {}
    for i, v in ipairs(xxzyzxx) do
        totalsize = string.format("%.4f", 
            (tonumber(xxzyzxx[i]["end"]) - tonumber(xxzyzxx[i].start)) / 1000000.0)

        local elf = {
            {address = xxzyzxx[i].start, flags = 1},
            {address = xxzyzxx[i].start + 1, flags = 1},
            {address = xxzyzxx[i].start + 2, flags = 1},
            {address = xxzyzxx[i].start + 3, flags = 1}
        }

        elf = gg.getValues(elf) 
        local elfch = {}
        for j = 1, 4 do
            local val = elf[j].value
            elfch[j] = (val > 31 and val < 127) and string.char(val) or " "
        end

        local header = table.concat(elfch)
        local started = string.format("%X", xxzyzxx[i].start)
        local ended = string.format("%X", xxzyzxx[i]["end"])

        region[i] = string.format("📍 [%s] • (%s) %sMB\n🔹 Start: 0x%s\n🔸 End:   0x%s", 
            v.state, header, totalsize, started, ended)
    end 

    gg.toast("📦 OFFSET TESTER - Memuat region...")
    libreg = gg.multiChoice(region, {}, 
        "🧩 OFFSET TESTER\n\n📌 Pilih region awal dari library:")

    if libreg == nil then goto CHLIB end 

    local c = 0 
    for i = 1, 100 do
        if libreg[i] then c = c + 1 end
    end 

    if c == 0 then goto CHLIB end 

    for i = 1, #region do
        if libreg[i] then
            xand = gg.getRangesList(libzz)[i].start 
            libz = libzz 
            xxxxxxxxxx = i 
            xxxxxSTATE = string.sub(region[i], 4, 6)
        end
    end 
end -- if libresult==1

if libresult == 3 then
    xand = listlib[1] 
    libz = tostring(listlib[1]) 
end 

liblib = (libresult == 1) and libz or "Split Apk"

gg.toast("✅ OFFSET TESTER - Library siap")
xSTATEx = xxxxxSTATE or "n/a"

local auto = gg.alert(
    string.format("📊 %s\n📦 %s v%s\n\n📌 Start Address:\n%s [%s]\n0x%X", 
        vlabel, vbit, vversion, liblib, xSTATEx, xand),
    "✅ YES", "🔁 BACK", "❌ EXIT"
)

if auto == 3 then 
    gg.setVisible(true) 
    return 
end 

if auto == 2 then goto CHLIB end 

print(string.format("📊 %s\n📦 %s v%s\n\n📌 Start Address:\n%s [%s]\n0x%X", 
    vlabel, vbit, vversion, liblib, xSTATEx, xand))

--███████████████████████
-- APEXKEY 
if is64 then
    xtrue="h200080D2"
    xfalse="h000080D2"
    xEND="hC0035FD6"
    xMOVKX0="h000080F2" -- E,Q
    xMOVKX016="h0000A0F2"  -- E,Q
    xMOVKX032="h0000C0F2"  -- E,Q
    xMOVKX048="h0000E0F2" 
    xMOVZX048="h0000E0D2" 
    xMOVW0="h00008052"  -- I,F
    xMOVKW0="h00008072"   -- I,F 
    xMOVKW016="h0000A072"
    xMOVX0=xfalse -- F,Q 
    xFMOVS0W0="1E270000h" 
    xFMOVD0X0="h0000679E"
    xMOVZX0="h000080D2"
    
else
    xtrue="h0100A0E3"
    xfalse="h0000A0E3"
    xEND="h1EFF2FE1"
end 

--███████████████████████
--███████████████████████
--███████████████████████
REVERT=0
xCLASS=0
mcO="" 
mcEV="" 
mcREP=false 
function menu()
  apex = 1
  gg.toast(xTAGx)

  if xCLASS == 1 then
    menu2()
    return
  end

  --==== REVERT HANDLING ====
  if REVERT == 1 then
    if cc == 0 then cc = 1 end

    if isOffset == 2 then
      ihex = {}
      for i = 1, #I do
        ihex[i] = "["..i.."]=0x"..string.format("%X", I[i])
      end
      ihex = table.concat(ihex, ",  ")
      if #I > 10 then
        ihex = "["..#I.."]  "..tostring(mcEV)
      end
      xmcOC = mcOC
      XMCxx = xmcOC.."  /  "..xmcCO
    elseif isOffset == 1 then
      ihex = "[1] = "..mcOC
      XMCxx = ""
    else
      ihex = ""
      XMCxx = ""
    end

    local r = gg.choice({"🔁 REVERT", "❌ DON'T REVERT"}, 0, XMCxx.."\n"..ihex)
    if r == nil then gg.toast("CANCELLED") return end
    if cc == 1 then cc = 0 end
    if r == 1 then gg.setValues(APEXREV) gg.toast("[ REVERT DONE ]") end
  end

  if REVERT == 2 then
    local r = gg.choice({"🔁 Revert", "❌ Don't Revert"}, 0, "REPLACE\n"..xR1.." = "..xR2)
    if r == nil then gg.toast("CANCELLED") return end
    if r == 1 then
      gg.setValues(repv1rev)
      REVERT = 0
      mcREP = false
    end
  end

  --==== MAIN PROMPT ====
  ::STARTMC::
  COPYHEX = 0
  SCRIPTIT = 0

  local mc = gg.prompt({
    "🔎 Public Class Field Offset Search",                         -- 1
    "📌 Offset / Method_Name / Method~Class\n(0xOffset=0xReplace)\nKosongkan untuk menyimpan offset terbaru", -- 2
    "✔️ Edit TRUE (1)",                                            -- 3
    "❌ Edit FALSE (0)",                                           -- 4
    "♻️ Replace Mode (Beta)",                                      -- 5
    "🔺 Maximum Value",                                            -- 6
    "🔻 Minimum Value",                                            -- 7
    "📥 Enter Edit Value (within range!)",                         -- 8
    "🧮 INT / DWORD / SHORT",                                      -- 9
    "🌊 FLOAT (equivalent)",                                       -- 10
    "🎯 FLOAT (real)",                                             -- 11
    "💠 DOUBLE",                                                   -- 12
    "🗂️ QWORD / LONG",                                             -- 13
    "📋 Copy: ARM / OpCode / Offset",                              -- 14
    "📝 Script it",                                                -- 15
    "💾 Save / Load Notes",                                        -- 16
    "ℹ️ INFO / HELP",                                              -- 17
    "🧩 INSTALL MODULE",                               -- 18
    "🚪 [ E X I T ]"                                               -- 19
  }, {[2]=mcO, [5]=mcREP, [8]=mcEV},
  {[1]="checkbox", [2]="text", [3]="checkbox", [4]="checkbox", [5]="checkbox",
   [6]="checkbox", [7]="checkbox", [8]="number",
   [9]="checkbox", [10]="checkbox", [11]="checkbox", [12]="checkbox", [13]="checkbox",
   [14]="checkbox", [15]="checkbox", [16]="checkbox",
   [17]="checkbox", [18]="checkbox", [19]="checkbox"})

  if mc == nil then cancel() return end
  if mc[19] then exit() os.exit() fuckshit() return end
  if mc[16] then notes() return end
  if mc[17] then infohelp() return end
  if mc[18] then morescripts() return end
  if mc[1] then xCLASS = 1 menu2() return end

  if #(mc[2]) == 0 then
    gg.alert("⛔ ERROR\nInvalid Offset / Method")
    mcO = ""
    goto STARTMC
  end

  mcO = tostring(mc[2])
  isOffset = 0
  if mc[5] then xREPLACE() return end

  --==== OFFSET / METHOD VALIDATION ====
  if string.byte(mcO) == 48 then
    if string.byte(mcO,2) == 120 or string.byte(mcO,2) == 88 then
      if type(tonumber(mcO)) ~= "number" then
        gg.alert("⛔ ERROR\nInvalid Offset Format")
        goto STARTMC
      end
    end
  else
    for i = 1, #mcO do
      local b = string.byte(mcO, i)
      if b == 46 or b == 40 or b == 41 or b == 123 or b == 125 or b == 32 then
        local rusure = gg.alert("⛔ ERROR\nInvalid Method/Class Name.\nNo spaces\nNo ( )\nNo { }", "NO", "YES", "CONTINUE?")
        if rusure ~= 2 then goto STARTMC end
        break
      end
    end
  end

  mcOC = nil
  mcCO = nil

  --==== METODE / OFFSET PARSING ====
  if type(tonumber(mcO)) == "number" then
    isOffset = 1
    mcOC = mcO
  else
    isOffset = 2
    for i = 1, #mcO do
      if string.byte(mcO, i) == 126 then
        x126 = i
        mcOC = string.sub(mcO, 1, x126 - 1)
        mcCO = string.sub(mcO, x126 + 1)
        break
      else
        mcOC = mcO
        mcCO = "nil"
      end
    end

    xsox = 0
    local Ach = gg.alert("Method:\n  "..mcOC.."\nClass:\n  "..mcCO, "SAVE", "SEARCH", "SEARCH + EDIT")
    if Ach == 0 then goto STARTMC end
    if Ach == 1 then gg.toast("✅ SAVED") REVERT = 0 return end
    if Ach == 3 then goto EDITFUNCTIONS end
    if Ach == 2 then
      REVERT = 0
      xsox = 1
      METHODSEARCH()
      if methodSuccess == 0 then return end
      local cpyoffx = {}
      for i = 1, #I do
        cpyoffx[i] = "0x"..string.format("%X", I[i])
      end
      cpyoffx = table.concat(cpyoffx, "\n")
      local Acpy = gg.alert(mcOC.."\n"..mcCO.."\n\n"..cpyoffx, "COPY", "MENU", xTAGx)
      if Acpy == 2 then goto STARTMC end
      if Acpy == 1 then
        gg.copyText(cpyoffx)
        gg.toast("✅ Offset(s) Copied:\n"..cpyoffx)
        return
      end
    end
  end

  --==== EDIT FUNCTIONALITY ====
  ::EDITFUNCTIONS::
  local xeditions = 0
  for i = 3, 7 do if mc[i] then xeditions = 1 end end
  for i = 9, 13 do if mc[i] then xeditions = 1 end end
  if xeditions == 0 then
    gg.alert("⚠️ No Edit Option Selected")
    goto STARTMC
  end

  if mc[14] then COPYHEX = 1 end
  if mc[15] then SCRIPTIT = 1 end

  if mc[3] then xTRUE() return end
  if mc[4] then xFALSE() return end
  if mc[6] then xMAXIMUM() return end
  if mc[7] then xMINIMUM() return end

  mcEV = tostring(mc[8])
  if mcEV == "0" then xFALSE() return end

  if mc[9] or mc[10] or mc[11] or mc[12] or mc[13] then
    if type(tonumber(mcEV)) ~= "number" then
      gg.alert("⛔ ERROR\nInvalid Edit Value")
      goto STARTMC
    end
  end

  mcEV = tonumber(mc[8])

  if mc[9] then xINT() return end
  if mc[10] then xFLOATE() return end
  if mc[11] then xFLOATR() return end
  if mc[12] then xDOUBLE() return end
  if mc[13] then xQWORD() return end

  REVERT = 0
end -- end menu
    
--███████████████████████
--███████████████████████
--███████████████████████

function xTRUE()
c=nil cc=nil 
APEXREV=nil APEXREV={}
EDIT=nil EDIT={}

    if isOffset==1 then 
        APEXREV[1]={} APEXREV[2]={} 
        EDIT[1]={} EDIT[2]={}
        APEXREV[1].address=xand+mcO
        APEXREV[1].flags=4
        APEXREV[2].address=xand+mcO+4
        APEXREV[2].flags=4
        APEXREV=gg.getValues(APEXREV) 
        EDIT[1].address=xand+mcO
        EDIT[1].value=xtrue
        EDIT[1].flags=4
        EDIT[2].address=xand+mcO+4
        EDIT[2].value=xEND
        EDIT[2].flags=4       
        gg.setValues(EDIT) 
        REVERT=1 
        cc=1 
    end 


    if isOffset==2 then 
        METHODSEARCH() if methodSuccess==0 then return end 
        clear() wait() 
        c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1 
                APEXREV[c]={}
                EDIT[c]={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c].address=xload[i].address
                EDIT[c].value=xtrue 
                EDIT[c].flags=4
                c=c+1 
                APEXREV[c]={}
                EDIT[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xEND 
                EDIT[c].flags=4
                cc=cc+1 
            end
       APEXREV=gg.getValues(APEXREV) 
       gg.setValues(EDIT) 
       REVERT=1
   end 
        
gg.toast("[ "..cc.." ]  TRUE / 1") 
if COPYHEX==1then copyhex() end
if SCRIPTIT==1 then scripit() end 
end -- xTRUE     

--███████████████████████

function xFALSE()
c=nil cc=nil 
APEXREV=nil APEXREV={}
EDIT=nil EDIT={}

    if isOffset==1 then 
        APEXREV[1]={} APEXREV[2]={} 
        EDIT[1]={} EDIT[2]={}
        APEXREV[1].address=xand+mcO
        APEXREV[1].flags=4
        APEXREV[2].address=xand+mcO+4
        APEXREV[2].flags=4
        EDIT[1].address=xand+mcO
        EDIT[1].value=xfalse
        EDIT[1].flags=4
        EDIT[2].address=xand+mcO+4
        EDIT[2].value=xEND
        EDIT[2].flags=4
        APEXREV=gg.getValues(APEXREV) 
        gg.setValues(EDIT) 
        REVERT=1 
        cc=1 
    end 


    if isOffset==2 then 
        METHODSEARCH() if methodSuccess==0  then return end 
        clear() wait() 
        c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1 
                APEXREV[c]={}
                EDIT[c]={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c].address=xload[i].address
                EDIT[c].value=xfalse
                EDIT[c].flags=4
                c=c+1 
                APEXREV[c]={}
                EDIT[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xEND 
                EDIT[c].flags=4
                cc=cc+1 
            end
       APEXREV=gg.getValues(APEXREV) 
       gg.setValues(EDIT) 
       REVERT=1
   end 
        
gg.toast("[ "..cc.." ]  FALSE / 0") 
if COPYHEX==1then copyhex() end
if SCRIPTIT==1 then scripit() end 
end -- xFALSE 

--███████████████████████

xrepx=0

function xREPLACE()
REVERT=0 mcREP=true 

local m=string.find(tostring(mcO),"=")

-- if no = and value is not a number 
    if m==nil and type(tonumber(mcO))~="number" then
        gg.alert("× INVALID OFFSET ×","OK",nil, xTAGx)
        menu()
        return
    end

-- if there is an = at end of string or start of string or if is number 
    if m==#(tostring(mcO))  or m==1 or type(tonumber(mcO))=="number" then 
        local srep=gg.alert("REPLACE\n\n"..mcO.."\n","SAVE","CANCEL",xTAGx) 
        if srep==2 then mcO="" mcREP=false gg.toast("CANCELLED") end 
        return 
    end 

-- if = is not at beginning or end , seperate and chech if numbers 
    if m~=nil and m~=#(tostring(mcO))  and m~=1 and type(tonumber(mcO))~="number" then 
        xR1=string.sub(tostring(mcO),1,m-1)
        xR2=string.sub(tostring(mcO),m+1,-1)
            if type(tonumber(xR1))~="number" or type(tonumber(xR1))~="number" then
                gg.alert("REPLACE\n\n× NOT VALID OFFSETS ×\n","OK",nil, xTAGx) 
                menu()
                return
            end 
        repver=gg.alert("REPLACE\n\nEdit "..xR1.."\nTo = "..xR2.."\n","YES","CANCEL",xTAGx) 
            if repver==2 then mcREP=false mcO="" menu() return end
    end 
        
xR1n=tonumber(xR1)
xR2n=tonumber(xR2)

    if gg.getTargetInfo().x64 then frep=32 orep=8 
    else frep=4 orep=4 
    end

xxxrep1=nil xxxrep2=nil
repv1=nil repv1rev=nil repv2=nil 
 
gg.clearResults()
xxxrep1={}
xxxrep1[1]={}
xxxrep1[1].address=xand+xR1n
xxxrep1[1].flags=frep
gg.loadResults(xxxrep1)
gg.getResults(gg.getResultsCount())
gg.searchPointer(0)
    if gg.getResultsCount()==0 then
        gg.alert("REPLACE\n\n× ERROR × \nNo Pointer for "..xR1.."\n","OK",nil, xTAGx) 
        return
    end 
repv1=gg.getResults(gg.getResultsCount())
repv1rev=gg.getResults(gg.getResultsCount())

gg.clearResults()
xxxrep2={}
xxxrep2[2]={}
xxxrep2[2].address=xand+xR2n
xxxrep2[2].flags=frep
gg.loadResults(xxxrep2)
gg.getResults(gg.getResultsCount())
gg.searchPointer(0)
    if gg.getResultsCount()==0 then
        gg.alert("REPLACE\n\n× ERROR × \nNo Pointer for "..xR2.."\n","OK",nil, xTAGx) 
        return
    end
repv2=gg.getResults(1)

gg.clearResults()
    for i, v in ipairs(repv1) do
        v.value=repv2[1].value
    end
gg.setValues(repv1)
gg.toast(xR1.." = "..xR2)
REVERT=2

end -- xREPLACE

--███████████████████████

function xMAXIMUM()
maxch=gg.choice({
	"INT +2,147,483,647",
	"FLOAT +3.4e38 (equiv)",
	"FLOAT +3.4e38 (real)",
	"DOUBLE +1.79e307",
	"QWORD +9.2e18"},0,"MAXIMUM +VALUE")
	
	if maxch==nil then menu() return end 

APEXREV=nil APEXREV={}
EDIT=nil EDIT={}
c=0 cc=0 

    
--======================================
-- MAX INT maxch 1 
    if is64 then 
        xxint1="~A8 MOV W0, #0xFFFF" 
        xxint2="~A8 MOVK W0, #0x7FFF, LSL #16"
    else 
        xxint1="h0000E0E3"  -- MOV R0, #-1
        xxint2="~A MOVT R0, #32767 "
    end 
    
    if maxch==1 then 
        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={}
            EDIT[1]={} EDIT[2]={} EDIT[3]={}
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            EDIT[1].address=xand+mcO 
            EDIT[1].value=xxint1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xxint2 
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=xEND
            EDIT[3].flags=4
            gg.setValues(EDIT) 
            gg.toast("+ 2,147,483,647") 
            cc=1 
        end 
---------------------------        
        if isOffset==2 then 
            METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxint1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xxint2 
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=xEND
                EDIT[c].flags=4
                cc=cc+1 
            end
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  +2,147,483,647") 
        end        
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end         
    end -- if maxch=1 
    
--======================================
-- MAX FLOAT equiv - maxch 2
    if is64 then 
        xxfloateq1="~A8 MOV X0, #0x7F7FC99E"
    else 
        xxfloateq1="~A MOVT R0, #32639" 
    end 
    
    if maxch==2 then 
        if isOffset==1 then
            APEXREV[1]={} APEXREV[2]={}
            EDIT[1]={} EDIT[2]={}
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            EDIT[1].address=xand+mcO
            EDIT[1].value=xxfloateq1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xEND
            EDIT[2].flags=4
            gg.setValues(EDIT) 
            gg.toast("FLOAT +3.4e38 (equiv)")
            cc=1 
        end -- isOffset 1 
---------------------------                
        if isOffset==2 then
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxfloateq1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xEND 
                EDIT[c].flags=4   
                cc=cc+1 
            end
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ] FLOAT +3.4e38 (equiv)") 
        end -- isOffset 2 
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end                         
    end -- maxch 2 

--====================================== 
-- MAX FLOAT  real  maxch 3 
    if is64 then 
        xxfloat1="~A8 MOVZ W0, #-0x2662" 
        xxfloat2="~A8 MOVK W0, #0x7F7F, LSL #16"
        xxfloat3=xFMOVS0W0 
        xxfloat4="~A8 RET" 
    else 
        xxfloat1="~A MOVW R0, #51614"
        xxfloat2="~A MOVT R0, #32639"
        xxfloat3="~A VMOV S15, R0 "
        xxfloat4="~A VMOV.F32 S0, S15 " 
    end
    
    if maxch==3 then 
        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={} 
           APEXREV[4]={} APEXREV[5]={} 
            EDIT[1]={} EDIT[2]={} EDIT[3]={} EDIT[4]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV[4].address=xand+mcO+12
            APEXREV[4].flags=4 
            APEXREV[5].address=xand+mcO+16
            APEXREV[5].flags=4 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            EDIT[1].address=xand+mcO 
            EDIT[1].value=xxfloat1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xxfloat2 
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=xxfloat3
            EDIT[3].flags=4
            EDIT[4].address=xand+12 
            EDIT[4].value=xxfloat4 
            EDIT[4].flags=4
            if not v.x64 then 
                EDIT[5]={}
                EDIT[5].address=xand+16
                EDIT[5].value=xEND
                EDIT[5].flags=4
            end 
            gg.setValues(EDIT) 
            gg.toast("FLOAT +3.4e38") 
            cc=1 
        end         
---------------------------                
        if isOffset==2 then 
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxfloat1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xxfloat2 
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=xxfloat3
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+12
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+12
                EDIT[c].value=xxfloat4
                EDIT[c].flags=4   
                    if not v.x64 then
                    c=c+1
                    APEXREV[c]={} 
                    APEXREV[c].address=xload[i].address+16
                    APEXREV[c].flags=4
                    EDIT[c]={}
                    EDIT[c].address=xload[i].address+16
                    EDIT[c].value=xEND
                    EDIT[c].flags=4    
                   end    
               cc=cc+1 
            end -- for I 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  FLOAT +3.4e38") 
        end  -- isOffset 2                   
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end                 
    end  -- maxch 3 

--======================================            
-- MAX DOUBLE  1.79e307 maxch 4
    if is64 then 
        xxdouble1="~A8 MOV X0, #-0x385"
        xxdouble2="~A8 MOVK X0, #-0x1F76, LSL #16"
        xxdouble3="~A8 MOVK X0, #0x7D8D, LSL #32"
        xxdouble4="~A8 MOVK X0, #0x7FB9, LSL #48"
        xxdouble5=xFMOVD0X0 
        xxdouble6=xEND     
    else 
        xxdouble1="~A MOVW R0, #64635"
        xxdouble2="~A MOVT R0, #57482"
        xxdouble3="~A MOVW R1, #32141"
        xxdouble4="~A MOVT R1, #32697"
        xxdouble5="~A VMOV D16, R0, R1"
        xxdouble6="~A VMOV.F64 D0, D16"
        xxdouble7=xEND 
    end 

    if maxch==4 then 
        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={} APEXREV[4]={}
            APEXREV[5]={} APEXREV[6]={} APEXREV[7]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV[4].address=xand+mcO+12
            APEXREV[4].flags=4
            APEXREV[5].address=xand+mcO+16
            APEXREV[5].flags=4
            APEXREV[6].address=xand+mcO+20
            APEXREV[6].flags=4
            APEXREV[7].address=xand+mcO+24
            APEXREV[7].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1 
            EDIT[1]={} EDIT[2]={} EDIT[3]={} EDIT[4]={}
            EDIT[1].address=xand+mcO
            EDIT[1].value=xxdouble1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xxdouble2
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=xxdouble3
            EDIT[3].flags=4
            EDIT[4].address=xand+mcO+12
            EDIT[4].value=xxdouble4
            EDIT[4].flags=4                
            EDIT[5]={}
            EDIT[5].address=xand+mcO+16
            EDIT[5].value=xxdouble5
            EDIT[5].flags=4
            EDIT[6]={} 
            EDIT[6].address=xand+mcO+20
            EDIT[6].value=xxdouble6
            EDIT[6].flags=4
                if not v.x64 then 
                EDIT[7]={} 
                EDIT[7].address=xand+mcO+24
                EDIT[7].value=xEND 
                EDIT[7].flags=4
                end
            gg.setValues(EDIT)  
            gg.toast("1.79e307 DOUBLE") 
            cc=1 
        end -- isOffset 1
---------------------------                        
        if isOffset==2 then 
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxdouble1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xxdouble2 
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=xxdouble3
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+12
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+12
                EDIT[c].value=xxdouble4
                EDIT[c].flags=4   
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+16
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+16
                EDIT[c].value=xxdouble5
                EDIT[c].flags=4    
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+20
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+20
                EDIT[c].value=xxdouble6 
                EDIT[c].flags=4    
                    if not v.x64 then 
                    c=c+1
                    APEXREV[c]={} 
                    APEXREV[c].address=xload[i].address+24
                    APEXREV[c].flags=4
                    EDIT[c]={}
                    EDIT[c].address=xload[i].address+24
                    EDIT[c].value=xEND 
                    EDIT[c].flags=4    
                   end    
               cc=cc+1 
            end -- for I 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  1.79e307 DOUBLE") 
        end  -- isOffset 2    
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end                        
    end -- maxch 4 

--======================================            
-- MAX QWORD +9,223,372,036,854,775,807 maxch 5
-- 9223372036854774607
    if is64 then 
        xxqword1="~A8 MOVZ X0, #0x7FFF, LSL #48"
        xxqword2="~A8 MOVK X0, #-0x1, LSL #32"
        xxqword3="~A8 MOVK X0, #-0x1, LSL #16"
        xxqword4="~A8 MOVK X0, #-0x1"
        xxqword5="hC0035FD6"
    else 
        xxqword1="~A MOVW R0, #64335"
        xxqword2="~A MOVT R0, #65535"
        xxqword3="~A MOVW R1, #65535"
        xxqword4="~A MOVT R1, #32767"
        xxqword5="~A VMOV D0, R0, R1"
    end
    
    if maxch==5 then
        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={} 
            APEXREV[4]={} APEXREV[5]={} APEXREV[6]={} 
            APEXREV[7]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV[4].address=xand+mcO+12
            APEXREV[4].flags=4
            APEXREV[5].address=xand+mcO+16
            APEXREV[5].flags=4
            APEXREV[6].address=xand+mcO+20
            APEXREV[6].flags=4
            APEXREV[7].address=xand+mcO+24
            APEXREV[7].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1 
            EDIT[1]={} EDIT[2]={} EDIT[3]={} 
            EDIT[4]={} EDIT[5]={} 
            EDIT[1].address=xand+mcO
            EDIT[1].value=xxqword1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xxqword2
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=xxqword3
            EDIT[3].flags=4
            EDIT[4].address=xand+mcO+12
            EDIT[4].value=xxqword4
            EDIT[4].flags=4
            EDIT[5].address=xand+mcO+16
            EDIT[5].value=xxqword5
            EDIT[5].flags=4
                if not v.x64 then 
                EDIT[6]={} 
                EDIT[6].address=xand+mcO+20
                EDIT[6].value=xEND 
                EDIT[6].flags=4  
                end
            gg.setValues(EDIT) 
            gg.toast("QWORD 9.2e18") 
            cc=1 
        end -- isOffset 1 
---------------------------              
         if isOffset==2 then
              METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxqword1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xxqword2
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=xxqword3
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+12
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+12
                EDIT[c].value=xxqword4
                EDIT[c].flags=4   
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+16
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+16
                EDIT[c].value=xxqword5
                EDIT[c].flags=4    
                    if not v.x64 then 
                    c=c+1
                    APEXREV[c]={} 
                    APEXREV[c].address=xload[i].address+20
                    APEXREV[c].flags=4
                    EDIT[c]={}
                    EDIT[c].address=xload[i].address+20
                    EDIT[c].value=xEND 
                    EDIT[c].flags=4    
                   end    
               cc=cc+1 
            end -- for I 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  QWORD 9.2e18") 
        end  -- isOffset 2   
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end                           
    end -- maxch 5
---------------------------        
end -- xMAXIMUM           
--███████████████████████

function xMINIMUM() 
minch=gg.choice({
	"INT -2,147,483,647",
	"FLOAT -3.4e38 (equiv)",
	"FLOAT -3.4e38 (real)",
	"DOUBLE -1.79e307",
	"QWORD -9.2e18"},0,"MINIMUM -VALUE")
	
	if minch==nil then menu() return end 

APEXREV=nil APEXREV={}
EDIT=nil EDIT={}
c=0 cc=0 

 --======================================    
-- MIN INT minch 1 

    if is64 then 
        xxint1="~A8 MOV X0, #-0x80000000"
    else 
        xxint1="~A MOVT R0, #32768"  
    end 
    
    if minch==1 then 
        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} 
            EDIT[1]={} EDIT[2]={}
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            EDIT[1].address=xand+mcO 
            EDIT[1].value=xxint1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xEND 
            EDIT[2].flags=4
            gg.setValues(EDIT) 
            gg.toast("- 2,147,483,647") 
            cc=1 
        end 
---------------------------        
        if isOffset==2 then 
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxint1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xEND 
                EDIT[c].flags=4
                cc=cc+1 
            end
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  -2,147,483,647") 
        end     
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end                    
    end -- if minch=1 
    
--======================================
-- MIN FLOAT equiv - mInch 2 -3.4e38
    if is64 then 
        xxfloateq1="~A8 MOV X0, #0xFF7F0000" 
    else 
        xxfloateq1="~A MOVT R0, #65407 "   
    end 
    
    if minch==2 then 
        if isOffset==1 then
            APEXREV[1]={} APEXREV[2]={}
            EDIT[1]={} EDIT[2]={}
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            EDIT[1].address=xand+mcO
            EDIT[1].value=xxfloateq1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xEND
            EDIT[2].flags=4
            gg.setValues(EDIT) 
            gg.toast("FLOAT -3.4e38 (equiv)")
            cc=1 
        end -- isOffset 1 
---------------------------                
        if isOffset==2 then
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxfloateq1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xEND 
                EDIT[c].flags=4   
                cc=cc+1 
            end
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..c.." ] FLOAT -3.4e38 (equiv)") 
        end -- isOffset 2      
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end                    
    end -- minch 2 

--======================================            
-- MIN FLOAT  real  mInch 3 -3.4e38 
    if is64 then 
        xxfloat1="~A8 MOV W0, #0xFF7F0000"
        xxfloat2="~A8 MOVK W0, #-0x3662, LSL #16"
        xxfloat3=xFMOVW0S0 
        xxfloat4="~A8 RET" 
    else 
        xxfloat1="~A MOVW R0, #2310"
        xxfloat2="~A MOVT R0, #65407"
        xxfloat3="~A VMOV S15, R0 "
        xxfloat4="~A VMOV.F32 S0, S15 " 
    end
    
    if minch==3 then 
        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={} 
           APEXREV[4]={} APEXREV[5]={} 
            EDIT[1]={} EDIT[2]={} EDIT[3]={} EDIT[4]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV[4].address=xand+mcO+12
            APEXREV[4].flags=4 
            APEXREV[5].address=xand+mcO+16
            APEXREV[5].flags=4 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            EDIT[1].address=xand+mcO 
            EDIT[1].value=xxfloat1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xxfloat2 
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=xxfloat3
            EDIT[3].flags=4
            EDIT[4].address=xand+12 
            EDIT[4].value=xxfloat4 
            EDIT[4].flags=4
            if not v.x64 then 
                EDIT[5]={}
                EDIT[5].address=xand+16
                EDIT[5].value=xEND
                EDIT[5].flags=4
            end 
            gg.setValues(EDIT) 
            gg.toast("FLOAT -3.4e38") 
            cc=1 
        end         
---------------------------                
        if isOffset==2 then 
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxfloat1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xxfloat2 
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=xxfloat3
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+12
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+12
                EDIT[c].value=xxfloat4
                EDIT[c].flags=4   
                    if not v.x64 then
                    c=c+1
                    APEXREV[c]={} 
                    APEXREV[c].address=xload[i].address+16
                    APEXREV[c].flags=4
                    EDIT[c]={}
                    EDIT[c].address=xload[i].address+16
                    EDIT[c].value=xEND
                    EDIT[c].flags=4    
                   end    
               cc=cc+1 
            end -- for I 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  FLOAT -3.4e38") 
        end  -- isOffset 2                   
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end                
    end  -- minch 3 

--======================================            
-- MIN DOUBLE  -1.79e308 minch 4
    if is64 then 
        xxdouble1="~A8 MOVK X0, #-0x385" 
        xxdouble2="~A8 MOVK X0, #-0x1F76, LSL #16"
        xxdouble3="~A8 MOVK X0, #0x7D8D, LSL #32"
        xxdouble4="~A8 MOVK X0, #-0x47, LSL #48"
        xxdouble5=xFMOVD0X0 
        xxdouble6=xEND     
    else 
        xxdouble1="~A MOVW R0, #64635"
        xxdouble2="~A MOVT R0, #57482"
        xxdouble3="~A MOVW R1, #32141"
        xxdouble4="~A MOVT R1, #65465"
        xxdouble5="~A VMOV D16, R0, R1 "
        xxdouble6="~A VMOV.F64 D0, D16 "
        xxdouble7=xEND 
    end 

    if minch==4 then 
        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={} APEXREV[4]={}
            APEXREV[5]={} APEXREV[6]={} APEXREV[7]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV[4].address=xand+mcO+12
            APEXREV[4].flags=4
            APEXREV[5].address=xand+mcO+16
            APEXREV[5].flags=4
            APEXREV[6].address=xand+mcO+20
            APEXREV[6].flags=4
            APEXREV[7].address=xand+mcO+24
            APEXREV[7].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1 
            EDIT[1]={} EDIT[2]={} EDIT[3]={} EDIT[4]={}
            EDIT[1].address=xand+mcO
            EDIT[1].value=xxdouble1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xxdouble2
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=xxdouble3
            EDIT[3].flags=4
            EDIT[4].address=xand+mcO+12
            EDIT[4].value=xxdouble4
            EDIT[4].flags=4                
            EDIT[5]={}
            EDIT[5].address=xand+mcO+16
            EDIT[5].value=xxdouble5
            EDIT[5].flags=4
            EDIT[6]={} 
            EDIT[6].address=xand+mcO+20
            EDIT[6].value=xxdouble6
            EDIT[6].flags=4
                if not v.x64 then 
                EDIT[7]={} 
                EDIT[7].address=xand+mcO+24
                EDIT[7].value=xEND 
                EDIT[7].flags=4
                end
            gg.setValues(EDIT)  
            gg.toast("-1.79e307 DOUBLE") 
            cc=1 
        end -- isOffset 1
---------------------------                        
        if isOffset==2 then 
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxdouble1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xxdouble2 
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=xxdouble3
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+12
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+12
                EDIT[c].value=xxdouble4
                EDIT[c].flags=4   
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+16
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+16
                EDIT[c].value=xxdouble5
                EDIT[c].flags=4    
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+20
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+20
                EDIT[c].value=xxdouble6 
                EDIT[c].flags=4    
                    if not v.x64 then 
                    c=c+1
                    APEXREV[c]={} 
                    APEXREV[c].address=xload[i].address+24
                    APEXREV[c].flags=4
                    EDIT[c]={}
                    EDIT[c].address=xload[i].address+24
                    EDIT[c].value=xEND 
                    EDIT[c].flags=4    
                   end    
               cc=cc+1 
            end -- for I 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  -1.79e307 DOUBLE") 
        end  -- isOffset 2    
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end                        
    end -- minch 4 

--======================================            
-- MIN QWORD -9,223,372,036,854,775,808 minch 5

    if is64 then 
        xxqword1="~A8 MOVZ X0, #0x8000, LSL #48"
        xxqword2=xMOVKX032
        xxqword3=xMOVKX016
        xxqword4=xMOVKX0 
        xxqword5="hC0035FD6"
    else
        xxqword1="~A MOVW R0, #1201"
        xxqword2="~A MOVT R0, #0"
        xxqword3="~A MOVW R1, #0"
        xxqword4="~A MOVT R1, #32768"
        xxqword5="~A VMOV D0, R0, R1 "
    end
    
    if minch==5 then 
        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={} 
            APEXREV[4]={} APEXREV[5]={} APEXREV[6]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV[4].address=xand+mcO+12
            APEXREV[4].flags=4
            APEXREV[5].address=xand+mcO+16
            APEXREV[5].flags=4
            APEXREV[6].address=xand+mcO+20
            APEXREV[6].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1 
            EDIT[1]={} EDIT[2]={} EDIT[3]={} 
            EDIT[4]={} EDIT[5]={} 
            EDIT[1].address=xand+mcO
            EDIT[1].value=xxqword1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=xxqword2
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=xxqword3
            EDIT[3].flags=4
            EDIT[4].address=xand+mcO+12
            EDIT[4].value=xxqword4
            EDIT[4].flags=4
            EDIT[5].address=xand+mcO+16
            EDIT[5].value=xxqword5
            EDIT[5].flags=4
                if not v.x64 then 
                EDIT[6]={} 
                EDIT[6].address=xand+mcO+20
                EDIT[6].value=xEND 
                EDIT[6].flags=4  
                end
            gg.setValues(EDIT) 
            gg.toast("QWORD -9.2e18") 
            cc=1 
        end -- isOffset 1 
---------------------------              
         if isOffset==2 then
              METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=xxqword1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=xxqword2
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=xxqword3
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+12
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+12
                EDIT[c].value=xxqword4
                EDIT[c].flags=4   
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+16
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+16
                EDIT[c].value=xxqword5
                EDIT[c].flags=4    
                    if not v.x64 then 
                    c=c+1
                    APEXREV[c]={} 
                    APEXREV[c].address=xload[i].address+20
                    APEXREV[c].flags=4
                    EDIT[c]={}
                    EDIT[c].address=xload[i].address+20
                    EDIT[c].value=xEND 
                    EDIT[c].flags=4    
                   end    
               cc=cc+1 
            end -- for I 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  QWORD -9.2e18") 
        end  -- isOffset 2   
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end                           
    end -- minch 5
---------------------------        
end -- xMINIMUM 

--███████████████████████
--███████████████████████
--███████████████████████
--███████████████████████
 
function xINT()
APEXREV=nil APEXREV={}
EDIT=nil EDIT={} c=0 cc=0 
BITCHASS=nil BITCHASS=tsEV 
clear() wait() 
INTX[1].value=mcEV
gg.setValues(INTX) 
CHECK=gg.getValues(INTX) 
CHECK=nil 
CHECK=gg.getValues(INTX) 
    if CHECK[1].value ~= mcEV or tostring(CHECK[1].value) == "inf" or tostring(CHECK[1].value) == "NaN" then
        gg.toast("×× ERROR ××") 
        gg.alert("×× ERROR ××\n"..BITCHASS.."\nInvalid Number for Value Type","MENU",nil,xTAGx) 
        menu() return
    end 
gg.loadResults(AP) 
GET=gg.getResults(4) 
HEX={}

    if is64 then 
        for i ,v in ipairs(GET) do
            if GET[i].value<0 then 
                HEX[i]="-0x"..string.format("%X",tostring(GET[i].value*(-1)))
            else
                HEX[i]="0x"..string.format("%X",tostring(GET[i].value))
            end 
        end  -- for loop 

        x1="~A8 MOV W0, #"..tostring(HEX[1]) 
        if tostring(HEX[1])=="0x0" then x1=xMOVW0 end
        if tonumber(HEX[1])==-1 then x1="~A8 MOV W0, #0xFFFF" end
        
        x2="~A8 MOVK W0, #"..tostring(HEX[2])..", LSL #16" 
        if tostring(HEX[2])=="0x0" then x2=xMOVKW016 end 
              
    else -- if 64
        
        if GET[1].value<0 then xx1=65536+GET[1].value else xx1=GET[1].value end
        if GET[2].value<0 then xx2=65536+GET[2].value else xx2=GET[2].value end
        
        x1="~A MOVW R0, #"..xx1
        x2="~A MOVT R0, #"..xx2 
    
    end -- if 32 


        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={}
            EDIT[1]={} EDIT[2]={} EDIT[3]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            EDIT[1].address=xand+mcO 
            EDIT[1].value=x1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=x2
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=xEND 
            EDIT[3].flags=4
            gg.setValues(EDIT) 
            gg.toast("INT = "..mcEV) 
            cc=1 
        end 
---------------------------        
        if isOffset==2 then 
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=x1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=x2
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=xEND 
                EDIT[c].flags=4
                cc=cc+1 
            end
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  INT = "..mcEV) 
        end                
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end         

end -- xINT() 
--███████████████████████

function xFLOATE()
APEXREV=nil APEXREV={}
EDIT=nil EDIT={} c=0 cc=0 
BITCHASS=nil BITCHASS=tsEV 
clear() wait() 
FLOATX[1].value=mcEV
gg.setValues(FLOATX) 
CHECK=nil 
CHECK=gg.getValues(FLOATX) 
    if tostring(CHECK[1].value) == "inf" or tostring(CHECK[1].value) == "NaN" then
        gg.toast("×× ERROR ××") 
        gg.alert("×× ERROR ××\n"..BITCHASS.."\nInvalid Number for Value Type","MENU",nil,xTAGx) 
        menu() return
    end 
gg.loadResults(AP) 
GET=gg.getResults(4) 
HEX={}

    if is64 then 
        for i ,v in ipairs(GET) do
            if GET[i].value<0 then 
                HEX[i]="-0x"..string.format("%X",tostring(GET[i].value*(-1)))
            else
                HEX[i]="0x"..string.format("%X",tostring(GET[i].value))
            end 
        end -- for loop 

        x1="~A8 MOV W0, #"..tostring(HEX[1]) 
        if tostring(HEX[1])=="0x0" then x1=xMOVW0 end
        if tonumber(HEX[1])==-1 then x1="~A8 MOV W0, #0xFFFF" end
        
        x2="~A8 MOVK W0, #"..tostring(HEX[2])..", LSL #16" 
        if tostring(HEX[2])=="0x0" then x2=xMOVKW016 end 
                
    else -- if 64

        if GET[1].value<0 then xx1=65536+GET[1].value else xx1=GET[1].value end
        if GET[2].value<0 then xx2=65536+GET[2].value else xx2=GET[2].value end
        
        x1="~A MOVW R0, #"..xx1
        x2="~A MOVT R0, #"..xx2 
    
    end -- if 32 


        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={}
            EDIT[1]={} EDIT[2]={} EDIT[3]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            EDIT[1].address=xand+mcO 
            EDIT[1].value=x1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=x2
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=xEND 
            EDIT[3].flags=4
            gg.setValues(EDIT) 
            gg.toast("F equiv "..mcEV) 
            cc=1 
        end 
---------------------------        
        if isOffset==2 then 
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0 cc=0 
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=x1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=x2
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=xEND 
                EDIT[c].flags=4
                cc=cc+1 
            end
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..c.." ]  F equiv"..mcEV) 
        end   
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end         
end -- xFLOATE()          

--███████████████████████

function xFLOATR() 
APEXREV=nil APEXREV={}
EDIT=nil EDIT={} c=0 cc=0 
BITCHASS=nil BITCHASS=tsEV 
clear() wait() 
FLOATX[1].value=mcEV
gg.setValues(FLOATX) 
CHECK=nil 
CHECK=gg.getValues(FLOATX) 
    if tostring(CHECK[1].value) == "inf" or tostring(CHECK[1].value) == "NaN" then
        gg.toast("×× ERROR ××") 
        gg.alert("×× ERROR ××\n"..BITCHASS.."\nInvalid Number for Value Type","MENU",nil,xTAGx) 
        menu() return
    end 
gg.loadResults(AP) 
GET=gg.getResults(4) 
HEX={}

    if is64 then 
        for i ,v in ipairs(GET) do
            if GET[i].value<0 then 
                HEX[i]="-0x"..string.format("%X",tostring(GET[i].value*(-1)))
            else
                HEX[i]="0x"..string.format("%X",tostring(GET[i].value))
            end 
        end 

        x1="~A8 MOV W0, #"..tostring(HEX[1]) 
        if tostring(HEX[1])=="0x0" then x1=xMOVW0 end 
        if tonumber(HEX[1])==-1 then x1="~A8 MOV W0, #FFFF0000" end 
        
        x2="~A8 MOVK W0, #"..tostring(HEX[2])..", LSL #16"
        if tostring(HEX[2])=="0x0" then x2=xMOVKW016 end  
        
        x3=xFMOVS0W0 
        x4=xEND 
        
    else -- if 64

        if GET[1].value<0 then xx1=65536+GET[1].value else xx1=GET[1].value end
        if GET[2].value<0 then xx2=65536+GET[2].value else xx2=GET[2].value end
        
        x1="~A MOVW R0, #"..xx1
        x2="~A MOVT R0, #"..xx2 
        x3="~A VMOV S15, R0" 
        x4="~A VMOV.F32 S0, S15" 
    
    end -- if 32

        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={} 
            APEXREV[4]={} APEXREV[5]={} 
            EDIT[1]={} EDIT[2]={} EDIT[3]={} EDIT[4]={}
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4 
            APEXREV[4].address=xand+mcO+12
            APEXREV[4].flags=4 
            APEXREV[5].address=xand+mcO+12
            APEXREV[5].flags=4 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            EDIT[1].address=xand+mcO 
            EDIT[1].value=x1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=x2
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=x3
            EDIT[3].flags=4
            EDIT[4].address=xand+mcO+12
            EDIT[4].value=x4
            EDIT[4].flags=4
                if not v.x64 then
                EDIT[5]={}
                EDIT[5].address=xand+mcO+16
                EDIT[5].value=xEND
                EDIT[5].flags=4
                end 
            gg.setValues(EDIT) 
            gg.toast("FLOAT = "..mcEV) 
            cc=1 
        end 
---------------------------        
        if isOffset==2 then 
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=x1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=x2
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=x3 
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+12
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+12
                EDIT[c].value=x4
                EDIT[c].flags=4
                    if not v.x64 then
                    c=c+1
                    EDIT[c] ={}
                    EDIT[c].address=xload[i].address+16 
                    EDIT[c].value=xEND
                    EDIT[c].flags=4
                    end 
                cc=cc+1 
            end
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..c.." ]  FLOAT = "..mcEV) 
        end                
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end         

end  -- xFLOATR() 

--███████████████████████

function xDOUBLE()
APEXREV=nil APEXREV={}
EDIT=nil EDIT={} c=0 cc=0 
BITCHASS=nil BITCHASS=tsEV 
clear() wait() 
DOUBLEX[1].value=mcEV
gg.setValues(DOUBLEX) 
CHECK=nil 
CHECK=gg.getValues(DOUBLEX) 
    if tostring(CHECK[1].value) == "inf" or tostring(CHECK[1].value) == "NaN" then
        gg.toast("×× ERROR ××") 
        gg.alert("×× ERROR ××\n"..BITCHASS.."\nInvalid Number for Value Type","MENU",nil,xTAGx) 
        menu() return
    end 
gg.loadResults(AP) 
GET=gg.getResults(4) 
HEX={}

    if is64 then 
        for i ,v in ipairs(GET) do
            if GET[i].value<0 then 
                HEX[i]="-0x"..string.format("%X",tostring(GET[i].value*(-1)))
            else
                HEX[i]="0x"..string.format("%X",tostring(GET[i].value))
            end 
        end 

        if tonumber(HEX[1])==-1 then HEX[1]="0xFFFF" end 
        x1="~A8 MOVK X0, #"..tostring(HEX[1])
        if tostring(HEX[1])=="0x0" then x1=xMOVKX0 end 
        
        if tonumber(HEX[2])==-1 then HEX[2]="0xFFFF" end 
        x2="~A8 MOVK X0, #"..tostring(HEX[2])..", LSL #16"
        if tostring(HEX[2])=="0x0" then x2=xMOVKX016 end 
        
        if tonumber(HEX[3])==-1 then HEX[3]="0xFFFF" end 
        x3="~A8 MOVK X0, #"..tostring(HEX[3])..", LSL #32"
        if tostring(HEX[3])=="0x0" then x3=xMOVKX032 end 
        
        if tonumber(HEX[4])==-1 then HEX[4]="0xFFFF" end 
        x4="~A8 MOVK X0, #"..tostring(HEX[4])..", LSL #48"
        if tostring(HEX[4])=="0x0" then x4=xMOVKX048 end 
        
        x5=xFMOVD0X0 
        x6=xEND 
    else -- if 64
        
        if GET[1].value<0 then xx1=65536+GET[1].value else xx1=GET[1].value end
        if GET[2].value<0 then xx2=65536+GET[2].value else xx2=GET[2].value end
        if GET[3].value<0 then xx3=65536+GET[3].value else xx3=GET[3].value end
        if GET[4].value<0 then xx4=65536+GET[4].value else xx4=GET[4].value end
        
        x1="~A MOVW R0, #"..xx1
        x2="~A MOVT R0, #"..xx2 
        x3="~A MOVW R1, #"..xx3
        x4="~A MOVT R1, #"..xx4
        x5="~A VMOV D16, R0, R1"
        x6="~A VMOV.F64 D0, D16"
    
    end -- if 32 
        

        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={} APEXREV[4]={}
            APEXREV[5]={} APEXREV[6]={} APEXREV[7]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV[4].address=xand+mcO+12
            APEXREV[4].flags=4
            APEXREV[5].address=xand+mcO+16
            APEXREV[5].flags=4
            APEXREV[6].address=xand+mcO+20
            APEXREV[6].flags=4
            APEXREV[7].address=xand+mcO+24
            APEXREV[7].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1 
            EDIT[1]={} EDIT[2]={} EDIT[3]={} EDIT[4]={}
            EDIT[1].address=xand+mcO
            EDIT[1].value=x1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=x2
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=x3
            EDIT[3].flags=4
            EDIT[4].address=xand+mcO+12
            EDIT[4].value=x4
            EDIT[4].flags=4                
            EDIT[5]={}
            EDIT[5].address=xand+mcO+16
            EDIT[5].value=x5
            EDIT[5].flags=4
            EDIT[6]={} 
            EDIT[6].address=xand+mcO+20
            EDIT[6].value=x6
            EDIT[6].flags=4
                if not v.x64 then 
                EDIT[7]={} 
                EDIT[7].address=xand+mcO+24
                EDIT[7].value=xEND 
                EDIT[7].flags=4
                end
            gg.setValues(EDIT)  
            gg.toast("DOUBLE "..mcEV) 
            cc=1 
        end -- isOffset 1
---------------------------                        
        if isOffset==2 then 
             METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=x1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=x2
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=x3
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+12
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+12
                EDIT[c].value=x4
                EDIT[c].flags=4   
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+16
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+16
                EDIT[c].value=x5
                EDIT[c].flags=4    
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+20
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+20
                EDIT[c].value=x6
                EDIT[c].flags=4    
                    if not v.x64 then 
                    c=c+1
                    APEXREV[c]={} 
                    APEXREV[c].address=xload[i].address+24
                    APEXREV[c].flags=4
                    EDIT[c]={}
                    EDIT[c].address=xload[i].address+24
                    EDIT[c].value=xEND 
                    EDIT[c].flags=4    
                   end    
               cc=cc+1 
            end -- for I 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  DOUBLE "..mcEV) 
        end  -- isOffset 2                 
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end         

end -- xDOUBLE() 

--███████████████████████

function xQWORD()
APEXREV=nil APEXREV={}
EDIT=nil EDIT={} c=0 cc=0 
BITCHASS=nil BITCHASS=tsEV 
clear() wait() 
QWORDX[1].value=mcEV
gg.setValues(QWORDX) 
CHECK=nil 
CHECK=gg.getValues(QWORDX) 
    if CHECK[1].value ~= mcEV or tostring(CHECK[1].value) == "inf" or tostring(CHECK[1].value) == "NaN" then
        gg.toast("×× ERROR ××") 
        gg.alert("×× ERROR ××\n"..BITCHASS.."\nInvalid Number for Value Type","MENU",nil,xTAGx) 
        menu() return
    end 
gg.loadResults(AP) 
GET=nil GET=gg.getResults(4) 
HEX=nil HEX={}

    if is64 then 
        for i ,v in ipairs(GET) do
            if GET[i].value<0 then 
                HEX[i]="-0x"..string.format("%X",tostring(GET[i].value*(-1)))
            else
                HEX[i]="0x"..string.format("%X",tostring(GET[i].value))
            end 
        end 

        if tonumber(HEX[1])==-1 then HEX[1]="0xFFFF" end
        x1="~A8 MOVK X0, #"..tostring(HEX[1])
        if tostring(HEX[1])=="0x0" then x1=xMOVKX0  end 
    
        if tonumber(HEX[2])==-1 then HEX[2]="0xFFFF" end 	
        x2="~A8 MOVK X0, #"..tostring(HEX[2])..", LSL #16" 
        if tostring(HEX[2])=="0x0" then x2=xMOVKX016 end 
    
        if tonumber(HEX[3])==-1 then HEX[3]="0xFFFF" end 	
        x3="~A8 MOVK X0, #"..tostring(HEX[3])..", LSL #32" 
        if tostring(HEX[3])=="0x0" then x3=xMOVKX032 end 
    
        if tonumber(HEX[4])==-1 then HEX[4]="0xFFFF" end 	
        x4="~A8 MOVK X0, #"..tostring(HEX[4])..", LSL #48" 
        if tostring(HEX[4])=="0x0" then x4=xMOVKX048 end 
    
        x5="hC0035FD6"
        
    else -- if 64

        if GET[1].value<0 then xx1=65536+GET[1].value else xx1=GET[1].value end
        if GET[2].value<0 then xx2=65536+GET[2].value else xx2=GET[2].value end
        if GET[3].value<0 then xx3=65536+GET[3].value else xx3=GET[3].value end
        if GET[4].value<0 then xx4=65536+GET[4].value else xx4=GET[4].value end
        
        x1="~A MOVW R0, #"..xx1
        x2="~A MOVT R0, #"..xx2 
        x3="~A MOVW R1, #"..xx3
        x4="~A MOVT R1, #"..xx4
        x5="~A VMOV D0, R0, R1"
    end  -- if 32

        if isOffset==1 then 
            APEXREV[1]={} APEXREV[2]={} APEXREV[3]={} 
            APEXREV[4]={} APEXREV[5]={} APEXREV[6]={} 
            APEXREV[1].address=xand+mcO
            APEXREV[1].flags=4
            APEXREV[2].address=xand+mcO+4
            APEXREV[2].flags=4
            APEXREV[3].address=xand+mcO+8
            APEXREV[3].flags=4
            APEXREV[4].address=xand+mcO+12
            APEXREV[4].flags=4
            APEXREV[5].address=xand+mcO+16
            APEXREV[5].flags=4
            APEXREV[6].address=xand+mcO+20
            APEXREV[6].flags=4
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1 
            EDIT[1]={} EDIT[2]={} EDIT[3]={} 
            EDIT[4]={} EDIT[5]={} 
            EDIT[1].address=xand+mcO
            EDIT[1].value=x1
            EDIT[1].flags=4
            EDIT[2].address=xand+mcO+4
            EDIT[2].value=x2
            EDIT[2].flags=4
            EDIT[3].address=xand+mcO+8
            EDIT[3].value=x3
            EDIT[3].flags=4
            EDIT[4].address=xand+mcO+12
            EDIT[4].value=x4
            EDIT[4].flags=4
            EDIT[5].address=xand+mcO+16
            EDIT[5].value=x5 
            EDIT[5].flags=4
                if not v.x64 then 
                EDIT[6]={} 
                EDIT[6].address=xand+mcO+20
                EDIT[6].value=xEND 
                EDIT[6].flags=4  
                end
            gg.setValues(EDIT) 
            gg.toast("QWORD "..mcEV) 
            cc=1 
        end -- isOffset 1 
---------------------------              
         if isOffset==2 then
              METHODSEARCH() if methodSuccess==0  then return end 
            clear() wait() 
            c=0
            for i, v in ipairs(xload) do
                c=c+1
                APEXREV[c] ={}
                APEXREV[c].address=xload[i].address
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address
                EDIT[c].value=x1
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+4
                APEXREV[c].flags=4
                EDIT[c]={} 
                EDIT[c].address=xload[i].address+4
                EDIT[c].value=x2
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+8
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+8
                EDIT[c].value=x3
                EDIT[c].flags=4
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+12
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+12
                EDIT[c].value=x4
                EDIT[c].flags=4   
                c=c+1
                APEXREV[c]={} 
                APEXREV[c].address=xload[i].address+16
                APEXREV[c].flags=4
                EDIT[c]={}
                EDIT[c].address=xload[i].address+16
                EDIT[c].value=x5
                EDIT[c].flags=4    
                    if not v.x64 then 
                    c=c+1
                    APEXREV[c]={} 
                    APEXREV[c].address=xload[i].address+20
                    APEXREV[c].flags=4
                    EDIT[c]={}
                    EDIT[c].address=xload[i].address+20
                    EDIT[c].value=xEND 
                    EDIT[c].flags=4    
                   end    
               cc=cc+1 
            end -- for I 
            APEXREV=gg.getValues(APEXREV) 
            REVERT=1
            gg.setValues(EDIT) 
            gg.toast("[ "..cc.." ]  QWORD "..mcEV) 
        end  -- isOffset 2                     
        if COPYHEX==1then copyhex() end
        if SCRIPTIT==1 then scripit() end             

end  -- xQWORD() 

--███████████████████████
--███████████████████████

function copyhex()
gg.sleep(1200) 
    if EDIT==nil or #(EDIT)==0 then
        gg.alert("No Edits to Copy")
        return
    end 

cpych=gg.choice({"ARM HEX","OP CODES","0xOFFSET"},0,xTAGx.."\nSELECT TO COPY")
    if cpych==nil then gg.toast("CANCELLED") return end
    
    if cpych==1 then 
        CPY=nil VAL=nil 
        CPY={} VAL=gg.getValues(EDIT) 
            for i,  v in ipairs(VAL) do
                CPY[i]="    '"..string.sub(string.format("%X",tostring(VAL[i].value)),-8,-1).."h'" 
            end 
        CPY=table.concat(CPY,",\n") 
        gg.copyText("ApexHEX_"..mcO.."_"..mcEV.."={\n"..CPY.."\n    }", false) 
        gg.toast("COPIED ARM HEX\n"..CPY)        
    end
    
    if cpych==2 then
        CPY=nil VAL=nil 
        CPY={} 
            for i, v in ipairs(EDIT) do
                CPY[i]="    '"..tostring(v.value).."'"
            end
        CPY=table.concat(CPY,",\n") 
        gg.copyText("ApexOPCodes_"..mcO.."_"..mcEV.."={\n"..CPY.."\n    }", false) 
        gg.toast("COPIED OP CODES\n"..CPY)         
    end
    
    if cpych==3 then
        if isOffset~=2 then 
            gg.alert("No Need to Copy 0xOFFSET\nYou Already Know it  ;-)")
            return
        end 
        cpyoffx=nil cpyoffx={}
        for i = 1,#(I) do  
            cpyoffx[i]="0x"..string.format("%X",tostring(I[i]))
        end
        cpyoffx=tostring(table.concat(cpyoffx,"\n"))
        gg.copyText(cpyoffx, false) 
        gg.toast("0xOFFSET("..#(I)..")  COPIED") 
    end 
    
COPYHEX=0     
end -- copyhex 

--███████████████████████

function scripit()
gg.sleep(2000) 
    if EDIT==nil or #(EDIT)==0 then
        gg.alert("No Edits to Script")
        return
    end     

    if isOffset==2 then 
        if #(I)~=1 then
            gg.alert("×× SCRIPT IT ××\nRequires to have only 1 result from Method Search. Try Including Class Name.","OK",nil,xTAGx) 
            return
        end
        mcOxxx=tostring("0x"..string.format("%X%",tostring(I[1])))
    else 
        mcOxxx=mcO
    end 


CPY=nil 
SS=nil SS={}
VAL=nil VAL=gg.getValues(EDIT) 

    if liblib=="Split Apk" then 
        gg.alert("##  SCRIPT IT  ##\nSplit APK Detected.\n'Script It' feature will only work on your device.")
        grl=gg.getRangesList()
            for i, v in ipairs(grl)  do
                if VAL[1].address>grl[i].start and VAL[1].adress<grl[i]["end"] then
                    GRL=tostring(grl[i].name) 
                end
            end 
        SINDEX=0 
        xGRL=gg.getRangesList(GRL) 
            for i, v in ipairs(xGRL) do
                if v.state=="Xa" then
                    SINDEX=i 
                end
            end 
            if SINDEX==0 then gg.alert("×× ERROR ××\nSplit APK\nConfiguring Lib Index Failed") return end 
        xGRLx=GRL
        xxxxxxxxxx=SINDEX
    else
        xGRLx=libzz
    end 

SS[1]="ACKA01=gg.getRangesList('"..xGRLx.."')["..xxxxxxxxxx.."].start"
SS[2]="APEX=nil  APEX={}" 
ss=3 addo=0
    for i, v in ipairs(VAL) do 
    SS[ss]="APEX["..i.."]={}"
    ss=ss+1
    SS[ss]="APEX["..i.."].address=ACKA01+"..mcOxxx.."+"..addo
    ss=ss+1
    ACKA=string.sub(string.format("%X",tostring(VAL[i].value)),-8,-1)
    SS[ss]="APEX["..i.."].value='"..ACKA.."h'" 
    ss=ss+1
    SS[ss]="APEX["..i.."].flags=4"
    ss=ss+1 
    addo=addo+4 
    end 
SS[ss]="gg.setValues(APEX)"

SS=table.concat(SS,"\n")
CPY=gg.alert(tostring(SS),"COPY","CLOSE",xTAGx) 
    if CPY==1 then gg.copyText(tostring(SS),false) end
SCRIPTIT=0 

end  -- script it 

--███████████████████████

wmytab={}
wmytab[1]=[[mytab={}]]
wmytab[2]=[[mytab[1]='× Delete All Notes' ]]
wmytab[3]=[[mytab[2]='× Delete Selected Notes' mytab[3]='√ Add New Note']]  
wmycontext={}
wmycontext[1]=[[mycontext={}]]
wmycontext[2]=[[mycontext[1]="<{OFFSET TESTER}>"]] 
wmycontext[3]=[[mycontext[2]="Hacking is the Game" mycontext[3]='https://t.me/apexgg2Home']]


function notes()
mytab=nil mycontext=nil 
path1=gg.getFile():gsub('[^/]+$',"") 
path1=path1.."[Xa]-EDIT-NOTES.lua" 
SFILEx=nil 
SFILEx=io.open(path1)
    if SFILEx==nil then 
        mytab={}
        mytab[1]="× Delete All Notes"
        mytab[2]="× Delete Selected Notes"
        mytab[3]="+ Add New Note" 
        mycontext={}
        mycontext[1]="<{OFFSET TESTER}>"
        mycontext[2]="Hacking is the Game" 
        mycontext[3]="https://t.me/apencontext"  
    else 
        SFILEx=io.open(path1):read("*all")
        pcall(load(SFILEx)) 
        for i = 4,#(mytab) do
            wmytab[i]="mytab["..i.."]='"..mytab[i].."'" 
            wmycontext[i]="mycontext["..i.."]='"..mycontext[i].."'" 
        end 
    end 

mctype={} 
    for i = 1,104 do mctype[i]="checkbox" end

selectednote=#(mytab)+1

mnmc=gg.prompt(mytab,nil,mctype)
    if mnmc==nil then gg.toast("CANCELLED") menu() return end
    if mnmc[1] then deletenotes() return end
 
    if mnmc[2] then  
        for i = 4,#(mytab) do
            if mnmc[i] then 
                for a=i,#(mytab) do
                    if a==#(mytab) then 
                        table.remove(mytab, a) 
                        table.remove(wmytab, a)
                        table.remove(mycontext, a)
                        table.remove(wmycontext, a)
                    else 
                        mytab[a]=mytab[a+1]
                        mycontext[a]=mycontext[a+1]
                        wmytab[a]="mytab["..a.."]='"..mytab[a].."'" 
                        wmycontext[a]="mycontext["..a.."]='"..mycontext[a].."'"                    
                    end 
                end 
                tcwmytab=table.concat(wmytab, "\n")
                tcwmycontext=table.concat(wmycontext, "\n") 
                os.remove(path1) 
                io.open(path1,"w"):write(tcwmytab.."\n"..tcwmycontext):close()
                break 
            end 
        end 
    notes()
    return
    end 
    
    if mnmc[3] then addnotes() return end 
    
    if not mnmc[2] then 
        for i = 4,#(mytab) do
            if mnmc[i] then selectednote=i break end 
        end 
        thisnote()
    end
    
end -- notes 

-----------------------------------------------------------

function deletenotes()
os.remove(path1) 
gg.alert("\nSAVED NOTES DELETED","OK",nil, xTAGx) 
notes()
return
end 

-----------------------------------------------------------

nname="" ncontext=""

function addnotes()
    if selectednote>103 then gg.alert("TOO MANY NOTES\nMax Notes = 100","OK",nil,xTAGx) 
        notes()
        return
    end 
    
nname="" ncontext=""
newnote=gg.prompt({"Note Name","Note Context"},{[1]=nname,[2]=ncontext},{[1]="text",[2]="text"})
    if newnote==nil then gg.toast("CANCELLED") notes() return end
    if #(newnote[1])==0 then gg.toast("NAME INCOMPLETE") addnotes() return end
nname=tostring(newnote[1])	
ncontext=tostring(newnote[2])
mytab[selectednote]="'"..nname.."'" 
mycontext[selectednote]="'"..ncontext.."'" 
wmytab[selectednote]="mytab["..selectednote.."]='"..nname.."'" 
wmycontext[selectednote]="mycontext["..selectednote.."]='"..ncontext.."'" 

tcwmytab=table.concat(wmytab, "\n")
tcwmycontext=table.concat(wmycontext, "\n") 

os.remove(path1) 
io.open(path1,"w"):write(tcwmytab.."\n"..tcwmycontext):close()

notes()
return
end 
    
-----------------------------------------------------------

function thisnote()
newnote=gg.prompt({
    "Note Name",
    "Copy Note Name",
    "Note Context",
    "Copy Note Context"},
    {[1]=tostring(mytab[selectednote]),
    [3]=tostring(mycontext[selectednote])},
    {[1]="text",[2]="checkbox",[3]="text",[4]="checkbox"})
   
    if newnote==nil then gg.toast("CANCELLED") notes() return end 
    if #newnote[1]==0 then gg.toast("NOTE INCOMPLETE") thisnote() return end 
    if newnote[2] then gg.copyText(tostring(newnote[1]),false) gg.toast(tostring(newnote[1])) end
    if newnote[4] then gg.copyText(tostring(newnote[3]),false) gg.toast(tostring(newnote[2])) end

nname=tostring(newnote[1])	
ncontext=tostring(newnote[3])
mytab[selectednote]="'"..nname.."'" 
mycontext[selectednote]="'"..ncontext.."'" 

wmytab[selectednote]="mytab["..selectednote.."]='"..nname.."'" 
wmycontext[selectednote]="mycontext["..selectednote.."]='"..ncontext.."'" 

tcwmytab=table.concat(wmytab, "\n")
tcwmycontext=table.concat(wmycontext, "\n") 

os.remove(path1) 
io.open(path1,"w"):write(tcwmytab.."\n"..tcwmycontext):close()
 
notes()
return
end 

--███████████████████████
--███████████████████████

function infohelp()
gg.alert([[INFO / HELP

FLOAT (equivalent) 
   This will be an INT value that
   is Equivalent to the Float Value. 

FLOAT (real)
   This is a Real Float Value made
   from floating register. 

QWORD
   Qword Real Maximum Value 
   for x32 Could Not be made, 
   the Max is actually 1000 less.
   If You Enter a Value that is not
   supported,  it will = 10,000

COPY ARM HEX / SCRIPT IT 
   An Edit must be performed
   same time as selecting one
   of these options. 

ENTER METHOD NAME ONLY
    * Unity Games Only *
    This will find lib offsets for
    ALL methods with that name
    and edit all. The Function
    must be propogated to be
    found. 

METHOD + CLASS NAME
    * Unity Games Only *
    Paste Method Name First, 
    with NO spaces enter a ~
    then paste Class Name. 
    get_health~Player_Controller
    Class must be propogated
    to find results. 

SEARCH CLASS NAME
   * Unity Games Only *
   For Field Offset. 
   Class Must be propogated 
   to find results. You may
   need to refine results. 

REPLACE
   * Unity Games Only *
   Enter 0xOffset then an
   = sign,  and then another
   0xOffset. 
   0xABCD=0x1234
   When function 0xABCD is
   called by game, it will
   call 0x1234 instead. 
   Example 0xABCD is for
   void playerForfeit() and
   0x1234 is void playerWin()
   REPLACE will make you win
   when you pause and forfeit. 
   Many factors can cause
   this to crash game. Know
   what you are doing before
   complaining about it. 

VALUES IN RANGE
   Script does not check
   if your edit value is within
   valid range for value type. 
   You need to know range 
   limits. If you Exceed limit, 
   Script / gg will error. 

SAVE / LOAD NOTES
   You can permanently save
   your own Notes, and copy
   the contents. Notes will 
   save to file and can be 
   deleted at anytime. 

PC EMULATOR  & x86
   Script is not optimized for
   PC use.  It may or may not
   work correctly. 
   Script will definitely Not work
   with x86 Architecture. 

GG FORUM OP CODES
   Search the GG Forums for
   "How to write OP Codes" ~
   and find my post by APEXggV2
   There will be a downloadable
   PDF file explaining in detail
   how to create any op code for
   any value and type. 

Made by  <{OFFSET TESTER}>
https://t.me/apexgg2Home
and Acka01]],"MENU")
menu()
return
end  -- infohelp 


--███████████████████████
--███████████████████████
--███████████████████████
--███████████████████████
function clear()
gg.getResults(gg.getResultsCount())
gg.clearResults()
end
------------------------------------------------------------------------------  
function search()
gg.getResults(gg.getResultsCount())
gg.clearResults()
gg.searchNumber(x,t) 
end 
------------------------------------------------------------------------------  
function refine()
gg.refineNumber(x,t) 
end 
------------------------------------------------------------------------------  
function check()
E=nil E=gg.getResultsCount()
end 
------------------------------------------------------------------------------  
function offset()
o=tonumber(o) addoff=nil 
addoff=gg.getResults(gg.getResultsCount())
    for i, v in ipairs(addoff) do
        addoff[i].address=addoff[i].address+o
        addoff[i].flags=t
    end
gg.loadResults(addoff) 
end 
------------------------------------------------------------------------------  
function cancel()
gg.toast("CANCELLED")
end 
------------------------------------------------------------------------------  
function wait()
gg.toast("Please Wait..") 
end 
------------------------------------------------------------------------------  
function error()
gg.toast("× ERROR ×")
gg.sleep(1000)
end 
------------------------------------------------------------------------------  
function exit()
gg.getListItems()
gg.clearList()
gg.getResults(gg.getResultsCount())
gg.clearResults()
gg.toast("[ EXIT ]")  
    if xhaX~=nil then 
        print(printx) 
        print(xhaX) 
        print(printx)  
    end 
gg.setVisible(true) 
return
end 
--███████████████████████

function METHODSEARCH()
methodSuccess=0
I=nil I={} 
A=nil A={} A[1]={} 
A[1].method=mcOC  
    if mcCO==nil then 
        xmcCO="nil" 
    else 
        xmcCO=mcCO 
        A[1].class=mcCO 
    end 
    
A[1].start=nil A[1].finish=nil A[1].error=1

if xsox==1 then xsotext="-- SEARCH ONLY --" else xsotext="SEARCH + EDIT" end 
    yes=gg.alert(xsotext.."\n\nMethod Name =\n  '"..mcOC.."'\n\nClass Name =\n  '"..xmcCO.."'","YES","NO","CORRECT ?")
        if yes~=1 then REVERT=0 menu() return end 

if is64 then off1=-16 typ=32 else off1=-8 typ=4 end 
gg.setRanges(gg.REGION_OTHER | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS) 
gmdx=gg.getRangesList("global-metadata.dat")
    if #(gmdx)~=0 then        
    gmds=gg.getRangesList("global-metadata.dat")[1].start
    gmde=gg.getRangesList("global-metadata.dat")[1]["end"] 
    else gmds=nil gmde=nil
    end 

ATOTAL=1 
ASTART=1 AEND=0 ATABT=ATOTAL+1 ATAB=1
S=0 
    while ATAB<=ATOTAL do 
    ::AUTOSTART::
    gg.setVisible(false)
        if ATAB>ATOTAL then break goto FINISHED end 
    gg.toast("Please Wait.. [ "..ATABT-ATAB.." ]") 
    A[ATAB].error=1 

    ACLASS=nil ACLASS={}
    if A[ATAB].class~=nil then 
        for i = 1,#(tostring(A[ATAB].class))+1 do
            if i == #(tostring(A[ATAB].class))+1 then 
                ACLASS[i]=0 
            else
                ACLASS[i]=string.byte(A[ATAB].class,i) 
            end 
        end 
    else
        A[ATAB].class=0
    end 
    
                ASTART=AEND+1
                clear() t=1 
                ::GMDSE:: 
                gg.searchNumber(":"..tostring(A[ATAB].method),1,false,gg.SIGN_EQUAL,gmds,gmde) 
                xm=gg.getResults(2) gg.getResults(gg.getResultsCount())
                check() 
                    if E==0 and gmds~=nil then gmds=nil gmde=nil goto GMDSE return end
                    if E==0 and gmds==nil then ATAB=ATAB+1 
                        if ATAB>ATOTAL then break return end
                    goto AUTOSTART return 
                    end 
                x=xm[1].value..";"..xm[2].value.."::2" refine()
                x=xm[1].value refine() 
                o=-1 offset() x=0 refine() oo=#(tostring(A[ATAB].method))
                o=oo+1 offset() refine() o=-oo offset()
                check() 
                    if E==0 then ATAB=ATAB+1 
                        if ATAB>ATOTAL then break return end
                    goto AUTOSTART return 
                    end 
                gg.searchPointer(0) xcount=gg.getResultsCount()
                xpoint=gg.getResults(xcount,nil, nil, nil, nil, nil, nil, nil,gg.POINTER_READ_ONLY)
                    if #(xpoint)==0 then ATAB=ATAB+1 
                        if ATAB>ATOTAL then break return end
                    goto AUTOSTART return 
                    end 
                clear() 
                    for xp=1,#(xpoint) do
                    xpoint[xp].address=xpoint[xp].address+off1
                    xpoint[xp].flags=typ
                    end
                gg.loadResults(xpoint) 
                xoff=gg.getResults(#(xpoint),nil, nil, nil, nil, nil, nil, nil, gg.POINTER_EXECUTABLE | gg.POINTER_READ_ONLY)
                    if #(xoff)==0 then ATAB=ATAB+1 
                        if ATAB>ATOTAL then break return end
                    goto AUTOSTART return 
                    end 
                    xfin=1
                    while xfin<=#(xoff) do 
                    ::XFIN:: 
                        if xfin>#(xoff) then ATAB=ATAB+1
                            if ATAB>ATOTAL then break return end 
                        goto AUTOSTART return
                        end 
                        if gg.getTargetInfo().x64 then 
                            xadd=tonumber(xoff[xfin].value)  
                        else 
                            xadd=string.format("%X",tonumber(xoff[xfin].value)) 
                            xadd=string.sub(tostring(xadd), -8,-1)
                            xadd=tonumber("0x"..xadd) 
                        end     
                    gval1=nil gval1={} gval1[1]={}
                        if gg.getTargetInfo().x64 then gvo=24 gvo1=16 gvo2=24 else gvo=12 gvo1=8 gvo2=12 end 
                    gval1[1].address=xoff[xfin].address+gvo
                    gval1[1].flags=typ
                    gval1=gg.getValues(gval1) 
                        if gg.getTargetInfo().x64 then 
                            gval=tonumber(gval1[1].value)  
                        else 
                            gval=string.format("%X",tonumber(gval1[1].value)) 
                            gval=string.sub(tostring(gval), -8,-1)
                            gval=tonumber("0x"..gval) 
                        end     
                    gval2=nil gval2={} gval2[1]={} gval2[2]={}
                    gval2[1].address=gval+gvo1
                    gval2[1].flags=typ
                    gval2[2].address=gval+gvo2
                    gval2[2].flags=typ 
                    gval2=gg.getValues(gval2)
                        if gg.getTargetInfo().x64 then 
                            gval21=tonumber(gval2[1].value)  
                            gval22=tonumber(gval2[2].value) 
                        else 
                            gval21=string.format("%X",tonumber(gval2[1].value)) 
                            gval21=string.sub(tostring(gval21), -8,-1)
                            gval21=tonumber("0x"..gval21) 
                            gval22=string.format("%X",tonumber(gval2[2].value)) 
                            gval22=string.sub(tostring(gval22), -8,-1)
                            gval22=tonumber("0x"..gval22) 
                        end    
                         xrefine=0
                         if A[ATAB].class~=0 then 
                            for xyz=1,#(ACLASS) do
                                gvalc={} gvalc[1]={} 
                                gvalc[1].address=gval21+(xyz-1)
                                gvalc[1].flags=1                        
                                gvalc=gg.getValues(gvalc) 
                                if gvalc[1].value~=ACLASS[xyz] then xrefine=1 break xfin=xfin+1 goto XFIN end
                            end
                        end 
              
                         if xrefine==0 then 
                        A[ATAB].start=ASTART AEND=AEND+1
                        A[ATAB].finish=AEND 
                        A[ATAB].error=0 
                        clear() I[AEND]=xadd-xand
                        end 
                    xfin=xfin+1             
                    end -- xfin 
    ATAB=ATAB+1
    end -- ATAB 
---------------------------------------------------
::FINISHED:: 
e=0
    for i =1,#(A) do 
        if A[i].error==1 then e=e+1 end
    end 
    if e==#(A)  then 
        gg.alert("×× ERROR ××\nNo Method Offsets Found for:\n\nMethod \n  '"..mcOC.."'\n\nClass\n  '"..xmcCO.."'") 
    return 
    end 

 xload=nil xload={}
    for i = 1,#(I) do
    xload[i]={}
    xload[i].address=xand+I[i] 
    xload[i].flags=4 
    end
xload=gg.getValues(xload) 
methodSuccess=1
end -- METHODSEARCH 



--███████████████████████
--███████████████████████
--███████████████████████
--███████████████████████
xemu3=0
ICN="<{OFFSET TESTER}>"
IOX="0x"
ECN="Enter Class Name"
xECN=0
EOS="0x"
xEOS=0
EVT="Select Value Type"
xEVT=0
ERT="ANONYMOUS (A)" 
xACO=gg.REGION_ANONYMOUS 
ON="[√]  " 
OFF="[×]  "
xSx=OFF 

function menu2()
gg.setVisible(false)  
    if xemu3==0 then
    gg.alert("Class Search is for UNITY Only\nPress the [Sx] Button for Menu","OK",nil,"<{OFFSET TESTER}>")
    xemu3=1
    end
    
if xECN==1 and xEOS==1 and xEVT==1 then xSx=ON end 
if #(ECN)==0 then ECN="Enter Class Name" xECN=0 end
if #(EOS)==0 then EOS="Enter 0xOffset" xEOS=0 end
xchx=gg.choice({
	ECN, 
	EOS, 
	EVT, 
	ERT, 
	xSx.."START", 
	"<[ BACK ]>"},0,"<{OFFSET TESTER}>\nhttps://t.me/apexgg2Home\nClass Name Field Offset")
gg.showUiButton() 
	if xchx==nil then gg.toast("CANCELLED") return end

	if xchx==1 then enterclassname() return end
	if xchx==2 then enteroffset() return end
	if xchx==3 then selectvaluetype() return end 
	if xchx==4 then selectrange() return end
	if xchx==5 then START() return end 
	if xchx==6 then gg.setVisible(false) xCLASS=0 apex=0 gg.hideUiButton() menu() return end
end 

--███████████████████████

function enterclassname()
input=gg.prompt({"Paste / Enter Class Name"},{[1]=ECN},{[1]="text"})
if input==nil then menu2() return end
if #(input[1])==0 then gg.toast("INCOMPLETE") xECN=0 enterclassname() return end
ECN=tostring(input[1])
if string.match(ECN,"%s") then gg.alert("Class Name [×/√]\n\n× No Spaces ' '\n\n√ Underscore  _\n√ AlphaNumeric Characters Only\n√ aA~zZ   0~9","OK",nil,"<{OFFSET TESTER}>") xECN=0 enterclassname() return end
xslen=#(tostring(ECN)) 
    for i=1,xslen do
    x=nil x=string.byte(tostring(ECN),i) 
        if x==46 then 
        gg.alert("Class Name [×/√]\n\n× No Periods  ' . '\n\n√ Underscore  _\n√ AlphaNumeric Characters \n√ aA~zZ   0~9","OK",nil,"<{OFFSET TESTER}>") 
        xECN=0
        enterclassname() return 
        end
    end  
xECN=1
menu2()
return 
end 
	
--███████████████████████

function enteroffset()
input2=gg.prompt({"Paste / Enter 0xOffset"},{[1]=EOS},{[1]="number"})
if input2==nil then menu() return end 
if #(input2[1])<3 then xEOS=0 gg.toast("INCOMPLETE") enteroffset() return end 
if type(tonumber(input2[1]))~="number" then gg.toast("INVALID NUMBER") xEOS=0 enteroffset() return end
EOS=input2[1]
xEOS=1
menu2() 
return 
end 

--███████████████████████

function selectvaluetype()
ggtype=gg.choice({
	"Byte / Bool ",
	"Word ",
	"Dword / INT",
	"Float",
	"Qword",
	"Double"},0,"<{OFFSET TESTER}>\nSELECT VALUE TYPE_")
if ggtype==nil then menu2() return end
if ggtype==1 then tz=1 EVT="Byte / Bool" end
if ggtype==2 then tz=2 EVT="Word" end
if ggtype==3 then tz=4 EVT="Dword / INT" end
if ggtype==4 then tz=16 EVT="Float" end
if ggtype==5 then tz=32 EVT="Qword" end
if ggtype==6 then tz=64 EVT="Double" end 
xEVT=1
menu2()
return
end   

--███████████████████████

function selectrange()
input3=gg.choice({
	"ANONYMOUS (A)",
	"C_ALLOC (Ca)",
	"OTHER (O)"},0,"<{OFFSET TESTER}>\nSELECT REGION")
if input3==nil then menu2() return end
if input3==1 then ERT="ANONYMOUS (A)" xACO=gg.REGION_ANONYMOUS end
if input3==2 then ERT="C_ALLOC (Ca)" xACO=gg.REGION_C_ALLOC end
if input3==3 then ERT="OTHER (O)" xACO=gg.REGION_OTHER end 
menu2()
return 
end 

--███████████████████████

function START()
    if xSx==OFF then
    gg.alert("Please Complete All Information:\nClass Name\n0xOffset\nValue Type\nRegion","MENU",nil,"<{OFFSET TESTER}>")
    menu2() return
    end 

EXCLUDE=nil 
xlude=0
exclude=gg.multiChoice({
	"Remove NonValues",
	"Show ALL Results"},{[2]=true},"FILTER RESULTS\n\n- Remove NonValues:\n   Objects/Lists/Tables/Pointers\n\n- Or Show All Results Regardless")
    if exclude==nil then menu2() return end 
    if exclude[1] then EXCLUDE=1 xlude=xlude+1 end
    if exclude[2] then EXCLUDE=0 xlude=xlude+1 end 
    if xlude==2 then gg.toast("SELECT ONLY 1 OPTION") START() return end 
SEARCH()
end 

--███████████████████████

function SEARCH()
gg.toast("Please Wait..") 
gg.setRanges(gg.REGION_OTHER | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS) 
gmdx=gg.getRangesList("global-metadata.dat")
    if #(gmdx)~=0 then        
    gmds=gg.getRangesList("global-metadata.dat")[1].start
    gmde=gg.getRangesList("global-metadata.dat")[1]["end"] 
    else gmds=nil gmde=nil
    end 
 
 ::PCFS:: 
gg.clearResults()   
gg.searchNumber(":"..ECN,1,false,gg.SIGN_EQUAL,gmds,gmde)

    if gg.getResultsCount()==0 and gmds~=nil then gmds=nil gmde=nil goto PCFS return end 
    if gg.getResultsCount()==0 and gmds==nil then     
    gl=gg.getLine()  
    xerror=gg.alert("×× ERROR "..gl.." ××\n"..ECN.."\nNot Found","OK","MENU","<{OFFSET TESTER}>") 
        if xerror==2 then menu2() return end 
    return
    end
    
x=nil x=gg.getResults(1)
gg.getResults(gg.getResultsCount())
gg.refineNumber(tonumber(x[1].value),1)
x=nil x=gg.getResults(gg.getResultsCount())
gg.clearResults()
    for i, v in ipairs(x) do
    x[i].address=x[i].address-1
    x[i].flags=1
    end
x=gg.getValues(x) 
a={} aa=1 
    for i, v in pairs(x) do
        if x[i].value==0 then
        a[aa]={}
        a[aa].address=x[i].address
        a[aa].flags=1
        aa=aa+1
        end
    end
    
    if #(a)==0 then 
    gg.clearResults() 
    gl=gg.getLine() 
    xerror=gg.alert("×× ERROR "..gl.." ××\nClass Name With Pointer Not Found","OK","MENU","<{OFFSET TESTER}>")
    x=nil a=nil aa=nil 
        if xerror==2 then menu2() return end 
    return
    end 

x=nil
    for i, v in ipairs(a) do
    a[i].address=a[i].address+#(ECN)+1
    a[i].flags=1
    end
a=gg.getValues(a) 
ba=nil ba={} bb=1
    for i, v in ipairs(a) do
        if a[i].value==0 then
        ba[bb]={}
        ba[bb].address=a[i].address
        ba[bb].flags=1
        bb=bb+1
        end
    end

    if #(ba)==0 then 
    gg.clearResults() 
    gl=gg.getLine() 
    xerror=gg.alert("×× ERROR "..gl.." ××\nClass Name With Pointer Not Found","OK","MENU","<{OFFSET TESTER}>")
    x=nil a=nil aa=nil ba=nil bb=nil  
       if xerror==2 then menu2() return end 
    return
    end 

a=nil
    for i, v in ipairs(ba) do
    ba[i].address=ba[i].address-#(ECN) 
    ba[i].flags=1
    end
gg.loadResults(ba) 

gg.searchPointer(0)

    if gg.getResultsCount()==0 then
    gg.clearResults() 
    gl=gg.getLine() 
    xerror=gg.alert("×× ERROR "..gl.." ××\nNo Pointer Results From Class Name","OK","MENU","<{OFFSET TESTER}>") 
    ba=nil
       if xerror==2 then menu2() return end      
    return
    end

    if is64 then
        x=gg.getResults(gg.getResultsCount())
        clear() xx=nil xx={} xxx=nil xxx={} 
            for i, v in ipairs(x) do
                xx[i]={}
                xx[i].address=v.address+0x38
                xx[i].flags=32
                xxx[i]={}
                xxx[i].address=v.address+0x30
                xxx[i].flags=32
            end
        xx=gg.getValues(xx) 
        xxx=gg.getValues(xxx) 
        xxxx={}  j=0
            for i, v in ipairs(xx) do 
                if v.value==xxx[i].value and #(tostring(v.value))>11 then
                    j=j+1
                    xxxx[j]=v.value
                end
            end 
            if j==0 then 
                gl=gg.getLine() 
                gg.alert("×× ERROR "..gl.." ××\nNo Pointer Results From Class Name","OK","MENU","<{OFFSET TESTER}>") 
                menu() 
                return
            end 
            x=nil xx=nil 
            gg.setRanges(xACO) 
            i = nil i = 1
            while i <= j do
                ::SEARCHJ:: 
                x=nil xx=nil
                    if i > j then break end 
                clear() wait() 
                x=tonumber(xxxx[i]) t=32 search()
                    if gg.getResultsCount() == 0 then i = i +1 goto SEARCHJ end 
                xx=gg.getResults(gg.getResultsCount())
                    for w=1,#(xx) do
                        for asdf=1,#(xxx) do
                            if xx[w].address>xxx[asdf].address+100 or xx[w].address<xxx[asdf].address-100 then 
                                 xx[w].name="<{OFFSET TESTER}>"
                            else
                                 xx[w].name="DELETE"
                            end
                        end 
                    end
                gg.addListItems(xx)  
                clear() 
                i = i +1
            end 
            i =nil 
        else -- if x64 end    start if x32 
        
            x=gg.getResults(gg.getResultsCount())
            clear() 
            xxx=nil xxx={}
                for i, v in ipairs(x) do
                    xxx[i]={}
                    xxx[i].address=v.address-8 
                    xxx[i].flags=4
                end
            gg.loadResults(xxx) 
            xxx=nil xxx=gg.getResults(gg.getResultsCount(),nil,nil,nil,nil,nil,nil,nil,gg.POINTER_WRITABLE) 
                if #(xxx)==0 then 
                    gl=gg.getLine()
                    gg.alert("×× ERROR "..gl.." ××\nNo Pointer Results From Class Name","OK","MENU","<{OFFSET TESTER}>") 
                    menu() 
                    return
                end 
            clear() gg.setRanges(xACO)
            gg.loadResults(xxx) 
            gg.getResults(gg.getResultsCount()) 
            gg.searchPointer(0) 
                if gg.getResultsCount()==0 then
                    gl=gg.getLine()
                    gg.alert("×× ERROR "..gl.." ××\nNo Pointer Results From Class Name","OK","MENU","<{OFFSET TESTER}>") 
                    menu() 
                    return
                end 
            xx=gg.getResults(gg.getResultsCount()) 
                for i, v in ipairs(xx) do
                    for asdf=1,#(xxx) do
                        if v.address>xxx[asdf].address+100 or v.address<xxx[asdf].address-100 then 
                            v.name="<{OFFSET TESTER}>"
                        else
                            v.name="DELETE"
                        end
                    end 
                end
            gg.addListItems(xx) 
            clear() 
        
        end -- if x32 
 
gg.setVisible(false) 
xxzx=nil 
xload={} remove={} xxx=1
x=gg.getListItems()
    if is64 then xcl=32 else xcl=4 end 
    
    for i, v in ipairs(x) do
        if x[i].name=="<{OFFSET TESTER}>" then 
        xload[xxx]={}
        xload[xxx].address=x[i].address+EOS
        xload[xxx].flags=xcl --tz 
        xxx=xxx+1 
        end
    end 
    xxx=1 
    for i, v in ipairs(x) do
        if x[i].name=="<{OFFSET TESTER}>" or x[i].name=="DELETE" then 
        remove[xxx]={}
        remove[xxx]=x[i] 
        xxx=xxx+1
        end
    end 
xload=gg.getValues(xload) 
gg.loadResults(xload) 
gg.toast("Please Wait...") 
								
    offerror=0 
    if gg.getResultsCount()==0 then 
        for i, v in ipairs(xload) do 
        xload[i].address=xload[i].address
        xload[i].flags=1
        end
    gg.loadResults(xload) 
    offerror=1
    gg.alert("## NOTICE ##\n\n  ×  Value Type '"..EVT.."' is Not Valid at Offset '"..tostring(EOS).."'\n\n  √  Value Type 'Byte' Has Been Loaded Instead\n##  ALL RESULTS SHOWING REGARDLESS OF OPTION TO REMOVE OR NOT","OK","<{OFFSET TESTER}>")
    end 

gg.removeListItems(remove) 

if EXCLUDE==0 and offerror==0 then
    for i, v in ipairs(xload) do
        v.address=v.address
        v.flags=tz
    end
    gg.loadResults(xload) 
end -- if EXCLUDE  0
if EXCLUDE==1 and offerror==0 then 
    xxclude=nil 
    xxclude=gg.getResults(gg.getResultsCount(),nil, nil, nil, nil, nil, nil, nil,gg.POINTER_NO) 
    gg.clearResults()
    for i, v in ipairs(xxclude) do
        v.address=v.address
        v.flags=tz
    end
    gg.loadResults(xxclude) 
end -- if EXCLUDE 1

gg.toast("SUCCESS") 
gg.setVisible(true) 

end -- search 

--███████████████████████

function refinenot()
gg.refineNumber(xshit,t,false,gg.SIGN_NOT_EQUAL) 
end 

--███████████████████████

function morescripts()
zzms=gg.multiChoice({
	"Value to Arm Converter",
	"Get Registration Offsets",
	"Online Mega Games Script",
	"XOR Encrypt/Decrypt/GetKey",
	"<-- MAIN MENU"},
	{[1]=true, [2]=true, [3]=true, [4]=true, [5]=true},
	"INSTALLED MODULE") 

    if zzms==nil then menu() return end 

	if zzms[1] then 
	    gg.alert("Value to Arm Converter\n\nEnter any value of any type and it will instantly convert to valid arm hex.\n√ Online for easy updates\n√ Run in any process\n√ Any Bit\n√ Any Value Type\n√ Copy Style Options","OK",nil,xTAGx) 
	end
	
	if zzms[2] then
	    gg.alert("Get Registration Offsets\n\nFor Unity Games, simple script will automatically get the Code/Meta Registration Offsets that you can copy to clipboard","OK",nil, xTAGx) 
	end
	
	if zzms[3] then
	    gg.alert("Online Mega Games Script\n\n√ One Script that has MANY scripts for games.\n√ More games added frequently\n√ Open source,  never encrypted\n√ Options to download individual game scripts.","OK",nil,xTAGx) 
	end
	
	if zzms[4] then
	    gg.alert("XOR SCRIPT\n√ Encrypt Values with Xor Key\n√ Decrypt Xor Values with key\n√ Get the Xor key with value and Xor value.","OK",nil, xTAGx) 
	end 

    if zzms[5] then menu() return end

end 
	
--███████████████████████
--███████████████████████
while true do
    if xCLASS==0 then 
        if gg.isVisible() or apex==0 then
        gg.setVisible(false) 
        menu()
        end
    end 
    
    if xCLASS==1 then
	    while true do 
	        if xCLASS==0 then break end 
	        if gg.isClickedUiButton() then
	        menu2()
	        end 
	    end
	end 
	
end 
        
end


function buildScript()
    local menuMode = gg.choice({
        "🟢 Buat script dengan gg.choice (pilihan satu fitur)",
        "🟡 Buat script dengan gg.multiChoice (pilihan banyak fitur)"
    }, nil, "Pilih tipe menu yang Anda inginkan:")

    if menuMode == nil then
        gg.alert("❌ Anda tidak memilih menu. Script dibatalkan.")
        return
    end

    local useMultiChoice = (menuMode == 2)
    gg.toast("✔ Mode menu yang dipilih: " .. (useMultiChoice and "multiChoice" or "choice"))

    local jumlahInput = gg.prompt({"Masukkan jumlah function yang ingin Anda buat:"}, nil, {"number"})
    if not jumlahInput or jumlahInput[1] == nil then
        gg.alert("❌ Input dibatalkan.")
        return
    end

    local jumlahFunction = tonumber(jumlahInput[1])
    if not jumlahFunction or jumlahFunction <= 0 then
        gg.alert("❌ Jumlah function tidak valid.")
        return
    end

    local namaFunctions = {}
    for i = 1, jumlahFunction do
        local inputt1 = gg.prompt({"Masukkan nama untuk function ke-" .. i .. ":"}, nil, {"text"})
        if not inputt1 or inputt1[1] == "" then
            gg.alert("❌ Nama function tidak boleh kosong.")
            return
        end
        namaFunctions[i] = inputt1[1]
    end

    local functionData = {}
    for i = 1, jumlahFunction do
        local namaFunc = namaFunctions[i]
        gg.alert("📌 Konfigurasi function: " .. namaFunc)

        local tipePilihan = gg.choice({
            "Dword", "Float", "Double", "Qword", "Word", "Byte"
        }, nil, "📦 Pilih type untuk pencarian:")
        if not tipePilihan then return end

        local typeMap = {
            [1] = gg.TYPE_DWORD,
            [2] = gg.TYPE_FLOAT,
            [3] = gg.TYPE_DOUBLE,
            [4] = gg.TYPE_QWORD,
            [5] = gg.TYPE_WORD,
            [6] = gg.TYPE_BYTE
        }

        local tipeType = typeMap[tipePilihan]
        local tipeNama = ({ "Dword", "Float", "Double", "Qword", "Word", "Byte" })[tipePilihan]

        local cariValue = gg.prompt({ "🔍 Value yang ingin dicari (" .. tipeNama .. "):" }, nil, { "text" })
        if not cariValue or cariValue[1] == "" then return end

        local refineValue = gg.prompt({ "🔬 Value untuk refine (kosongkan jika tidak ingin refine):" }, nil, { "text" })
        if refineValue and refineValue[1] == "" then refineValue[1] = nil end

        local editPrompt = gg.prompt({
            "✏️ Nilai edit yang akan diterapkan:",
            "🧊 Freeze nilai ini? (centang)"
        }, nil, { "text", "checkbox" })
        if not editPrompt then return end

        local inginOffset = gg.choice({
            "✅ Ya, tambahkan offset",
            "❌ Tidak, lanjut"
        }, nil, "➕ Tambahkan offset?")

        local offsets = {}
        if inginOffset == 1 then
            local jmlOffsetPrompt = gg.prompt({"Jumlah offset yang ingin diedit:"}, nil, {"number"})
            local jmlOffset = tonumber(jmlOffsetPrompt[1]) or 0
            for j = 1, jmlOffset do
                local inputOffset = gg.prompt({
                    "Offset ke-" .. j,
                    "Type (Dword, Float, dll)",
                    "Nilai edit offset",
                    "Freeze? true/false"
                }, nil, {"text", "text", "text", "text"})
                if inputOffset then
                    table.insert(offsets, {
                        offset = inputOffset[1],
                        tipe = inputOffset[2],
                        value = inputOffset[3],
                        freeze = inputOffset[4] == "true"
                    })
                end
            end
        end

        functionData[i] = {
            nama = namaFunc,
            cari = cariValue[1],
            refine = refineValue and refineValue[1] or nil,
            edit = editPrompt[1],
            freezeMain = editPrompt[2],
            offsets = offsets,
            tipe = tipeType
        }

        gg.toast("✅ Function " .. namaFunc .. " selesai.")
    end

    -- Generate script
    local hasilScript = {}
    table.insert(hasilScript, "-- 📜 Script hasil dari Script Builder GG")
    table.insert(hasilScript, "gg.alert('📢 Pilih fitur dari menu.')")

    for i, func in ipairs(functionData) do
        table.insert(hasilScript, "")
        table.insert(hasilScript, string.format("function f%d()", i))
        table.insert(hasilScript, string.format("  -- 🎯 Function: %s", func.nama:gsub('"', '\\"')))
        table.insert(hasilScript, string.format("  gg.searchNumber('%s', %s)", func.cari, func.tipe))
        if func.refine then
            table.insert(hasilScript, string.format("  gg.refineNumber('%s', %s)", func.refine, func.tipe))
        end
        table.insert(hasilScript, "  local hasil = gg.getResults(100)")
        table.insert(hasilScript, string.format("  for i = 1, #hasil do"))
        table.insert(hasilScript, string.format("    hasil[i].value = '%s'", func.edit))
        if func.freezeMain then
            table.insert(hasilScript, "    hasil[i].freeze = true")
        end
        table.insert(hasilScript, "  end")
        table.insert(hasilScript, "  gg.setValues(hasil)")
        if func.freezeMain then
            table.insert(hasilScript, "  gg.addListItems(hasil)")
        end

        if #func.offsets > 0 then
            table.insert(hasilScript, "  local base = gg.getResults(100)")
            table.insert(hasilScript, "  local patch = {}")
            table.insert(hasilScript, "  for _, b in ipairs(base) do")
            for _, off in ipairs(func.offsets) do
                table.insert(hasilScript, string.format(
                    "    table.insert(patch, {address = b.address + 0x%s, flags = gg.TYPE_%s, value = '%s', freeze = %s})",
                    off.offset:upper():gsub("^0X", ""),
                    off.tipe:upper(),
                    off.value,
                    tostring(off.freeze)
                ))
            end
            table.insert(hasilScript, "  end")
            table.insert(hasilScript, "  gg.setValues(patch)")
            table.insert(hasilScript, "  for _, item in ipairs(patch) do if item.freeze then gg.addListItems({item}) end end")
        end

        table.insert(hasilScript, "end")
    end

    -- Menu
    table.insert(hasilScript, "")
    table.insert(hasilScript, "function mainMenu()")
    local menuItems = {}
    for i, func in ipairs(functionData) do
        table.insert(menuItems, string.format("'%s'", func.nama:gsub("'", "\\'")))
    end

    if useMultiChoice then
        table.insert(hasilScript, "  local ch = gg.multiChoice({" .. table.concat(menuItems, ", ") .. "}, nil, 'Pilih fitur:')")
        table.insert(hasilScript, "  if ch == nil then  end")
        for i = 1, #functionData do
            table.insert(hasilScript, string.format("  if ch[%d] then f%d() end", i, i))
        end
    else
        table.insert(hasilScript, "  local ch = gg.choice({" .. table.concat(menuItems, ", ") .. "}, nil, 'Pilih fitur:')")
        table.insert(hasilScript, "  if ch == nil then end")
        table.insert(hasilScript, "  if ch then _G['f' .. ch]() end")
    end
    table.insert(hasilScript, "end")

    table.insert(hasilScript, "mainMenu()")

    -- Simpan script
    local final = table.concat(hasilScript, "\n")
    gg.copyText(final)

    local folderOptions = {
        "📂 /sdcard/",
        "📂 /sdcard/Download/",
        "📂 /sdcard/GameGuardian/",
        "📂 /sdcard/GameGuardian/Scripts/",
        "📝 Custom folder"
    }

    local pilihFolder = gg.choice(folderOptions, nil, "📁 Pilih folder simpan:")
    local folderPath = ""
    if pilihFolder == nil then return end

    if pilihFolder == 1 then folderPath = "/sdcard/"
    elseif pilihFolder == 2 then folderPath = "/sdcard/Download/"
    elseif pilihFolder == 3 then folderPath = "/sdcard/GameGuardian/"
    elseif pilihFolder == 4 then folderPath = "/sdcard/GameGuardian/Scripts/"
    elseif pilihFolder == 5 then
        local inputManual = gg.prompt({"Masukkan path folder (akhiri dengan /):"}, nil, {"text"})
        if not inputManual or inputManual[1] == "" then return end
        folderPath = inputManual[1]
    end

    local namaFileInput = gg.prompt({ "📝 Nama file script (tanpa .lua):" }, nil, { "text" })
    if not namaFileInput or namaFileInput[1] == "" then return end

    local fullPath = folderPath .. namaFileInput[1] .. ".lua"
    local file = io.open(fullPath, "w")
    if not file then
        gg.alert("❌ Gagal menyimpan file.")
        return
    end

    file:write(final)
    file:close()
    gg.alert("✅ Script berhasil disimpan:\n" .. fullPath)
end

function getLocationOnline()
    local result = gg.makeRequest("http://ip-api.com/json/")
    if result and result.code == 200 then
        local data = result.content
        return {
            ip = data:match('"query"%s*:%s*"([^"]+)"') or "-",
            city = data:match('"city"%s*:%s*"([^"]+)"') or "Unknown",
            region = data:match('"regionName"%s*:%s*"([^"]+)"') or "-",
            country = data:match('"country"%s*:%s*"([^"]+)"') or "-"
        }
    end
    return { ip = "-", city = "-", region = "-", country = "-" }
end

lokasi_user = getLocationOnline()

function getTime()
    local now = os.date("*t")
    return string.format("🕒 %02d:%02d:%02d", now.hour, now.min, now.sec)
end

function getDate()
    return os.date("📅 %A, %d %B %Y")
end

function getDeviceInfo()
    if gg.getDeviceModel and gg.getDeviceBrand and gg.getAndroidVersion then
        return string.format("📱 Info Device:\nModel: %s\nBrand: %s\nAndroid: %s",
            gg.getDeviceModel(), gg.getDeviceBrand(), gg.getAndroidVersion())
    else
        return "⚠️ Info device tidak tersedia~"
    end
end

function getBatteryInfo()
    if gg.getBattery then
        local percent = gg.getBattery()
        return percent and ("🔋 Baterai sekarang: " .. percent .. "%") or "⚠️ Tidak bisa cek baterai~"
    else
        return "⚠️ Fitur baterai tidak tersedia~"
    end
end

function detectLanguage(text)
    local indo_keywords = {"siapa", "jam", "lokasi", "baterai", "fitur", "tanggal", "terima kasih", "halo", "assalamualaikum"}
    for _, w in ipairs(indo_keywords) do
        if text:lower():match(w) then return "id" end
    end
    return "en"
end

function listcmdc()
gg.alert(" ❦ ════ •⊰❂ - ❂⊱• ════ ❦\n• Encrypt Script 🔏 [ /encryptsc ]\n• Offset Tester 🧭 [ /offset1 ]\n• Builder Script 📜 [ /buildersc ]\n• Save Value 💾 [ /savevalue ]\n• Scanner Pointer [1] 🔍[ /scanepointer1() ]\n• Scanner Pointer [2] 🔎 [ /scanepointer2 ]\n❦ ════ •⊰❂ - ❂⊱• ════ ❦")
gg.setVisible(true)
end

function handleCommand(input)
    local lc = input:lower()
    if lc:match("ram") then
        collectgarbage()
        return "🧠 RAM dibersihkan~ Yatta~!"
    elseif lc:match("kalkulator") then
        local a = gg.prompt({"🧮 Masukkan angka pertama~"}, nil, {"number"})
        local b = gg.prompt({"🧮 Masukkan angka kedua~"}, nil, {"number"})
        local sum = tonumber(a[1]) + tonumber(b[1])
        return "💖 Hasilnya adalah: " .. sum
    elseif lc:match("konversi suhu") then
        local temp = gg.prompt({"🌡️ Masukkan suhu (°C):"}, nil, {"number"})
        local f = tonumber(temp[1]) * 9 / 5 + 32
        return string.format("✨ %.2f°C = %.2f°F", temp[1], f)
    elseif lc:match("aktifkan speedhack") then
        gg.setSpeed(2.0)
        return "⏩ Speedhack diaktifkan, nyoom~!"
    elseif lc:match("reset speed") then
        gg.setSpeed(1.0)
        return "🐢 Kecepatan kembali normal~"
        elseif lc:match("^%/buildersc$") then
    return buildScript()
    elseif lc:match("^%/offset1$") then
    return run_offset_tester()
    elseif lc:match("^%/encryptsc$") then
    return encryptsc()
    elseif lc:match("^%/cmdlist$") then
    return listcmdc()
    elseif lc:match("^%/classname$") then
    return classname()
    elseif lc:match("^%/savevalue$") then
    return Savevalue1()
    elseif lc:match("^%/scanepointer1$") then
    return scanepointer1()
    elseif lc:match("^%/scanepointer2$") then
    return scanepointer2()
    end
end

function autoReply(input)
    local lang = detectLanguage(input)
    local lc = input:lower()

    -- Perintah langsung
    local direct = handleCommand(lc)
    if direct then return direct end

    -- Bahasa Indonesia
    if lang == "id" then
        if lc:match("assalam") then return "Wa'alaikumussalam warahmatullahi wabarakatuh~ 💞"
        elseif lc:match("halo") or lc:match("hai") then return "Haiii~ Ada yang bisa Vellbotz bantuin? (≧◡≦)♡"
        elseif lc:match("jam") or lc:match("waktu") then return "⏰ Sekarang pukul: " .. getTime()
        elseif lc:match("tanggal") then return getDate()
        elseif lc:match("lokasi") or lc:match("ip") then
            return string.format("🌍 Lokasimu: %s, %s (%s)\n📡 IP: %s",
                lokasi_user.city, lokasi_user.region, lokasi_user.country, lokasi_user.ip)
        elseif lc:match("device") then return getDeviceInfo()
        elseif lc:match("baterai") then return getBatteryInfo()
        elseif lc:match("fitur") then return [[
💫 Fitur Vellbotz~:
• Anti-Tamper 💣
• Device Lock 🔐
• Expired Timer ⏳
• Ban Device 🔒
• AI Assistant 🧠
• Lokasi & IP 🌍
• Speedhack ⚡
• Kalkulator 🧮
• Konversi Suhu 🌡️
• RAM Cleaner 🧼
• Builder Script 📜
• Offset Tester 🧭
• Encrypt Script 🔏
• Save Value 💾
• Scanner Pointer [1] 🔍
• Scanner Pointer [2] 🔎
        ]]
        elseif lc:match("keluar") then
            return "👋 Bye bye~ Vellbotz pamit dulu yaa~", true
        end
    else
        -- English Mode
        if lc:match("hello") or lc:match("hi") then return "Hiyaa~ I'm Vellbotz! Need something cute and smart? 💕"
        elseif lc:match("time") then return "⏰ Time now: " .. getTime()
        elseif lc:match("date") then return getDate()
        elseif lc:match("location") or lc:match("ip") then
            return string.format("🌎 You're in %s, %s (%s)\n📡 IP: %s",
                lokasi_user.city, lokasi_user.region, lokasi_user.country, lokasi_user.ip)
        elseif lc:match("device") then return getDeviceInfo()
        elseif lc:match("battery") then return getBatteryInfo()
        elseif lc:match("features") then return [[
✨ Vellbotz Features~:
• Anti-Tamper 💣
• Device Lock 🔐
• Expired Timer ⏳
• Device Ban 🔒
• AI Assistant 🧠
• IP & Location 🌐
• Speedhack ⚡
• Calculator 🧮
• Temp Converter 🌡️
• RAM Cleaner 🧼
• Builder Script 📜
• Offset Tester 🧭
• Encrypt Script 🔏
• Save Value 💾
• Scanner Pointer [1] 🔍
• Scanner Pointer [2] 🔎
        ]]
        elseif lc:match("exit") then
            return "Bye bye~ See you soon, master~ (｡♥‿♥｡)", true
        end
    end

    -- Fallback ke AI online
    local json = '{"prompt":"' .. input:gsub('"', '\\"') .. '"}'
    local headers = {["Content-Type"] = "application/json"}
    local result = gg.makeRequest(url, headers, json)
    if result.content and result.content:find("response") then
        local response = result.content:match('"response"%s*:%s*"(.-)"')
        if response then
            response = response:gsub("\\n", "\n"):gsub('\\"', '"')
            return "💬 Vellbotz:\n\n" .. response
        end
    end

    return "Uwaah~ Vellbotz-nya lagi lemot, coba lagi nanti yaa~ (>_<)"
end

function startVellbotz()
    while true do
        local input = gg.prompt({"🎀 Vellbotz di sini~ Mau tanya apa? (Ketik 'keluar' buat tutup~)"}, nil, {"text"})
        if not input then
            gg.toast("😶‍🌫️ Vellbotz sembunyi dulu~ klik ikon GG buat lanjut yaa~")
            gg.setVisible(false)
            return
        end
        local reply, exitFlag = autoReply(input[1])
        gg.alert(reply, "💗 Oke~")
        if exitFlag then return end
    end
end

-- Mulai sesi
startVellbotz()


-- ⛏️ <{OFFSET TESTER}>Injected Feature
