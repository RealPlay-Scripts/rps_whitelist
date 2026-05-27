--[[
    ╔══════════════════════════════════════════════════════╗
    ║          DISCORD WHITELIST CONFIG                    ║
    ╚══════════════════════════════════════════════════════╝
    
    Fill in your API details below.
    The API key needs at minimum the "read" scope.
--]]

Config = {}

-- ──────────────────────────────────────────────
-- Your whitelist website base URL (no trailing slash)
-- Example: "https://yoursite.com"
-- ──────────────────────────────────────────────
Config.ApiBaseUrl = "https://web.goldenshoresrp.com"

-- ──────────────────────────────────────────────
-- Your API key (X-API-Key header)
-- Generate this from your site's admin panel
-- ──────────────────────────────────────────────
Config.ApiKey = " cfrp_emW2mNHUrUlltBQTkSdaHAyINQye0eoVfpM7fTARPft_hCLa07OSYTp2LLng7iuV"

-- ──────────────────────────────────────────────
-- The URL you want to send unlinked players to
-- This should be your Discord OAuth signup page
-- ──────────────────────────────────────────────
Config.SignupUrl = "https://discord.com/oauth2/authorize?client_id=1492205889300598938&redirect_uri=https%3A%2F%2Fweb.goldenshoresrp.com%2Fauth%2Fdiscord%2Fcallback&response_type=code&scope=identify+email+guilds.join&state=yqUZ4caGiggyNJFyQTyCmA&prompt=consent"

-- ──────────────────────────────────────────────
-- Kick message shown to players who aren't linked
-- {url} is replaced with Config.SignupUrl
-- ──────────────────────────────────────────────
Config.KickMessage = "You are not whitelisted on this server!\n\nTo join, please visit our Discord: https://discord.gg/y6Ttqr7jrs and apply.\n\nYou must link your Discord account on our website:\n%s\n\nOnce linked, restart FiveM and try again."
-- ──────────────────────────────────────────────
-- Kick message shown if the API is unreachable
-- ──────────────────────────────────────────────
Config.ErrorMessage = "Could not verify your whitelist status. Please try again in a moment or contact staff."

-- ──────────────────────────────────────────────
-- Steam hex identifiers to always allow through
-- (server owners / backup access)
-- Example: { "steam:110000112345678" }
-- ──────────────────────────────────────────────
Config.Bypass = {}

-- ──────────────────────────────────────────────
-- Print debug info to the server console?
-- Disable in production.
-- ──────────────────────────────────────────────
Config.Debug = true
