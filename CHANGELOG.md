# Changelog

All notable changes to this repository are documented in this file.

## [Unreleased]

### Added
- Initial complete design foundation document for **Storm Chasers: World Break** including gameplay, systems, monetization, architecture, MVP plan, and art direction.
- Initial Roblox Luau starter modules for weather, creatures, monetization hooks, client weather event handling, and profile data model.

### Changed
- Hardened weather authority logic with input validation, server timestamp payloads, and state accessors.
- Improved weather scheduler resilience (invalid pool handling and deterministic weighted fallback).
- Refined lightning hazard logic to use deterministic RNG and eligibility checks.
- Updated wet-surface system to preserve original per-part material/reflectance and restore safely.
- Hardened Lightning Serpent spawning with runtime folder initialization, template guards, and despawn cleanup API.
- Improved Storm Seed purchase flow with request validation/cooldowns, safe receipt handling for product IDs, and explicit `NotProcessedYet` behavior for unresolved receipts.

### Security
- Added stronger server-side validation for monetization-triggered weather events.
- Avoided unsafe assumptions in replicated client requests by validating payload types and allowlisted weather IDs.

## [2026-03-11]

### Added
- Repository README and notebook placeholders from initial project setup.
