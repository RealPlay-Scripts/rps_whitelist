--[[
    ╔══════════════════════════════════════════════════════╗
    ║          DISCORD WHITELIST - server.lua              ║
    ║                                                      ║
    ║  Checks joining players against your whitelist site. ║
    ║  Also respects the whitelist on/off toggle set from  ║
    ║  the admin panel at https://web.goldenshoresrp.com/admin/   ║
    ║  whitelist                                           ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ──────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────

local function debugLog(msg)
    if Config.Debug then
        print(("[Whitelist] %s"):format(msg))
    end
end

--- Returns all identifiers for a player as a table keyed by type.
local function getIdentifiers(source)
    local ids = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if id then
            local prefix = id:match("^([^:]+):")
            if prefix then
                ids[prefix] = id
            end
        end
    end
    return ids
end

--- Strips the "discord:" prefix from a Discord identifier.
local function parseDiscordId(discordIdent)
    if not discordIdent then return nil end
    return discordIdent:gsub("discord:", "")
end

--- Formats the kick message, inserting the signup URL.
local function buildKickMessage()
    return Config.KickMessage:format(Config.SignupUrl)
end

-- ──────────────────────────────────────────────────────────────
-- Bypass check
-- ──────────────────────────────────────────────────────────────

local bypassSet = {}
for _, v in ipairs(Config.Bypass) do
    bypassSet[v:lower()] = true
end

local function isBypassed(identifiers)
    for _, id in pairs(identifiers) do
        if bypassSet[id:lower()] then
            return true
        end
    end
    return false
end

-- ──────────────────────────────────────────────────────────────
-- Whitelist status cache
-- Fetched once on start, then refreshed every 60 seconds so
-- admin panel changes take effect quickly without adding latency
-- to every single player join.
-- ──────────────────────────────────────────────────────────────

local whitelistEnabled = true          -- default: ON
local lastStatusCheck  = 0
local STATUS_CACHE_TTL = 60            -- seconds

local function refreshWhitelistStatus(cb)
    local url     = ("%s/api/whitelist/status"):format(Config.ApiBaseUrl)
    local headers = {
        ["X-API-Key"]    = Config.ApiKey,
        ["Content-Type"] = "application/json",
    }

    PerformHttpRequest(url, function(status, body, _headers)
        if status == 200 then
            local ok, data = pcall(json.decode, body)
            if ok and data and data.enabled ~= nil then
                local prev = whitelistEnabled
                whitelistEnabled = data.enabled
                if prev ~= whitelistEnabled then
                    print(("^3[Whitelist] Status changed → %s^7"):format(
                        whitelistEnabled and "ENABLED" or "DISABLED"))
                end
            end
        else
            debugLog(("Status check returned HTTP %d — keeping cached value"):format(status))
        end
        lastStatusCheck = GetGameTimer() / 1000
        if cb then cb() end
    end, "GET", "", headers)
end

-- Background refresh loop
CreateThread(function()
    while true do
        Wait(STATUS_CACHE_TTL * 1000)
        refreshWhitelistStatus(nil)
    end
end)

-- ──────────────────────────────────────────────────────────────
-- API call: GET /api/whitelist/check?discord_id=:discord_id
--
-- Performs two checks server-side in a single request:
--   1. Player has a linked website account (discord_verified)
--   2. Player has the required Discord role in the guild
--        (role ID 1324156330096721980)
--
-- Response JSON:
--   { "allowed": true }
--   { "allowed": false, "reason": "not_registered"|"missing_role"|..., "message": "..." }
-- ──────────────────────────────────────────────────────────────

local function checkWhitelist(discordId, cb)
    local url     = ("%s/api/whitelist/check?discord_id=%s"):format(Config.ApiBaseUrl, discordId)
    local headers = {
        ["X-API-Key"]    = Config.ApiKey,
        ["Content-Type"] = "application/json",
    }

    debugLog(("Checking Discord ID %s via /api/whitelist/check…"):format(discordId))

    PerformHttpRequest(url, function(statusCode, responseBody, _responseHeaders)
        debugLog(("API response: HTTP %d"):format(statusCode))

        if statusCode == 200 then
            local ok, data = pcall(json.decode, responseBody)
            if ok and data then
                if data.allowed then
                    cb("allowed", nil)
                else
                    debugLog(("Denied — reason: %s"):format(data.reason or "unknown"))
                    cb("denied", data.message or buildKickMessage())
                end
            else
                debugLog("Failed to parse API JSON response.")
                cb("error", nil)
            end
        elseif statusCode == 401 or statusCode == 403 then
            debugLog("API key rejected (401/403). Check Config.ApiKey!")
            cb("error", nil)
        else
            debugLog(("Unexpected status code: %d — body: %s"):format(statusCode, responseBody or ""))
            cb("error", nil)
        end
    end, "GET", "", headers)
end

-- ──────────────────────────────────────────────────────────────
-- Deferred connection handler
-- ──────────────────────────────────────────────────────────────

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local source      = source
    local identifiers = getIdentifiers(source)

    deferrals.defer()
    Wait(0)

    -- ── 1. Bypass list ────────────────────────────────────────
    if isBypassed(identifiers) then
        debugLog(("Player %s (%s) bypassed whitelist."):format(playerName, source))
        deferrals.done()
        return
    end

    -- ── 2. Check whitelist status (use cache, refresh if stale) ─
    local now = GetGameTimer() / 1000
    if (now - lastStatusCheck) > STATUS_CACHE_TTL then
        deferrals.update("Checking server status, please wait…")
        local done = false
        refreshWhitelistStatus(function() done = true end)
        local waited = 0
        while not done and waited < 5000 do
            Wait(100)
            waited = waited + 100
        end
    end

    -- ── 3. Whitelist OFF → let everyone in ────────────────────
    if not whitelistEnabled then
        debugLog(("Whitelist is DISABLED — allowing %s without check"):format(playerName))
        deferrals.done()
        return
    end

    -- ── 4. Whitelist ON → Discord required ────────────────────
    local discordId = parseDiscordId(identifiers["discord"])

    if not discordId then
        debugLog(("Player %s has no Discord identifier."):format(playerName))
        deferrals.done(
            "No Discord identifier found.\n\n" ..
            "Please make sure Discord is running and linked in your FiveM settings, then try again.\n\n" ..
            "If you haven't registered on our site yet, visit:\n" .. Config.SignupUrl
        )
        return
    end

    debugLog(("Player %s connecting — Discord ID: %s"):format(playerName, discordId))
    deferrals.update("Checking your whitelist status, please wait…")

    -- ── 5. Check website connection + required Discord role ───
    --
    --  /api/whitelist/check verifies both in one request:
    --    • Player has connected their Discord to the website
    --    • Player holds role ID 1324156330096721980 in the guild
    --
    checkWhitelist(discordId, function(result, kickMsg)

        if result == "allowed" then
            debugLog(("Player %s (Discord %s) passed all checks. Allowing."):format(playerName, discordId))
            deferrals.done()

        elseif result == "denied" then
            debugLog(("Player %s (Discord %s) denied by whitelist check."):format(playerName, discordId))
            deferrals.done(kickMsg)

        else
            -- API error — fail closed
            debugLog(("API error while checking player %s."):format(playerName))
            deferrals.done(Config.ErrorMessage)
        end
    end)
end)

-- ──────────────────────────────────────────────────────────────
-- Startup confirmation
-- ──────────────────────────────────────────────────────────────

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    print("^2[Whitelist] Resource started. Checking against: " .. Config.ApiBaseUrl .. "^7")
    if Config.Debug then
        print("^3[Whitelist] Debug mode is ON — disable in production (Config.Debug = false).^7")
    end

    -- Initial status fetch on start
    refreshWhitelistStatus(function()
        print(("^2[Whitelist] Status: %s^7"):format(whitelistEnabled and "ENABLED" or "DISABLED"))
    end)
end)