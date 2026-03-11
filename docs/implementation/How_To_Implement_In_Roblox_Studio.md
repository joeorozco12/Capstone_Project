# How To Implement Storm Chasers: World Break in Roblox Studio

This is the fastest path to get your current code running in Roblox Studio.

## 1) Create the place and baseline services
1. Create a new Roblox place (Baseplate is fine).
2. In **Explorer**, ensure these services are visible:
   - `ReplicatedStorage`
   - `ServerScriptService`
   - `StarterPlayer`
   - `Workspace`
3. Turn on **Team Create** if you are collaborating.

## 2) Recreate the folder layout from this repo
Inside Studio, create these folders/scripts:

- `ServerScriptService/Systems/Weather/*`
- `ServerScriptService/Systems/Creatures/*`
- `ServerScriptService/Systems/Monetization/StormSeedService`
- `ServerScriptService/Data/DiscoveryDataModel`
- `ServerScriptService/Config/WeatherPool`
- `ServerScriptService/Main.server`
- `StarterPlayer/StarterPlayerScripts/Controllers/WeatherClientController.client`

Then paste each file's source from the repo.

## 3) Add required remotes
You can create these manually under `ReplicatedStorage/Remotes`, but the new `Main.server` script auto-creates them too.

Required remotes:
- `WeatherStateChanged` (RemoteEvent)
- `StormEventBroadcast` (RemoteEvent)
- `StormSeedPurchaseRequest` (RemoteEvent)
- `CreatureEncounterEvent` (RemoteEvent)
- `JournalSyncRequest` (RemoteFunction)

## 4) Add required world tags and runtime content
1. In `Workspace`, tag any terrain proxy parts or mesh parts that should look wet during storms with:
   - **Tag**: `WeatherReactive`
2. In `ReplicatedStorage`, add a model named:
   - `LightningSerpentTemplate`
   - Give it a valid `PrimaryPart`.

## 5) Configure your first weather loop
Edit `ServerScriptService/Config/WeatherPool.lua` to tune event frequency.
- Increase `weight` for more common weather.
- Adjust `duration` (seconds) for pacing.

## 6) Configure monetization
In `StormSeedService.lua`:
1. Replace `STORM_SEED_PRODUCT_ID` with your real Developer Product ID.
2. Keep the `ALLOWED_STORMS` allowlist to avoid exploit-triggered invalid storms.
3. In Roblox Creator Dashboard, create a product matching that ID.

## 7) Run local test (Play Solo first)
1. Click **Play** in Studio.
2. Confirm output shows weather changes from `WeatherClientController.client`.
3. Confirm parts tagged `WeatherReactive` become reflective during wet weather.
4. Force weather from command bar for testing:
   ```lua
   require(game.ServerScriptService.Systems.Weather.WeatherManager)
   ```
   (or temporarily call `weatherManager:SetWeather("Thunderstorm", 120)` in `Main.server`)

## 8) Multiplayer test
1. Use **Test** → Start with 2–4 players.
2. Validate:
   - all clients receive weather events
   - lightning damage is server-authoritative
   - serpent spawn announcement is synchronized

## 9) Publish checklist before public release
1. Fill store copy from `docs/publishing/templates/store_listing_template.md`.
2. Create icon + thumbnails from `docs/publishing/templates/thumbnail_and_icon_spec.md`.
3. Run launch checks from `docs/publishing/checklists/pre_publish_checklist.md`.
4. Use `docs/publishing/ops/launch_runbook.md` for soft launch.

## 10) Recommended next engineering tasks (priority order)
1. Add `ProfileService` integration for `DiscoveryDataModel`.
2. Add robust entitlement checks for gamepasses/products.
3. Add server-side encounter validation on `CreatureEncounterEvent`.
4. Move hardcoded constants to config modules.
5. Add quality tier settings for weather VFX on mobile.

## Common pitfalls to avoid
- Do not trust any client request for rewards/weather state.
- Do not attach expensive particles directly to every replicated part.
- Do not allow purchase remotes without cooldown and allowlists.
- Do not ship without at least one multi-player test pass.
