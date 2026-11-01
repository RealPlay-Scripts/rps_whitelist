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
-- Set as server convars in server.cfg, never commit real values here:
--   set rps_whitelist_api_url "https://yoursite.example"
--   set rps_whitelist_api_key "your-api-key"   (read scope)
-- ──────────────────────────────────────────────
Config.ApiBaseUrl = GetConvar('rps_whitelist_api_url', 'https://yoursite.example')

-- ──────────────────────────────────────────────
-- Your API key (X-API-Key header)
-- Generate this from your site's admin panel
-- ──────────────────────────────────────────────
Config.ApiKey = GetConvar('rps_whitelist_api_key', '')

-- ──────────────────────────────────────────────
-- The URL you want to send unlinked players to.
-- Point this at your site's registration/Discord-connect page — once
-- Discord OAuth is configured there, swap to a full OAuth deep-link if
-- you prefer sending players straight into the consent screen.
-- ──────────────────────────────────────────────
Config.SignupUrl = GetConvar('rps_whitelist_signup_url', 'https://yoursite.example/auth/register')

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
Config.Debug = false
