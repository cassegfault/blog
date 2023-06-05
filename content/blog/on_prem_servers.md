---
date: 2023-03-13
title: "On-Prem Deployment: Server Hardware"
layout: post
draft: ttrue
---

Picking hardware these days is, in some ways, easier than ever. There are system integrators that will send ready-made systems, wide parts compatibility, and a wealth of knowledge online. The very first thing you need to consider, however, is _how much server you need_.

### Maybe just get a NAS

If what you need is relatively simple, there may be a very low cost option that meets your needs. Many small to medium sized businesses can probably get away with a modern NAS. These days they not only provide a common network drive but can also run services, even automatically installing and applying updates. Have a few python scripts you need to run on a cron or when a file is uploaded? These are phenomenal for this type of work.

> Here are some links to some NAS options  
> <sup><sub>_These are affiliate links_ </sub></sup>
>
> - [Synology Diskstation with 4x4TB drives](https://www.amazon.com/Synology-Diskstation-Dual-Core-LAN-Port-IronWolf/dp/B0BN1K2YT3/ref=sr_1_2?crid=3FY6RONEEFVXP&keywords=synology%252Bdiskstation%252Bbundle&qid=1680804175&sprefix=synology%252Bdiskstation%252Bbundle%252Caps%252C60&sr=8-2&ufe=app_do%253Aamzn1.fos.ac2169a1-b668-44b9-8bd0-5ec63b24bcb5&th=1&_encoding=UTF8&=lostfutures-20&=ur2&=ac1d1501b884b318374aa3ec01166876&=1789&=9325)  
>    Extremely popular NAS which is easy to use and quite capable. The linked version comes pre-filled with 4TB drives.
> - [2 Bay QNAP NAS with 2x4TB drives](https://www.amazon.com/QNAP-Capacity-Preconfigured-IronWolf-TS-233-24S-US/dp/B09YTC3LCX/ref=sr_1_6?crid=18GWHE3L1LA1X&keywords=qnap%252Bnas%252Bbundle&qid=1680804382&sprefix=qnap%252Bnas%252Bbundle%252Caps%252C65&sr=8-6&th=1&_encoding=UTF8&=lostfutures-20&=ur2&=bfb0beae43f8728119907c19484c9ee9&=1789&=9325) ([Synology alt.](https://www.amazon.com/Synology-Diskstation-RTD1619B-Quad-Core-LAN-Port/dp/B0BW9NQY1J/ref=sr_1_2?crid=3PUVLV62HGAW7&keywords=synology+ds223&qid=1680806324&sprefix=synology+ds223%252Caps%252C75&sr=8-2&ufe=app_do%253Aamzn1.fos.ac2169a1-b668-44b9-8bd0-5ec63b24bcb5&_encoding=UTF8&=lostfutures-20&=ur2&=311e1cb0d95502c83c7afcccec3cd57b&=1789&=9325))  
>   People tend to prefer Synology over QNAP but it's best to compare the options. Note 2 bay solutions have lower redundancy, but are a great buy for small businesses that have low requirements or budget.
> - [Diskless Synology RS422+](https://www.amazon.com/Synology-Rackmount-RackStation-RS422-Diskless/dp/B0B1D5BL5C/ref=sr_1_1?crid=3B8F7YRDNUATR&keywords=synology+rs422&qid=1680805486&sprefix=synology+rs422%252Caps%252C94&sr=8-1&ufe=app_do%253Aamzn1.fos.ac2169a1-b668-44b9-8bd0-5ec63b24bcb5&_encoding=UTF8&=lostfutures-20&=ur2&=4d77c6c785f56c5a2c104ba905807604&=1789&=9325)  
>   If you've already got a network rack, this may fit there
> - [8TB Iron Wolf Pro NAS drive](https://www.amazon.com/Seagate-IronWolf-7200RPM-256MB-3-5-Inch/dp/B07H28PKM4/ref=sr_1_4?crid=3PDR05HRSMHHF&keywords=iron+wolf+8tb&qid=1680805741&sprefix=iron+wolf+8tb%252Caps%252C83&sr=8-4&ufe=app_do%253Aamzn1.fos.18ed3cb5-28d5-4975-8bc7-93deae8f9840&_encoding=UTF8&=lostfutures-20&=ur2&=125e743cb2f8afa82e729a3805f668b4&=1789&=9325)  
>    These come in many sizes, you'll probably want to buy a size larger than what you think you'll use. Make sure you get NAS drives, don't cheap out and don't buy renewed.

If this suits your needs you should definitely buy one of these machines, stick it on a shelf somewhwere, and forget about it. For the most part these manage themselves and there is a customer service rep ready to help when they don't. There's no need to fuss with anything else discussed here and it's really not worth pursuing until you really need it.

### I know I need _something_ more than a NAS, how do I know _what_?

Beyond a pre-built appliance like a NAS we get into more classical servers. On the low end these are reasonably similar to desktop PCs but get incredibly wild on the high end. Generally, you will want to match your hardware to the architecture and performance requirements of your software. For example the requirements of a database may look different than your Rails/FastAPI/Express application.

There's no one-size-fits-all guideline on what to buy here, you really need to consider _what_ you're running. Some aspects to keep in mind:

- **Memory Bandwidth**: Especially if your database fits in memory, minimizing the time it takes to pull data out of memory is crucial for your database.
- **Disk Speed and Bandwidth**: Data larger than main memory will require trips to the storage peripheral. Disk IO will almost always be the bottleneck on these systems, and as you increase capacity and speed the price tag can get quite hefty.
- **Network Bandwidth**: If the network is limited at 1/2.5/10Gbps that may be the bottleneck on how fast you can handle requests no matter how fast the machines on either side of the connection are.
- **Core Count**: More cores _might not_ give you the gains you're hoping for. Keep in mind most scripting languages run single-threaded, but also that most HTTP servers spin up a new thread for each request.
- **Clock Speed**: Your CPU only runs as fast as you can feed it work. A system that can churn through light network requests may not seem so fast when churning through files outside of main memory.
- **Memory Architecture**: Did you know not all ram is equal? Not only does memory access divide across channels but in larger server nodes you'll find Non-Uniform Memory Access can be fairly common. A core's access to some parts of memory will be faster than to others.
- **RAID**: A dead drive can be catastrophic even when you have backups. Using a (non-zero) raid prevents those catastrophes while taking a minor hit to drive capacity and performance. Factor in the number of drives and expected performance implications if you're building a storage server.

Another key decision to make is how many servers you need! A common rule of thumb you may have heard is to have one server per service. There can be a lot of benefits to abiding that rule, however it's not the only option. Especially with the prevelance of containerization today, serving multiple services from a single machine can make a lot of sense. You may serve both your API and your frontend on the same application server or maybe a few lower-traffic services and their shared database. Some of the kubernetes folks tend to lean more toward this approach and allocate additional storage or compute balanced nodes as needed.

Depending on your budget and requirements you might want to purchase any of: commodity hardware, a workstation build, or an enterprise server. These will closely align with the CPU platform divisions.

### Commodity Hardware for a server?

Intel Core and AMD Ryzen CPUs, < $10k

The past half-decade has seen tremendous advances in both consumer and enterprise grade hardware. Anymore, even a moderate consumer-grade machine provides exceptional performance for web services. If you have low requirements or are cash-constrained some consumer hardware can take you a long way.

This is not a guide on how to build a computer, but I will provide notes specific to building a _server_ with commodity hardware:

Commodity hardware typically provides more than enough performance to be serve the application directly handling requests in the case of a web application. It can make sense as a database in a pinch, and might even make sense for some machine learning tasks if they aren't too heavy. That being said, there are obviously some hard limits:

- Max memory bandwidth is ~90Gbps, typically 2 channels
- Max memory capacity is 128GB
- CPU maxes out at 16-24 cores at 5.8-6.0GHz
- CPU cores may be in a big.little architecture meaning some cores are more powerful than others
- Larger arrays of drives will require special PCIe devices
- PCIe connectivity is limited
- Support for ECC ram is spotty
- Motherboards may only have single gigabit NICs
- Will not have IPMI or anything like that

If you want to use rack-mounting you can get a chassis either off ebay or from a vendor. Depending on your cooling setup you may need a 2u or 3u case, though braver readers may attempt 1u solutions. Some chassis even support standard ATX power supplies.

Some additional notes:

- **Water cooling may not be a great idea**, make sure you have a way to check water levels, top off the system, and something to remind you to actually do that. AIOs will degrade quickly in an always-on environment. Make sure if a tube bursts it won't destroy a rack of servers below it.
- **Older platforms may require a graphics card** in order to boot, even if you won't be using a display. In any case it's a good idea to have _some_ way to get graphical output from the server in case you lose the ability to SSH in.
- **Definitely don't overclock your server**, the performance improvement will never outweigh the impact to stability. Even if the system is rock solid you'll be second guessing yourself while hunting down a bug that _just might have been a stability issue_.

## Workstation builds

Intel Xeon W and AMD ThreadRipper CPUs, >$5k <$25k

It seems like workstations have become fairly rare in software development over the past decade or so, but at one point it was very common to have one beefy machine in the office that was used as a build server, for testing, and hosting LAN servers on game night.

These machines are typically quite capable when it comes to performance-intense workloads such as compilation, rendering, or AI training, but can more geared toward an _individual_ using them as a desktop machine rather than as a server. One major benefit to this is they tend to be significantly quieter than servers built for the datacenter. If you don't plan on having a dedicated server room, this might be pretty important.

Some improvements these machines have over commodity hardware include:

- Support astronomically more ram (2TB at time of writing)
- CPUs with up to 64 cores
- Significantly more PCIe connectivity and available lanes
- Can come in dual-socket configurations for running multiple CPUs
- On-board support for enterprise storage interfaces like u.2
- Tend to have IPMI for remote management
- Manufacturers may have better customer support

Workstation systems cover a pretty wide middle ground between gaming PC and top-of-line servers. These _tend_ to be more compute-oriented machines, though one can feasibly build a machine with considerable storage using this platform (it may not be cost effective.) They come with ~6-10 onboard SATA but that could be increased with PCIe cards.

These machines tend to be nice to have around as a "brute force" option. That may mean a one-off or infrequent job that no longer needs to be engineered to be done more efficiently, running a bunch of virtual machines to test a system architecture change, or to stand in for other systems while they're under maintenance for one reason or another.

That being said, they are not without their drawbacks:

- they are quite large, can be loud, may consume 1000W+, and put off considerable heat
- AIO water coolers can degrade extremely quickly if you use them (newer coolers may solve this problem, but has been true for a while)
- Prebuilts can be very expensive for the parts

## Purpose-built servers

This is where we break from the CPU platform structure a bit. Certainly, a purspose-built, enterprise style server is the only place you're going to find AMD's Epyc or the highest end Xeon chips. However, there are also all kinds of other machines in this space. Some have relatively paltry paltry processing, but a lot of connectivity for storage. Some are
