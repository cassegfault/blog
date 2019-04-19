---
title: Hotfix Engineering
date: 2019-04-15
---

Software has sped up timelines of projects across virtually every industry. With that new power, many businesses see opportunities that weren't there in the past. However, with timelines sped up and a lower bar into engineering for software, some key elements of engineering are at times being ignored.

Boeing's 737 Max was designed to be an upgrade to the 737 with a new engine to compete with the new update to Airbus A320, entitled 'A320 neo'. A primary selling point of the A320 neo was to provide an upgraded plane without requiring additional training for the pilots. The 737 Max line, however, required structural changes to utilize the new engines; this would alter the performance of the plane and require additional training. Boeing's solution to this: An software augmentation system (the Maneuvering Characteristics Augmentation System, MCAS) to adjust the flight controls to feel like the original 737. If the 737 Max line handled similarly to the original, pilots were to be able to fly it with little extra training and Boeing would have a strong competitor to match the A320 neo. In producing this plane, Boeing would start down a path that would take nearly 350 lives.

<!--readmore-->

This all seems perfectly logical from a high level perspective but in retrospect on its failure there is a lesson that has been learned by many seasoned engineers. Solutions like the MCAS usually come from meetings that begin with "Can't we just..." and don't have anyone with a broad enough insight into the system to guide the conversation. The MCAS was covering up a larger problem: You can't both alter the structure of the plane *and* require little additional training. The MCAS is, of course, an extreme example.

On the complete opposite end of the spectrum is an example that is seen frequently by those who log errors in front-end development:

```javascript
// An error is logged, something like
TypeError: Cannot read property 'my_property' of undefined

// The offending code
var x_property = guaranteed_to_have_x.find(/* func to find x */).my_property;

// A PR is opened with the following hotfix
var x_property,
    found_x = guaranteed_to_have_x.find(/* func to find x */);
if (found_x){
    x_property = found_x.my_property;
} else {
    return;
}
```

In the real world the fact that x is guaranteed to be in the array may be more subtle. To a junior developer (or one with less exposure to the codebase), this would appear fine. The problem is seen as the item being assumed to be in array when it is not. However in reality, x should be guaranteed to be in the array, so the fact that it is not implies a deeper problem. Because this PR is labelled as a fix and there are 30 more in the queue and standups are in 15 minutes, the PR will be glanced over and merged.

The results of this could be subtle. It may pass all the tests, a cursory glance at its effects may seem fine. The problem this causes could be a user-experience issue, it could only appear in edge cases or for certain users. It will likely be hard to detect this is the offending code when the issue is raised.

This rapid-release approach to engineering presents a larger problem of not understanding a problem entirely before releasing a fix. The problem with the 737 Max wasn't that it didn't handle like the original, it was likely that the business goals were not achievable within safety standards. These problems should be met with growing a team of seasoned engineers and reducing turnover to increase the amount of exposure engineers have to the system on average.