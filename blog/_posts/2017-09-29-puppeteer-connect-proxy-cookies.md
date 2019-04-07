---
layout: post
title: Missing Puppeteer Examples
---

Google finally released [Chrome Headless](https://developers.google.com/web/updates/2017/04/headless-chrome) and shortly after, a nodejs library called [Puppeteer](https://github.com/GoogleChrome/puppeteer/). They have a decent document laying out how to use the API but a number of pieces are non-obvious. I needed to do a few things like connect to an existing chrome instance, use an http proxy, 

<!--readmore-->
### Connecting to an existing process

The first thing that can be difficult is attaching to existing chrome processes. I use this quite a bit as I don't like having multiple servers running chrome or god forbid multiple chrome instances up on a single server. After you've got chrome headless running (which can be a pain due to the dependencies) you'll need to run an http request to `localhost:9222/json/version` in order to get the `webSocketDebuggerUrl` which you're going to pass to `browserWSEndpoint` when running [Puppeteer's `connect`](https://github.com/GoogleChrome/puppeteer/blob/master/docs/api.md#puppeteerconnectoptions) function.

Here's a code sample from most of my current projects:

```javascript
http.get('http://localhost:9222/json/version', function(response) {
    let data = '';
    response.on('data', str => { data += str; } );
    response.on('end', () => { 
        let config = JSON.parse(data);
        endpoint = config["webSocketDebuggerUrl"];
    });
});
// ... 
this.browser = await puppeteer.connect({
    // ...
    browserWSEndpoint: endpoint
});
```

There are a couple of annoying issues with this such as not getting all the options as when you launch chrome from node (most notably `slowMo`). This is far preferable, though, because of the way puppeteer's launch function works, which is really *really* gross. [Read the function in question here](https://github.com/GoogleChrome/puppeteer/blob/a6cf8237b861473cc03a4825d6bc8cc786c1cb4c/lib/Launcher.js#L208)

*Remember to close your `Page` when you're done if you're connecting to an existing instance!*

### Connecting to an authenticated HTTP proxy

The solution to this is simple and won't be a problem for many, but it was very annoying to figure out. The `authenticate` function is built already, but has not been released (despite not being noted in the API). If you want to use it, you'll have to install puppeteer without NPM.

```javascript
// Chrome headless launched with option `--proxy-server=${the_ip}:${the_port}`
const browser = puppeteer.launch({
		// ...
		args: [ `--proxy-server=${the_ip}:${the_port}` ]
	});
// ...
const page = await browser.newPage();
await page.authenticate({ 
		username:'the_proxy_user', 
		password:'the_proxy_pass' 
	});
await page.goto('https://www.google.com/');
```

### Cookies

Cookies may be going the way of the dinosaur, but they're still important in many crawling projects. Here's a couple of quick lines I use to keep mine in check:

```javascript
// Store all the cookies for this page 
// you can store these in a file
var cookies = await page.cookies( page.url() );

// Delete the current page's cookies
await page.deleteCookie( ...(await page.cookies()) );

// Load them back in
await page.setCookie( ...cookies );

```

Hopefully some of these are helpful, hopefully the Puppeteer team will update their docs.
