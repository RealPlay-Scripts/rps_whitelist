# FiveM Discord Whitelist Resource

Checks joining players against your whitelist website API.  
Players **must** have their Discord linked on the site — anyone who isn't gets kicked with a redirect link to sign up.

---

## Setup

### 1. Drop the folder into your resources directory

```
resources/
└── discord-whitelist/
    ├── fxmanifest.lua
    ├── config.lua
    └── server.lua
```

### 2. Edit `config.lua`

| Setting | What to put |
|---|---|
| `Config.ApiBaseUrl` | Your site URL, e.g. `https://yoursite.com` |
| `Config.ApiKey` | An API key with at least `read` scope |
| `Config.SignupUrl` | The Discord OAuth link on your site (e.g. `https://yoursite.com/auth/discord`) |
| `Config.Bypass` | Steam hex IDs for owners / devs who skip the check |

### 3. Start the resource in `server.cfg`

```
ensure discord-whitelist
```

---

## How it works

1. Player connects → FiveM fires `playerConnecting` with a deferred connection.
2. The script reads the player's `discord:` identifier (the Discord snowflake ID).
3. It calls `GET /api/users/discord/:discord_id` on your site API using the `X-API-Key` header.
4. **HTTP 200** → user is linked → connection allowed.  
   **HTTP 404** → user not found → kicked with signup URL.  
   **Any error** → kicked with generic error message.

---

## Requirements

- FiveM server with `deferred connections` supported (all modern builds).
- Players must have **Discord open and linked in their FiveM identity** — FiveM only exposes the `discord:` identifier when Discord is running.
- Your API key must have the **`read` (scope 0)** permission.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Everyone gets kicked even when linked | Check `Config.ApiKey` is correct and has `read` scope |
| Players have no Discord identifier | Tell players to open Discord before launching FiveM |
| API error on every join | Check `Config.ApiBaseUrl` — no trailing slash |
| Want to also check approval status | In `server.lua` find the `"linked"` block and add a check on `userData.status` |
