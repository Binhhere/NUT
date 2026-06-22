# Store Console Answers Draft

These answers match the current v1 local-first build. Re-check before submission.

## Scope Assumption

Use these answers only if the submitted build still has:

- No backend.
- No account creation.
- No public community posting.
- No ads.
- No analytics SDK.
- No crash reporting SDK.
- No payment flow.
- No cloud sync.

If any of those change, update this document, `docs/PRIVACY_POLICY_DRAFT.md`, Apple App Privacy, and Google Play Data safety.

## Google Play: App Access

Suggested answer:

- All functionality is available without special access.
- No login is required.

If Google asks for test credentials, state that no account is required for v1.

## Google Play: Ads

Suggested answer:

- No, the app does not contain ads.

## Google Play: Data Safety

Suggested answer for current v1:

- Data collection: No user data collected by the developer.
- Data sharing: No user data shared with third parties.
- Data is processed ephemerally: Not applicable for developer collection because core data stays on device.
- Data encryption in transit: Not applicable for app data in current v1 because there is no backend transmission.
- Users can request deletion: Not applicable for developer-held data because the developer does not hold user data in current v1.

Explain in the privacy policy:

- Streak, optional username/reason, reminders, App Lock preference, and backup data are stored locally on the device.
- Export/import only occurs when the user chooses it.
- Notifications and App Lock are optional.

Review carefully in Play Console because Google may phrase questions differently.

## Google Play: Permissions And Disclosure

Current permission-related features:

- Notifications: requested only when the user enables daily reminders.
- Biometrics/device lock: requested only when the user enables App Lock.
- File/share flows: used only for backup export/import.

The app now includes:

- Onboarding privacy confirmation.
- Settings > Privacy & Safety screen.

## Google Play: Content Rating

Suggested framing:

- The app is a self-tracking tool for focus and discipline.
- It does not contain explicit sexual content.
- It does reference reset/recovery around sexual self-control behavior in app/store copy.
- It is not targeted at children.

Answer the questionnaire truthfully based on the final copy and screenshots.

## Apple App Store: App Privacy

Suggested answer for current v1:

- Data collected by this app: No.

Reason:

- The developer does not receive user data in the current local-first build.
- Optional username/reason and streak data stay on the device.
- No backend, ads, analytics, crash reporting, or account system is active.

Apple states that app privacy answers must include data collected by the developer and third-party partners. Re-check dependencies and features before submission.

## Apple App Store: Review Notes

Suggested review note:

```text
NUT is a local-first private streak tracker. No account is required. The mock feed is local demo content only and does not publish to a server. Premium screens are non-purchasable previews and all purchase copy says coming soon/no active purchase flow. Privacy & Safety is available in Settings, and onboarding requires a privacy confirmation before start.
```

## Apple App Store: Age Rating

Suggested framing:

- No explicit sexual content.
- No user-generated public content in v1.
- No gambling, alcohol, drugs, violence, or medical treatment claims.
- Sensitive self-control theme should be considered when answering age rating questions.

## Required Manual Values

Fill these before submission:

- Developer name.
- Support email.
- Privacy policy URL.
- Support URL.
- Marketing URL, if any.
- Copyright holder.
- App Store category.
- Google Play category.
- App review contact details.
