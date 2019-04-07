---
layout: post
title: Taking Advantage of Modern CPU Advancements
---

This is a part of a series of posts that follow the development of a side project I've been working on called HelloAudio, an in-browser multitrack audio editor. The project is primarily for exploring thoughts I've had on technical implementations. As these pieces come to fruition I am writing about them here.

## Taking Advantage of Modern CPU Advancements

Over the past several years processor clock speeds have not improved much. The Pentium 4 in 2004 had a base clock speed of 2.4Ghz compared to the Ryzen 2700X at 3.7GHz or the i9 at 3.6GHz both released in 2018, 14 years later. That's only 150% improvement over nearly a decade and a half. Obviously the important thing to note here is core count. With 8 cores now being standard that rate of improvement is still substantial. However, scaling with cores does not come as easily as scaling with processor speed.

The following are charts of the base clock, memory bandwidth, and core count of Intel processors of the past several years. As described above, the base clock and bandwidth have hardly moved, but there have been significant improvements in core counts.

<!--readmore-->
![Processor Advancements](/public/images/intel_cpu_over_time.png)

Not shown in these charts are any of the new AMD Zen architecture chips. These chips provide as many as 8 cores in their consumer grade chips and up to 32 cores in their workstation and datacenter grade chips. 

Both Intel and AMD are addressing this by adding memory channels, however this requires more DIMMs to provide more bandwidth, and the rate at which new channels are being added does not match the rate at which cores are being added.

This creates a bottleneck at remote memory access. In order to take advantage of the improvements in core count, this bottleneck must be addressed or avoided. Fortunately, cache sizes have scaled in turn with increases in core count.

### Multithreaded Cache Considerations

In the context of an HTTP server, frequently accessed memory is usually data associated with a request. As the request is processed the OS will attempt to keep this memory in the cache. However, if the process of handling the request jumps between threads (for example if you're running an ASIO io_context on multiple threads) frequent cache misses will occur, and the data will need to be retrieved from main memory.

If instead these requests are processed entirely on a single thread, these cache misses can be avoided. Additionally it requires less data to be shared as the request will be handled by a single thread. Many reading this may immediately consider the other implications: a thread-per-connection model can cause many more issues with long requests and will still have issues with the thread scheduler.

A thread-per-connection model may work for many, however servers which expect much higher loads will need to consider handling requests on an event loop as well to reduce idle time in threads waiting on network IO. These two concepts are not at odds, multiple threads can each manage an event loop and keep all processing for a single request bound to that thread. Any unnecessary shared memory should either be removed or reduced to local memory in order to reduce the memory bandwidth used by each request.

### Final Thoughts

For most it's going to be easiest to either use a thread-per-connection model or to have a single event loop running across multiple threads. As that architecture scales it will be easier to reduce time spent in the handler than to adjust the underlying architecture. However, when performance is of utmost importance and a very high load (especially load which will be doing a lot of DB access or other network IO), taking these considerations in mind will provide opportunities to improve request time and provide a more consistent latency.
