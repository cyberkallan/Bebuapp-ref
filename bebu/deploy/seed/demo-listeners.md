# Demo listeners

`demo-listeners.json` holds eight fictional Kerala-based caller profiles used
to exercise the app UI before real hosts sign up. They are created as **fake
listeners** (`isFake: true`) through the admin API, so the app renders them
with its simulated call flow, and they only appear while
`isDemoContentEnabled` is on in Settings. Turn that off before launch and
they disappear from the app without deleting anything.

Photos are AI-generated portraits (not real people). Each profile also needs a
short intro audio and video; the ones used on staging were produced with
ffmpeg from the portrait (8 s Ken-Burns clip + soft tone).

Recreate on a fresh database (admin Firebase ID token and uid required):

```bash
for p in $(jq -c '.[]' demo-listeners.json); do
  n=$(jq -r .n <<<"$p")
  curl -s -X POST "$PUBLIC_URL/api/admin/listener/createListener" \
    -H "key: $SECRET_KEY" -H "Authorization: Bearer $ADMIN_ID_TOKEN" -H "x-admin-uid: $ADMIN_UID" \
    -F "email=$n@demo.bebuapp.in" -F "name=$(jq -r .name <<<"$p")" -F "nickName=$(jq -r .nickName <<<"$p")" \
    -F "age=$(jq -r .age <<<"$p")" -F "location=$(jq -r .location <<<"$p")" -F "language=$(jq -r .language <<<"$p")" \
    -F "talkTopics=$(jq -r .talkTopics <<<"$p")" -F "experience=$(jq -r .experience <<<"$p")" \
    -F "selfIntro=$(jq -r .selfIntro <<<"$p")" -F "ratePrivateAudioCall=$(jq -r .av <<<"$p")" \
    -F "ratePrivateVideoCall=$(jq -r .vv <<<"$p")" -F "image=@$n.jpg" -F "audio=@$n.mp3" -F "video=@$n.mp4"
done
# then: db.settings.updateOne({}, {$set: {isDemoContentEnabled: true}})
```
