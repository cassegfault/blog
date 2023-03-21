---
date: 2023-03-05
title: "Combatting subscription fatigue in software teams"
layout: post
---

Since the rise of SaaS (and its siblings, PaaS, IaaS, etc) the number of subscriptions needed by any given software team has snowballed dramatically. Most of these also charge based on the number of people using the service, so as the team grows these costs grow exponentially. However there are a lot of these services that aren't necessarily critical. They're 'nice to have'-s or 'trying it out'-s. 

More recently there has been a steady rise in the self hosted space. Oodles of open source and permissively licensed software which likely will work just as well for you as the paid options. Most of these projects also have easy to deploy docker configurations, meaning deploying to AWS, GCP, or even $5 VPS is incredibly easy. In my experience these cost pennies per month to use and require very little upkeep.

**Not all services are a good candidate for this!** If the service will contain critical information or would prevent the team from operating by going down it is worth considering whether or not self-hosting is the right choice. I have seldom had self-hosted software catastrophically fail, primarily they stop working due to a lack of resources or change in the network, but should it fail *it's on you to get it fixed*. With that in mind, I've provided some areas which are (in my experience) good candidates for self-hosting:

### Stats and Monitoring

Tracking metrics inside your application should be trivial and engineers shouldn't be weighing whether a tag is worth paying DataDog another chunk of change. For many teams these are very helpful to debugging certain problems, but not critical to day-to-day operations. [There's a great guide on setting up Grafana + Prometheus](https://grafana.com/docs/grafana-cloud/quickstart/docker-compose-linux/) which is my preferred stats setup.

If you're interested in a self-hosted logging solution you could go as far as [running the Elastic/ELK stack](https://github.com/deviantony/docker-elk) (Elasticsearch, Logstash, and Kibana), however I'd warn that one is more likely to need some amount of upkeep. Logging can also be as simple as log files and [a log parser like GoAccess](https://goaccess.io/).

[Gatus is a super simple status page](https://github.com/TwiN/gatus#docker) which can alert you if your service goes down. There also are alternatives like [Vigil](https://hub.docker.com/r/valeriansaliou/vigil) and [Uptime Kuma](https://github.com/louislam/uptime-kuma#-docker) which may be better suited to your needs.

### Communication

I wouldn't recommend self-hosting email or chat as these tend to be super critical to team operations, however if you really want to [RocketChat is a Slack alternative deployable via docker](https://hub.docker.com/_/rocket-chat). 

If you're sick of the time limit on Zoom [Jitsi Meet is a good, maybe even better, alternative for videoconferencing](https://github.com/jitsi/docker-jitsi-meet).

You also may want a digital whiteboard for your team meetings, [like the one provided by WBO](https://hub.docker.com/r/lovasoa/wbo)

Project management tools are also abundant. There are [Jira alternatives like Taiga](https://github.com/taigaio/taiga-docker) and [pointing and retrospective tools like Thunderdome](https://hub.docker.com/r/stevenweathers/thunderdome-planning-poker). Looking for more to-do and less agile? [Focalboard is more to-do centric](https://hub.docker.com/r/mattermost/focalboard).

Thinking about trying Notion? Set up [Atomic Data's server](https://docs.atomicdata.dev/atomic-server.html) first and see if it works for you. 


### CI/CD and Development

[Trusty ole Jenkins](https://hub.docker.com/r/jenkins/jenkins) is still alive and well (and containerized!) for those of us that like that sort of thing. However you may be looking to set up your own runners for the CI pipelines built into [Github](https://github.com/myoung34/docker-github-actions-runner) or [Gitlab](https://docs.gitlab.com/runner/install/docker.html) to speed them up or cut back the cost.

There's also a very neat option called [Concourse CI](https://concourse-ci.org/quick-start.html) which looks helpful in more complex setups where you may have to debug pieces of the pipeline from time to time.

Did you know you can [host Jupyter notebooks](https://jupyter-docker-stacks.readthedocs.io/en/latest/)? This is handy if you want to host them from a powerful VM or want a common playground where everyone is using the same environment. Similarly there is a [web-based VS Code called code-server](https://github.com/coder/deploy-code-server) which allows you to write code anywhere and run/debug from a consistent environment.


### Miscellanea

- [Penpot is a figma alternative](https://help.penpot.app/technical-guide/getting-started/#install-with-docker)
- [Paperless-ngx](https://hub.docker.com/r/paperlessngx/paperless-ngx) will OCR and index your scanned documents and PDFs
- [Tooljet](https://hub.docker.com/r/tooljet/tooljet-ce) is an excellent Retool alternative for quickly building internal tools
- [NextCloud](https://hub.docker.com/_/nextcloud) is your own storage / office suite like Google Drive
- [n8n](https://hub.docker.com/r/n8nio/n8n) is a *very* widely integrated automation tool like ITTT 

If you're looking for more resources like this I suggest starting with these:

- [Awesome Selfhosted on Github](https://github.com/awesome-selfhosted/awesome-selfhosted)
- [Awesome SysAdmin on Github](https://github.com/awesome-foss/awesome-sysadmin)
- [/r/SelfHosted on Reddit](https://old.reddit.com/r/selfhosted/)

