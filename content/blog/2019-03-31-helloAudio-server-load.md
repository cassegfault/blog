---
date: 2019-03-31
layout: post
title: Load Balancing for helloAudio
---

This is a part of a series of posts that follow the development of a side project I've been working on called HelloAudio, an in-browser multitrack audio editor. The project is primarily for exploring thoughts I've had on technical implementations. As these pieces come to fruition I am writing about them here.

## Load Balancing on the API Server

The API server for HelloAudio has a somewhat unique workload. It will be filled with both simple short-lived connections for reading and writing to the database, longer connections for transferring files, and compute-heavy connections for audio processing. The majority of the connections will be in the first two categories.

The architecture of the API is quite versatile, but does focus on shorter connections that will need to communicate with database and storage servers. The API has a thread pool and each thread has a worker pool which asynchronously work through requests in the threads queue. This creates a choke-point in which a particularly heavy compute request could be processed by a worker while there are a number of smaller connections in the queue. There is no way to know whether a connection will be long or short until that connection has been accepted and read by a worker. 

However, when accepting a connection we can check on each thread and determine which is most likely to handle the connection the fastest. In order to do this, we need some way to predict the amount of time it takes a thread to completely burn through its queue.

<!--readmore-->
### Defining Load

When the server accepts a connection and assigns it to a thread, it has no way of knowing how long that connection might last. The best guess we can make is the median processing time for all connections handled by the server. This is a terrible estimate because of the distinct difference in request times by purpose. When the request is read, the server has the potential to have a much clearer picture of how long this request might take.

A simple way to approach this might be to assign a value to each handler. That could be a category, or even a number representing a weight for the request. Then, once the request is read, use this number to update a thread's load factor. The value represented in the load factor could be entirely arbitrary at this point, but it's something to sort by.

However, the server should be recording timings on requests already. This is much more valuable than an arbitrary number we would have to assign to every handler and is an automatically generated piece of information. Using this timing we can build a table that defines requests and how much time they are expected to take. Each time a request is processed, this table can be updated. Each time a request is read, this table can be used to more accurately update the threads load factor.

The table to define our requests could be as simple as a mapping of request target to median time to process. This does not work for all requests. Some endpoints may have serious performance implications in their query parameters or request verb. For example:

```
GET  /posts?limit=25000
GET  /file?download=true&preprocess=true
POST /file
```

Adding just a few data points to the key we use to map timings will greatly improve the accuracy. However, with each data point we reduce the number of samples we're likely to encounter to build an accurate timing and reduce the likelihood of having a request time to base our load estimate on. For example, if you include all query parameters and one of those parameters is an ID you will have a new row for every ID. The amount of rows used has both performance and memory implications, as it is a map which will do a hash lookup.

Due to the API structure of helloAudio, simply using the verb and target are enough. Each time a request is processed the table is updated, creating a new average for the matched request type including the latest timing. Every time a request is read a lookup is done and if a timing is found it is added to the threads load factor, otherwise a default value is used.

Using this method the load factor for any given thread is a reasonable estimate as to the amount of time it will take to process all active connections. Using this value and the number of requests in the threads queue will provide a very reasonable sort order for assigning new requests.

### Encountering Heavy Requests with a Long Queue

When requests are in the queue, they all have the same weight. Only connections accepted after a lengthy request is read are affected by the new load factor. Up until the point the request is read the load factor could be quite low comparitively and thus the queue would be added to accordingly.

In an extreme circumstance this could result in threads waiting for new work while another thread has several connections in its queue. This could be a serious cause of timeouts depending on the load profile. This is one of the disadvantages of running separate IO contexts on each thread (the benefit of course being that each request is tied to a thread and will have far fewer cache misses, among other concurrency benefits).

There are a few ways to address this, the most simple is to before waiting for new work instead find another thread that has connections in the queue and run its work on the current queue. This removes some of the thread-safety assumptions of each request being handled on a single thread, but is an easy solution. 

Alternatively a work stealing approach could be taken. In the helloAudio server the queues are safe to use across threads so any thread can become a consumer of any other threads queue. These connections have not been read yet, so any connection popped from the queue will still be handled on a single thread, but now handled on a thread which has time to spare.

### Load Balancing the Easy Way

These posts and the helloAudio project are specifically for me to explore approaches to solving problems which I find interesting. Throughout the post you may have been thinking about how a thread-per-connection model maintains thread safety and is load balanced by the OS or how running a single io context across multiple threads could load balance with far less code. I have added some requirements to this architecture specifically to have a bit of fun. This is not meant to be a prescriptive post about how an API server should be written, but instead a description of how I have developed a pretty performant and easy to use server for a specific set of constraints. Hopefully my notes bring some perspective or even can be adapted for your own needs.

