# Avatar Studio

Users build a 3D look instead of (or as well as) uploading a photo: an avatar
bust plus a scene, a pet, a ride, a home, something in the sky and a worn
accessory. Free items are equipped instantly; premium items are unlocked with
coins from the same wallet used for calls. The admin can switch the whole
feature off, in which case profiles fall back to a photo upload and six preset
pictures (three male, three female).

## Assets

All images come from [Microsoft Fluent Emoji](https://github.com/microsoft/fluentui-emoji)
(3D style, MIT licence). `talkin/tools/build_avatar_assets.py` sparse-checks
out only the renders listed in its catalog, trims transparent margins,
resizes (avatars 512 px, rides/homes 384 px, pets/sky 320 px, accessories
256 px), and writes WebP files plus `manifest.json` to:

| Path                                   | Purpose                                                          |
| -------------------------------------- | ---------------------------------------------------------------- |
| `talkin/backend/assets/avatar-studio/` | Served at `/avatar-studio/<key>.webp`; seeds the catalog on boot |
| `talkin/app/assets/avatar_studio/`     | Bundled in the APK (≈1.3 MB) so the stage renders with no network |

The app tries the bundled file first (`StudioImage`) and falls back to the
server URL, so items added later by the admin still render.

Catalog shipped: 38 avatars (19 male / 19 female), 10 pets, 10 rides, 6 homes,
4 sky items, 6 accessories, 7 gradient scenes. Rarity (`common`, `rare`,
`epic`, `legendary`) only drives the card glow and tag; price is a separate
`coins` field (0 = free).

## Data model

`AvatarItem` (`backend/models/avatarItem.model.js`):
`key`, `category` (`avatar | background | accessory | pet | vehicle | home | sky`),
`name`, `image`, `colors[]` (backgrounds), `coins`, `rarity`, `gender`
(`male | female | any`, avatars only), `isActive`, `sortOrder`, `unlockCount`.

`User` gains `avatar { active, avatar, background, accessory, pet, vehicle,
home, sky }` (ObjectIds) and `unlockedItems[]`. While `avatar.active` is true
the user's `profilePic` is the equipped avatar's image URL, so every existing
screen (host cards, chat, calls) shows the 3D face without changes. Uploading
a real photo sets `avatar.active = false`.

`Setting.avatarStudio { enabled, allowPhotoUpload }` controls the feature.
Coin history uses `HISTORY_TYPE.AVATAR_UNLOCK = 8`.

`util/seedAvatarStudio.js` runs at server start and on every admin catalog
fetch; it inserts manifest items that are missing by `key` and never
overwrites edits made in the admin panel.

## API

User (`/api/user/avatar`, Firebase auth):

| Method | Path      | Body                              | Notes                                                                |
| ------ | --------- | --------------------------------- | -------------------------------------------------------------------- |
| GET    | `/studio` | —                                 | settings, coins, gender, equipped slots, unlocked ids, items, presets |
| POST   | `/unlock` | `{ itemId }`                      | Atomic `coin >= price` decrement, pushes to `unlockedItems`, ledger   |
| POST   | `/equip`  | `{ active, avatar, pet, … }`      | Slot ids or `null`; ownership checked; updates `profilePic`          |
| POST   | `/preset` | `{ itemId }`                      | Free avatar as plain profile picture, `avatar.active = false`        |

Admin (`/api/admin/avatarStudio`, admin auth):

| Method | Path           | Notes                                                        |
| ------ | -------------- | ------------------------------------------------------------ |
| GET    | `/`            | settings, catalog, stats (users with a 3D look, unlocks), options |
| PATCH  | `/settings`    | `{ enabled?, allowPhotoUpload? }`                            |
| POST   | `/item`        | multipart: fields + `image`                                  |
| PATCH  | `/item?itemId` | multipart, image optional                                    |
| PATCH  | `/item/toggle?itemId` | hide / show                                           |
| DELETE | `/item?itemId` | refused while any user has it equipped                       |

## App

`lib/ui/user_flow/avatar_studio/`:

- `avatar_stage.dart` — the diorama. Layers: gradient scene + bokeh, home,
  sky item (drifting), avatar bust with breathing idle and worn accessory,
  pet (bobbing) and ride (rolling). Drag for parallax; every layer sits in a
  `RepaintBoundary` and stops animating when `BebuTheme.reducedMotion`.
- `avatar_studio_controller.dart` — `draft` (slot → item id), `tryOn`
  (locked item previewed on stage), `unlockTryOn()` and `saveLook()`.
  Nothing is written until *Save my look*; leaving with changes asks first.
- `avatar_studio_widget.dart` — header with coin pill, tabs with 3D icons,
  rarity item grid (`StudioItemCard`), docked action bar (Cancel / Unlock for
  N coins / Need N more coins → wallet / Save my look), `UnlockCelebration`
  particle burst, shimmer.
- `photo_avatar_picker.dart` — the fallback when the studio is off: camera,
  gallery and the six presets.
- `Sfx.pop()` on equip, `Sfx.unlock()` on a successful unlock, `Sfx.deny()`
  when coins are short; each pairs a haptic with a short synthesised sound.

My profile (`my_profile_screen`) shows the stage as its hero when a look is
active (with *Customize*), otherwise the photo with a *Create your 3D avatar*
card when the studio is enabled. The completeness checklist counts the avatar
as a step.

## Admin panel

*Settings → Avatar Studio*: enable toggle, allow-photo-upload toggle, usage
stats, and the catalog by category with add / edit (image upload, price,
rarity, gender, gradient colours, sort order, live switch), hide / show and
delete.
