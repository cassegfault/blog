---
title: My Infrastructure
date: 2019-04-22
---

I have a fairly complicated setup for all of my personal infrastructure and I believe documenting it here may push me to make it better. 

Machines:

- Primary Server / Workstation
    - 12/24 Xeon with 64GB ram, single 1TB SSD
- NAS
    - AMD FX6300 (6/6 @ 3.5GHz) with 8GB of ram, 4 2TB HDDs in a ZFS pool (RAIDZ)
- Supermicro Router
    - Intel Atom D525 (2/4 @ 1.8GHz) 2GB ram, 32GB storage
- Raspberry Pi 3 B+
- Raspberry Pi 1 B
- Several remotely hosted virtual private servers

## Network

All network traffic is managed by the [Supermicro](https://www.supermicro.com/index_home.cfm) router running [PF Sense](https://www.pfsense.org/). PF Sense routes incoming traffic, segments internal networks, and is a convenient way for me to block some security cameras I have from accessing the web (I want them as a backup for insurance, don't really want 24/7 streams of my house sent to the web).

<!--readmore-->

The primary server and NAS are directly connected via the router box, other machines (phones, laptops, etc) access through a wifi access point which has its own network and rules on a separate interface on the router.

The Raspberry Pi 1 B is set up with [PiHole](https://github.com/pi-hole/pi-hole) and is awaiting a weekend where I can integrate it.

For now, the network setup is relatively simple. I hope to clean this up a bit in the future, have better name resolution for local machines, and finally set up the VPN properly so I can access my local network from the outside world.

## Externally Facing Applications

I have a few websites and APIs I host (such as this one) which are all located on the primary server. This machine has a few too many purposes at the moment, and should be narrowed down. However, more machines require more space and that is not a luxury I have at the moment.

Once to the server, incoming traffic is primarily routed via [nginx](https://www.nginx.com/). I have separate configurations for each application and they can be enabled or disabled quickly. Most applications are managed via a tool called [supervisor](http://supervisord.org/).

There are several areas for improvement here. I am currently working on containerizing each of the applications (using [docker](https://www.docker.com/)), as this machine is currently a mess. Nginx configurations should be versioned with the projects and there should be some understanding of what dependencies some of these projects have. 

Another problem with this current setup is the database being run on the same machine as the applications utilizing it. These are separate concerns and have many reasons to be separated by hardware. In order to test the [high concurrency servers I wrote about](https://v3x.pw/shared/http-server-concurrency.pdf) with handlers requiring database connections I spun up a fresh copy of ubuntu and mysql using the NAS' hardware. A database machine is next on my list of probably unnecessary tech purchases.

## Internal Tooling

One of my reasons for having all of this setup is to test ideas and learn. One of the tools that helps me the most in achieving that is stat tracking. I use the [statsd](https://github.com/statsd/statsd) / [graphite](https://graphiteapp.org/) / [grafana](https://grafana.com/) monitoring stack which allows me to track virtually any metric over time with relative ease. All of this is hosted on the Raspberry Pi 3.

One tool that I have that utilizes the stat tracking tools is a simple air quality monitor I built using an ESP8266 (microcontroller with wifi), BME280(humidity and temperature sensor), and CCS811(air quality breakout). The ESP8266 simply needs to send a UDP packet with a formatted string of readings and the stats tooling handles the rest.

I self host a few applications such as [sentry](https://sentry.io) on remotely hosted virtual private servers. These are typically bargin-bin servers that only cost a few bucks a year. These servers also host a proxy for me to send requests through (via [squid](http://www.squid-cache.org/)) and play a role in a mini-cdn I have for certain public-facing applications (routing for this is handled by [Amazon's Route53](https://aws.amazon.com/route53/)). Deployment to those servers is handled by by [Jenkins](https://jenkins.io/), which I host locally and could be improved with containerization.

My NAS I also consider internal tooling. I use it for backups, but primarily it serves as a storage device for my photos and videos. I enjoy photography and cinematography as a hobby when I travel, however over the years the amount of space that requires has become more than I feel safe keeping on a single drive. The NAS currently uses HDDs as it would not make a lot of sense financially to get SSDs. These are configured in RAID-Z (zfs' raid 5) for best utilization of compression while still allowing me relatively quick access to the photos when I need them.

## In Conclusion

Self hosting is a bit of an addiction, however if you re-use hardware, stick to bargin bin servers, and keep your energy consumption in check it will cost you a bunch of time but only a little bit of money.