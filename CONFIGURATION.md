# Environment and Configuration Guide

This repository now uses a documented three-environment model:

- `local`: developer workstations, emulators, and test devices.
- `staging`: pre-production validation against shared infrastructure.
- `production`: live deployment values for customer-facing or field devices.

## Required configuration templates

The following templates should be copied and populated for each environment:

- Root application env: `.env.example`
- Backend service env: `backend/.env.example`
- Android developer properties: `android-app/local.properties.example`
- Firmware template: `firmware/config/firmware.config.example`

## Minimum required variables

Every environment should define these settings before launch:

### API and connectivity

- `API_BASE_URL`: base URL for the backend API.
- `MQTT_BROKER_HOST`: broker hostname or IP when MQTT is enabled.
- `MQTT_BROKER_PORT`: broker port.
- Optional MQTT credentials when the broker requires authentication.

### Authentication and secrets

- JWT and refresh token secrets for backend auth.
- Session secret or equivalent server-side signing key.
- Device secret or provisioning token for firmware onboarding.

### Device IDs and registration flow

Use one of these approaches per environment:

- **Manual/static IDs** for local prototyping.
- **Provisioning tokens** for staging and production.
- **Prefix-based issuance** when IDs are generated centrally.

Recommended keys:

- `DEVICE_REGISTRATION_MODE`
- `DEVICE_DEFAULT_ID` or `DEVICE_ID`
- `DEVICE_ID_PREFIX`
- `DEVICE_PROVISIONING_TOKEN`

### Feature flags

Use flags to keep partially finished capabilities out of launch builds:

- `FEATURE_ENABLE_MQTT`
- `FEATURE_ENABLE_REMOTE_FEEDING`
- `FEATURE_ENABLE_TELEMETRY`
- `FEATURE_ENABLE_DEVICE_PROVISIONING`

### Logging

- `LOG_LEVEL=debug` for local development.
- `LOG_LEVEL=info` for staging.
- `LOG_LEVEL=warn` or `error` for production unless deeper diagnostics are needed.

## Suggested values by environment

| Variable | local | staging | production |
| --- | --- | --- | --- |
| `APP_ENV` | `local` | `staging` | `production` |
| `API_BASE_URL` | localhost / emulator URL | staging API hostname | production API hostname |
| `MQTT_BROKER_HOST` | local broker or LAN IP | staging broker | production broker |
| `DEVICE_REGISTRATION_MODE` | `manual` | `provisioning` | `provisioning` |
| `LOG_LEVEL` | `debug` | `info` | `warn` |

## Operational notes

- Never commit real secrets to the repository.
- Keep per-environment concrete values in ignored files such as `.env.local`.
- Prefer registration tokens over shipping fixed device IDs in mobile apps.
- If the project later adds a formal config loader, these template keys should be kept in sync with that loader.
