---
layout: post
title: Firefox Focus for Android is not necessarily secure
---

Firefox Focus is Mozilla's attempt at a privacy-first mobile browser. By all accounts, it's a great attempt at solving the browser privacy issue on mobile devices. Many complain about the lack of features, but for those focused on maintaining privacy, having less features can many times come as a relief.

I noticed the other day that after running the browser, clearing everything, and opening up a new session I still had links marked as visited. As the main claim of the browser is that it automatically erases your browser history, this is a bit concerning. [I am not the first](https://github.com/mozilla-mobile/focus-android/issues/322) to find this issue, and there is a fix on the way. The whole situation is still a bit concerning.

Many years ago [Mozilla posted](https://blog.mozilla.org/security/2010/03/31/plugging-the-css-history-leak/) about changes they had made to make sure that an attacker would not be able to generate a list of websites a user had visited by checking the style of visited links. The changes were effective and thorough, but even by their own admission, [would not be all-encompassing](https://dbaron.org/mozilla/visited-privacy#limits). Firefox Focus would truly mitigate all attacks of this kind if the claims of removing browser history were as true as one might hope (or more worryingly, one might assume).

<!--readmore-->
## The Bug

The bug could be classified as a bug not with Focus, but rather with chromium. This is the stance the firefox team seem to be taking, and it is reasonably valid. The [vector of links](https://chromium.googlesource.com/chromium/src.git/+/d0ef9df6be5983f6df7e4e050bbad4eb5030e7a2/android_webview/browser/aw_browser_context.cc#140) is added to automatically, and there's [no good way](https://github.com/mozilla-mobile/focus-android/issues/322) to trigger that to empty from within java. This has been marked as a priority 2 issue by the chromium team and will not be fixed anytime soon.

[Andrzej Hunt](https://github.com/ahunt) had the right notion to see if the browser context could be unloaded, I don't know that I entirely agree with the notion that this could not happen other ways. They implement their own system web view which I believe could be destroyed and reloaded, forcing that memory to be dumped and thus getting rid of the list of visited links. For an example of this in action we can look to the Google Chrome app. The incognito tabs in the chrome app not only clear this data but do not share it between tabs. The clear history function also removes this list. They already do a good job of removing on-disk caches, all that needs to happen is have that memory dumped.

## The Fix

The slightly more concerning thing to me is the fix that has been implemented in the beta. The firefox team has [implemented a fix](https://github.com/mozilla-mobile/focus-android/commit/252f761edd20b9ff1f1936862cdb4958a6d044cc) which seems very much like a band-aid. It injects javascript which clears styling rules based on the links in this array (they are accessed by the :visited state of links). This is not only a messy solution from an engineering perspective, but also only sweeps the actual problem under the rug.

Fixes like these do not need to be concerning from the standpoint of whether or not the bug is fixed, but rather from an architectural standpoint. In my day-to-day where privacy is not a huge concern, these types of fixes are a big warning sign that the changes introduce technical debt, poor performance, and will likely break. The real issue is not whether or not the bug was addressed, but the architectural problem of how it was addressed.

From a security standpoint, these types of fixes are even more concerning. This gives the appearance of a reduction of attack surface, but in reality only mitigate a single attack vector. This may make the app feel more secure, but it leaves the user un-aware of the technical reality that not all traces of their browsing history have been erased.

I don't want to come off as paranoid or extremely upset over this issue, but sweeping issues under the rug like this does not bode well for the claim of privacy made by the firefox team. True privacy and security are upheld by strict standards; the claim of 'erasing your browsing history' should not only be effectively true, but technically true. While this one bug may seem small and the fix good enough, I believe that we should hold ourselves (especially in the open source community) to a higher standard when it comes to privacy.


## The Good News

This bug may not be relevant all that much longer. The firefox team is working on dropping the WebKit renderer for their own Gecko. This would be a huge win for the project, albeit a lot of work. In that scenario any bugs like this could easily be mitigated because both projects are open source. In the current build of the gecko client the bug I have mentioned is already fixed. I am very excited for the gecko viewer to become the renderer for the Focus project.

## In Conclusion

I hope the members of the firefox team and contributors to the project don't take this harshly as I very much believe they are doing great work and in perusing the source code of the project while writing this I was thoroughly impressed. Everyone involved is doing great work, and I hope the standards shown throughout the rest of the codebase are kept for a long time to come.

For everyone else, do remember that security is difficult and must be watched with a close eye. Even decade-old exploits can rear their heads if we are not very intentional with every line of code we write.
