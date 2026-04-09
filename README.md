# MacDownDocumentStats

This is a Swift MacDown plug-in project that adds **Plug-ins → Document Stats**. Fo

This corrected Xcode project is preconfigured to build the plug-in as **x86_64**, which matches the current MacDown app binary on macOS.

## Build
1. Open `MacDownDocumentStats.xcodeproj` in Xcode.
2. Use **Product → Build**.
3. When “build successful” use **Product → Show Build Folder In Finder**.
4. locate the built `MacDownDocumentStats.plugin`.
5. Copy it into `~/Library/Application Support/MacDown/PlugIns/`.
  6. You may need to create the “PlugIns” folder in `~/Library/Application Support/MacDown’ - make sure capitalization is correct.
7. If MacDown is open, quit it. Restart MacDown.
8. Open a doc. Goto “Plug-ins” in the menu - you should see “Document Stats” as an option.
9. Select “Document Stats” - you can copy the information with the button.

## Verify architecture
After building, this command should report `x86_64`:

```bash
file ~/Library/Application\ Support/MacDown/PlugIns/MacDownDocumentStats.plugin/Contents/MacOS/MacDownDocumentStats
```
