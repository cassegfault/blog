---
date: 2023-01-15
title: "Rhizomatic Structures: Evading the Omnipresent Arborescent"
layout: post
---

I've found that possibly the most ubiquitous structure in programming is the tree. We use them everywhere -- file systems, namespaces, even code itself "branches". It's such a fundemental concept nearly every data structure or schema we architect has a tree-like hierarchy.

> I have a `Foo` which has a `Bar` which has one or more `Baz`

Even in cases where data is not _really_ tree-like we abstract that away to fit in a much more tidy hierarchy. Blog posts have a many-to-many relationship with tags, but our abstractions will undoubtedly look like `Post->Tags` or `Tag->Posts`. Usually we consider the entire state of the application to be wrapped up in a single tree.

> MyStore is an application with a database which contains products, reviews, sales data, etc.

In my free time I spend a lot of time diving into philosophical concepts. It stretches a different part of my brain and can be helpful in finding ways to cope with (*gestures broadly*) all of this.

Exploring some of the facets of capitalist realism I stumbled across this idea by Deluze and Guattari that while we tend to conceptualize in terms of trees, a structure which holds up to more scrutiny is the Rhyzome.

Tree-like, or Arborescent, structures are strict hierarchies. Each leaf has a parent and zero or more children. Rhyzomatic structures are a bundle of interconnected vertices. There is no root and no direction. 

What we might conceive of as a single branch of a tree would be a cluster of indices in a rhyzome. When I use this model to think of application state or other data a 'branch' is some cluster of indices being considered in isolation, although they still have connections to unconsidered points.

I find this is helpful when considering your data in a whollistic way more than when considering a single abstraction. Let's take an ecommerce platform for example: I have a store which has products which have a description, category, and reviews.

![](/rhizome_1.svg)

Pretty simple tree, but those reviews are written by _users_ which also have other reviews.

![](/rhizome_2.svg)

Also categories are applied to many other products

![](/rhizome_3.svg)

When we peel back the curtain and look at higher degree connections we start to see how interconnected our app really is. Our initial tree depiction of the product no longer makes sense, a product is really just an intersection of linkages.

![](/rhizome_4.svg)

You can imagine how incomprehensible this might become in a real-world set of schemas. For me, this immediately makes me think of the complexity of making changes in intertwined systems like this. We've all had the discussion of "No you can't just re-build X table! Do you know how much of a rats nest this thing is?" 

But it also shows just how often we ignore this reality because we have our tidy tree-based views of our data. Especially in larger organizations I've seen the post-mortems where Service A made a subtle change that passed all the tests but took down Service B in production because of the assumptions baked into our tree-based views. These outages also can take down large sections of the company because at the end of the day, _its all connected_.

This is a pretty limited and simplistic representation of the concept. I've really only touched on the cartography of rhyzomatic structure, however if your look into the ideas Deluze presents in `A Thousand Plateaus` there are really interesting concepts about multiplicity, the heterogeneity of rhyzomes, and its interconnectedness.


