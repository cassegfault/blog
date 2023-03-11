---
date: 2022-10-22
title: Hidden Costs of Hitting the Easy Button
layout: post
---

With your last project you spent _way_ too much time figuring out all the complexities of _doing the thing_ yourself, so you've decided it's better to crack open the wallet than to lose the time. The rest of the team isn't so sure, it seems like something that could be done in-house, but it's your call.

It's more efficient! Sure it seemingly costs a lot of money, but that's _nothing_ compared to the cost of engineering time.

You spend the next few days perusing the options. There are lots of people solving this, You're obviously not the only one having this problem!

Finally several hours of shopping, a few sales calls, and several back-and-forth emails with the finance department later you've bought the service that will definitely speed up the project.

All we've got to do now is integrate!

The initial progress is promising, a basic proof-of-concept is built in no time. It feels good to have that weight off your shoulders. Now while the integration is happening on that you can move on to the next piece!

A couple weeks pass and the team still doesn't have the integration online. They're saying that the service makes a lot of assumptions that we have to work around. It works really well! It just can't quite speak the same language as the rest of the system. You return yet again to ruminating on the definition of "works."

A while later the integration is finally finished. It's not the slam-dunk you were hoping for, but this _definitely_ would have cost us more in the long run if we built it ourselves.

Some time passes. You awake in the middle of the night to a pagerduty alert (despite you being the 3rd fallback.) The integration is throwing a bunch of errors. It turns out something changed on _their_ side and your team didn't know it was coming.

"Looks like our RSS-to-slack bot has been broken for a while and nobody knew" one engineer says. "Doesn't everybody have that channel on mute after the barrage of 'minor fixes' update messages a while back?" replies another.

You have a meeting with the product team later that morning. They would like a small tweak to that feature's functionality. You pass along the request to one of your engineers. "We don't really _own_ that"

---

There are many perils to building it yourself, this is a small tale of perils of the easy button.
