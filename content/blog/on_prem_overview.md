---
date: 2023-03-13
title: "An Overview of On-Prem Deployment"
draft: true
layout: post
---

It's been a while since cloud solutions were anything but ubiquitous in tech, but many are finding that cloud solutions are not necessarily the right fit for their business. It could be due to AWS reaching Salesforce levels of complexity (having equally poor ergonomics), workloads becoming too expensive to make sense to run in the cloud, or the growing security risks associated with cloud providers. All are valid reasons to investigate alternatives.

The groups finding that moving off cloud is beneficial are pretty varied! Some have traffic-intense big data or media workloads, others have obscure hardware requirements, but many are run-of-the-mill SaaS companies.

On-premises deployments vary from a mini-pc in a closet up to full room datacenters and beyond. As in everything, each business' needs are different. You'll need to consider what your specific circumstances are.

Moving things on-premises is not an all-or-nothing move many times. It is almost always possible to draw a line in your infrastructure and pull one side of that line onto local hardware. Obviously this needs to be done strategically, but it is feasible.

Below I'll discuss many of the factors you'll need to consider when deploying systems on-premises. I try and keep the discussion broad and note when something may not apply to smaller or larger deployments and provide some actionable areas for consideration.

1. [The Servers]({{< ref "on_prem_servers.md" >}})
   First you'll need to pick some hardware to run your service(s) on. We'll use this a s a foundation for all of the other decisions.
2. [The Space](#)
   Your server may just need an outlet and a shelf, or significantly more than that. We'll consider power, cooling, security, fire safety, and more.
3. [Building a Network](#)
   ISPs through DNS, load balancing, routing, and certificates -- networking can be daunting. We'll walk through the necessary pieces and make it more approachable.
4. [Deploying and running your code](#)
   You probably already have this set up! We'll cover the differences between cloud and on-prem deployments and the gotchas you might encounter.
5. [Backup and Maintenance](#)
   Probably the most feared part of bringing services on-premises is not knowing what will happen when things go wrong. I'll discuss what that _actually looks like_ and ways you can be prepared (it will sound pretty familiar.)
6. [Staffing](#)
   Everybody pays the cloud so you don't have to staff the datacenter right? We'll talk about the required skills, how much help you'll need, and how to consider working with contractors.
