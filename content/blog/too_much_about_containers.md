---
date: 2023-03-01
title: I learned too much about containers
layout: post
---

I spent the last year working on software for companies in the logistics space. Largely we were focused on facilitating the sales process for freight forwarders. Forwarders are an intermediary between people who have something they need moved and all of the various entities involved in that process.

Consider ordering a set of furniture from another country an ocean away, how would you go about getting it from the manufacturer to your front door? You'd need to get a truck to pick it up from the manufacturer, put it in a shipping container (where does that come from?), bring it to the port (paperwork for the container needs to already be filled), book a spot with a carrier to ship it across the ocean, customs paperwork needs to be filled and paid (on time!), another truck needs to pick it up in your country, bring it to your front door, offload the furniture (how does it get off the truck?) and do something with the empty container.

How would you know how much that is going to cost? What fees are you going to accrue across customs, loading & unloading, delays at the port, etc?

This description of the problems you'd need to solve is not contrived, but rather over-simplified. There are many, many more complexities in shipping even fairly standard freight. One perspective on what forwarders are is a silo of knowledge required to solve these shipping problems. You tell them the move you need to make, they ask all the necessary questions and get your signature on all the necessary paperwork then send you the bill when it's done.

### A fragmented industry

As I showed in the description above, there are a _lot_ of players involved in moving freight. Because of this, there are many different firms that abstract some of that complexity. These firms can look pretty different from each other as they each have their own area of focus with differing pain points.

In approaching forwarders as a market, this means that the workflows and standard procedures are varied from company to company. While one company spends 90% of their time on X, it's not even a consideration for another (sometimes seemingly quite similar) company.

We spent a lot of time stepping back and taking a look at the contacts we had and what was actually the same between them. They all are giving quotes to customers and contracting with carriers (or consolidators), but the ways they go about this are still pretty varied.

One thing that was quite surprising is how much of the work is done over email. Many of the smaller forwarders we talked to would receive an email requesting a quote, they'd send an email to an agent they knew could handle the shipment, take the number they got back, apply some markup, and respond to the customer. This process took days/weeks.

The key takeaway here is the basis of everything forwarders do is ocean rates. They do many, many other things, but the rate is a central part of every transaction they are making with the customer.

*Note here that we're talking about ocean rates. Freight is also moved by air, train, and truck but most of what I know has to do with ocean rates.

### Containers, contracts, and rates - oh my

There are only a few major ocean carriers, if you're shipping something you'll have to buy some space on one of their boats. Larger forwarders may have contracts directly with the carriers but many will have to either use the spot market or go through a consolidator. 

Consolidators and carriers tend to send out their prices via email either as a spreadsheet attachment or _as text directly in the body of the email._ There's not a lot of progress on moving towards APIs, though I'm sure that's on the roadmap for many.

These spreadsheets are... the absolute worst. They appear to be a mix of generated and hand-edited. There are typos, missing or incorrect data, and virtually every sheet has a different format. These can be incredibly difficult to interpret and usually require jumping back and forth between several spots to really get a sense of what the pricing actually is for a given rate. More on these spreadsheets in a minute.

The contracts contain a few key pieces of information related to pricing: The base rate broken out by container size + type, applicable surcharges, and the type of move this rate applies to.

Let's break down some terms:
- **Container Size**: Shipping containers are usually 20, 40, or 45 feet long
- **Container Type**s: Some examples:
	- **Dry**: a bog-standard metal box
		- `40, 20', 40D`
	- **High-Cube**: indicates the container is 9'6" rather than the standard 8'6". Most (all?) 45' containers are high-cube.
		- `H, HQ, HC` as either prefix or suffix
	- **Reefer**: Refrigerated containers, or 'reefers', for transporting temperature-sensitive cargo. These have a smaller capacity due to the refrigeration unit.
		- `R, RF`, can also be high-cube like `40HRF, 20HR`
	- **NOR**: Non-operating reefers. These can be discounted due to their smaller capacity and non-functional refrigeration. 
	- **Tanks**: Containers for liquid or gasses
- **Surcharges**: Fees, typically conditionally applicable, which are added on top of the base rate. Some examples
	- **Bunker Adjustment Factor**: (BAF) Contracted base rates stay static so the carrier covers the fluctuating fuel prices by adjusting this fee. This fee can considerably affect pricing.
	- **Peak Season Surcharge**: (PSS) Exactly what it sounds like, demand is high during this time so a surcharge is applied (Typically June-November)
	- **Canal Surcharges**: (PCS/SCS) Travelling through passages like the Suez Canal or Panama Canal incurs a surcharge

