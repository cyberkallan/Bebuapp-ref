# Appearance: themes and UI controls

The bebu app ships a dark and a light theme. Which one a user sees is decided
by three inputs, in this order:

1. **Admin config** (`setting.appearance`, edited in *Admin → Settings →
   Appearance*). Sets the default theme and whether users may override it,
   plus the brand accent, corner style, motion level and individual effects.
2. **User choice** (System / Dark / Light), stored on the phone
   (`GetStorage` key `themeMode`). Only honoured while
   `allowUserThemeChoice` is on.
3. **Platform brightness**, when the effective mode is `system`.

## Admin fields

| Field                  | Values                                           | Effect in the app                                                             |
| ---------------------- | ------------------------------------------------ | ----------------------------------------------------------------------------- |
| `defaultTheme`         | `dark` (default), `light`, `system`              | Theme for users who never picked one, and for everyone when choice is locked. |
| `allowUserThemeChoice` | bool (default `true`)                            | Shows the picker on *My profile*; when off the saved user choice is ignored.  |
| `askThemeOnOnboarding` | bool (default `true`)                            | Adds a "Pick your look" step to first-run onboarding (needs choice enabled).  |
| `accent`               | `pink`, `violet`, `coral`, `ocean`, `mint`, `sunset` | Primary buttons, gradients, call button, live indicators, selection states.   |
| `ambientGlow`          | bool                                             | Violet/accent glows behind Home, Random match, Calls, Profile, onboarding.    |
| `motion`               | `full`, `reduced`                                | `reduced` makes transitions near-instant and stops looping animations.        |
| `cornerStyle`          | `rounded`, `soft`, `sharp`                       | Scales every `BebuTheme.radius*` token (1.0 / 0.72 / 0.45).                    |
| `liveRings`            | bool                                             | Ringing call buttons for online hosts.                                        |
| `coinAnimation`        | bool                                             | 3D flip / sweep on the coin balance pill.                                     |

API: `GET /api/admin/appearance` returns `{ settingId, appearance, options }`,
`PATCH /api/admin/appearance` accepts any subset of the fields above.
Values are validated against the allowed sets and written through
`updateSettingFile`, so `/api/user/setting/fetchAppSettingsData` serves the new
object immediately; the app applies it on the next launch (splash fetches
settings) and caches it locally (`appearanceConfig`) so the first frame after
that is already themed.

## App implementation

- `lib/utils/app_theme.dart` — `BebuTheme` exposes surface/text colours as
  getters backed by a `BebuPalette` (`dark` / `light`), the accent via
  `BebuAccent`, scaled radii and motion durations. `onPhoto*` are constants for
  text drawn over photos and gradients, which stay light in both themes.
- `lib/utils/appearance.dart` — `Appearance` loads the cached config and user
  choice at startup (`main()` → `Appearance.init()`), applies the server config
  (`applyServer`), stores user picks (`setUserChoice`), listens to platform
  brightness for `system`, and rebuilds the whole tree with
  `Get.forceAppUpdate()` when the effective look changes.
- `lib/custom/theme_picker.dart` — `ThemePicker`, the three-card selector used
  on *My profile* and in onboarding.
- `Utils.onChangeStatusBar` flips requested light status-bar icons to dark when
  the light theme is active, so themed screens need no changes.
- Animated widgets (`CoinPill`, `RingingCallButton`) read
  `BebuTheme.coinAnimation` / `BebuTheme.liveRings` and re-sync in
  `reassemble()`; `AuroraBackground` and Home's ambient glow honour
  `BebuTheme.ambientGlow`.

Legacy (non-redesigned) screens still use `AppColors` and stay light in both
themes.
