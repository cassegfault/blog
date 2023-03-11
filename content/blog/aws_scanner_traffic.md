---
date: 2022-08-10
title: Getting Rid of Pesky AWS Scanner Traffic
layout: post
---

I've found that knowing how a connection is getting from the wider internet to your application is both seldom comprehensively understood and a super important piece to resolving some common problems.

One super-common issue I've seen where this kind of understanding would be helpful is when you've set up your service on EC2 and all the sudden you're getting bombarded with traffic to weird endpoints like `/remote/login` or `/_wpeprivate/config.json`.

### What are these things?

You've probably seen these and you probably know they come from bots. Looking into it a bit closer reveals some important information: These are typically scanning the full blocks of IPs owned by AWS searching for known vulnerabilities on the applications hosted at these IPs.

Hackers of the malicious variety take the large blocks of IPs assigned by AWS to EC2 instances and any known vulnerabilities, then build a script that automates gaining access to large numbers of systems. Obviously depending on the exploit once they have access they may be able to cause some pretty serious chaos.

In this case it all starts with an HTTP request. They're probing:
Are you running wordpress?
Are you running an outdated version of wordpress?
Is your elasticsearch instance exposed to the internet?
Does it have the default password?

For the most part if you've done some basic security hygeine, this stuff isn't too harmful. In fact, most of the time I talk to people about this they're trying to improve their APDEX more than prevent security failures.

### How do we get rid of them?

The first thing people tend to do is google around, start throwing things at the wall, and seeing what sticks. It's surprising to me how ubiquitous this approach is, even senior+ engineers do this.

There's a better way! We can approach it just like we would a programming problem.

These bots are sending traffic to our _EC2 IP address_. So our goal with the changes we make are to _block unwanted traffic to our EC2 instances._ Let's take a look at most people's first approach:

![](/AWS_1.svg)

Adding a firewall, whether it be WAF, cloudflare, or something else will definitely help block unwanted traffic, so long as it sees that traffic. However, our problem is that our traffic is not coming in via the firewall at all!

![](/AWS_2.svg)

Remember these scanners are using the EC2 IP addresses, so if they're coming in after the firewall it won't prevent this type of traffic at all. You probably will see the firewall preventing _some_ traffic especially if you've had some exposure for your domain. There are the same types of bots that use lists of domain names instead of IP blocks.

Now the problem is really clear. We need to block off _just_ traffic to our servers. We can differentiate between good and bad traffic in a few ways:
- Does the `Host` header match one of our domains?
- Does it have a tracing header showing the request went through the firewall or load balancer?
We can build rules like these into our reverse-proxy(nginx, traefik) configs or into the HTTP server for our app itself.

Another, in many situations more preferable, approach is to block of incoming internet access to any of the servers but a single gateway. You need to make sure you understand the implications here, but generally for HTTP servers you only want traffic from the broader internet coming in if it's directed to your domain.

![](/AWS_3.svg)

This isn't an AWS tutorial but essentially you create a subnet for all of your services you want to filter out traffic for, then set the ACL (access control list) to block incoming traffic. 

There are a number of other ways to do this whether you are using AWS or not, so make sure to do the research and pick the best one for you!