Between the complexity of pricing due to differences in cargo and determining which surcharges are applicable many quotes simply take a base rate (or a number derived from intuition) and apply a % increase for margin. This reduces operational complexity for the sales team considerably, but can be risky and raises the bar for new recruits as they do not have any of that inutition built up.

It's pretty obvious that there's something to be gained by taking unifying these rates and systematically determining pricing rather than this intuition based approach. In order to do that we needed to parse the spreadsheets containing the contracts I mentioned above.

### Rate sheet parsing

This has been my waking nightmare and intense addiction for several months. I mentioned earlier these have many different formats which is only a small part of why these are so difficult to work with. There are a few key problems that prevent off-the-shelf solutions from parsing these files:

- **The ad-hoc placement of tables in sheets**: These spreadsheets are excel files where the document is laid out in an ad-hoc manner. There may be dozens or even hundreds of _tables_ on any given _sheet_. 
- **Key information residing outside of the table**: Some files will have tables which will be compressed by having an enumeration above the table which applies to each row of the table. For example you may have a list of origins above a table containing destinations and rates. The total number of rows this represents is `count(origins) x count(destinations)`. Other times tables will be grouped with metadata placed above or below the grouping, many times this is the case with the validity dates.
- **Hierarchical Headers**: Some tables will lay out their headers in a hierarchical fashion. This creates a similar effect of having multiple rows intermingled with eachother. For example a table may have an origin, destination, then prices for 20/40/45' containers _for each carrier_.

Having spent time in the linguistic analysis world before the takeover of neural nets I initially approached parsing these sheets in a similar fashion to a stateful parser. I've seen this pattern used very powerfully in the past and knew it could handle multiple tables and context existing outside of tables. It wasn't until much later we encountered the hierarchical header case.

I built a tagging system for cells which were potentially header rows and at each row these would be used to determine if this row was the header for a table. Only tables we are interested in consuming would pass this test.

This approach also works for context outside of the tables. When a piece of information we're interested in is parsed it is stored and can be applied to tables in both a forward-looking and backward-looking fashion.

This worked surprisingly well and adding a few configuration parameters allowed many types of sheets to be parsed unsupervised.

As we encountered more types of sheets cell classification work didn't plateau as well as I would have liked. This is where a language model comes in quite handy. Using zero-shot classification accounts for the many different terms used to identify similar concepts.

#### Why not use a LLM?

During the ChatGPT craze it commonly came up that an LLM can read CSVs, write JSON, etc. It's pretty enticing to a fast-moving startup to hit the easy button and drop a ton of money on OpenAI instead of the time to develop something in-house.

My initial concerns were pretty obvious, these models have limited memory and the sheets are large, their output is not predictable, and the language in our dataset is industry-specific.

There are workarounds to each of these problems but at the end of the day we would end up spending a lot more time on problems we weren't familiar with rather than working through the conventional build's hurdles. In 6 months if we went with an LLM we would be in the same spot as if we didn't, but it would cost significantly more to operate.

My view of LLMs during this time eventually shaped to be that they are useful for _fuzzy questions._ If you're dealing with interpretation, unknown unknowns, etc you're going to get a lot more benefit than if you are trying to perform logical operations or answer questions exactly.

Multimodal models exist, but typically aren't helpful for questions about the meta of the data. Most of these are built to simulate SQL in a sense and that really isn't the right place to answer questions about which column has the type of data you are looking for. Additionally, these models require your data to have some sort of schema, but the data we are working with is ad-hoc with features which are significant to interpretation such as style, font, and merged cells.

#### Cleaning vs parsing

Like so many data projects we eventually found that pre-processing the data would significantly assist passing the tables. Particularly, this could be helpful for the hierarchical-header problem. 

There are CNN models out there which solve the region detection problem even specifically for excel spreadsheets. This would be a pre-requisite to building an interpretation of the structure of each table.

These models lacked the performance of the stateful parser but produced pretty reasonable results.

#### Wrapup

This is far from everything I learned in this space and certainly is not a comprehensive look at anything. However, hopefully this provides some benefit to someone who is taking this space on in the future. Feel free to reach out if you're diving in, I'm happy to share the things I've learned. 

