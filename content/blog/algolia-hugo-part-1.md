+++
type = "post"
author = "Author"
date = "2017-03-03"
title = "How I integrated Algolia search into my Hugo blog - Part 1"
description = "Indexing articles content"
categories = ["hugo", "algolia"]
+++

Found https://www.npmjs.com/package/hugo-algolia

```
$ npm install hugo-algolia
```
```
npm WARN saveError ENOENT: no such file or directory, open '/home/horgix/work/blog/package.json'
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN enoent ENOENT: no such file or directory, open '/home/horgix/work/blog/package.json'
npm WARN blog No description
npm WARN blog No repository field.
npm WARN blog No README data
npm WARN blog No license field.

+ hugo-algolia@1.2.13
added 55 packages in 1.284s
```

Had no `package.json` as said so I just created it:

```
echo '{}' > package.json
```

And reinstalled it just to make sure it's in the `package.json`: 

```
$ npm install hugo-algolia
```
```
npm WARN blog No repository field.
npm WARN blog No license field.

+ hugo-algolia@1.2.13
updated 1 package in 0.984s
```

```
$ cat package.json
```
```json
{
  "dependencies": {
    "hugo-algolia": "^1.2.13"
  }
}
```

=> d43f08d927b02a4818032cf8366412cf5c96cc8f


Then just added a script to the `package.json` to call `hugo-algolia`:

```json
  "scripts": {
    "index": "hugo-algolia"
  },
```

This just avoid me from calling directly
`./node_modules/hugo-algolia/bin/index.js`

=> ecceca1f95f2ebd4ef3af5dae60ee460a444886d

HOWEVER this doesn't work out of the box :

```
$ npm run index
```
```
> @ index /home/horgix/work/blog
> hugo-algolia

fs.js:646
  return binding.open(pathModule._makeLong(path), stringToFlags(flags), mode);
                 ^

Error: ENOENT: no such file or directory, open './config.yaml'
    at Object.fs.openSync (fs.js:646:18)
    at Object.fs.readFileSync (fs.js:551:33)
    at Function.matter.read (/home/horgix/work/blog/node_modules/gray-matter/index.js:161:16)
    at HugoAlgolia.HugoAlgolia.setCredentials (/home/horgix/work/blog/node_modules/hugo-algolia/lib/index.js:86:31)
    at HugoAlgolia.HugoAlgolia.index (/home/horgix/work/blog/node_modules/hugo-algolia/lib/index.js:100:10)
    at Object.<anonymous> (/home/horgix/work/blog/node_modules/hugo-algolia/bin/index.js:23:26)
    at Module._compile (module.js:635:30)
    at Object.Module._extensions..js (module.js:646:10)
    at Module.load (module.js:554:32)
    at tryModuleLoad (module.js:497:12)
npm ERR! code ELIFECYCLE
npm ERR! errno 1
npm ERR! @ index: `hugo-algolia`
npm ERR! Exit status 1
npm ERR!
npm ERR! Failed at the @ index script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

npm ERR! A complete log of this run can be found in:
npm ERR!     /home/horgix/.npm/_logs/2018-03-09T17_02_08_982Z-debug.log
```

It looks like it's searching for a `config.yaml` while I have a `config.toml`

let's call `hugo-algolia` with a `--help` flag:


```
$ ./node_modules/hugo-algolia/bin/index.js --help
```
```
  Usage: index [options]

  Options:

    -V, --version                   output the version number
    -i, --input [value]             Input files (default: content/**)
    -o, --output [value]            Output files (default: public/algolia.json)
    -t, --toml                      Parse with TOML
    -A, --all                       Turn off "other" category
    -s, --send                      Send to Algolia
    -m, --multiple-indices [value]  Multiple categories
    -p, --custom-index              Custom index
    --config [value]                Config file (default: ./config.yaml)
    -c, --content-size [value]      Content size to send to Algolia (default: 5Kb)
    -h, --help                      output usage information
```

Yay, we have a `--config` flag!


Change this in package.json:

```json
  "scripts": {
    "index": "hugo-algolia --config config.toml"
  },
```

=> 4a64fa747d73dd088aa4aac9efc27005abf6a2ec


run it:

```
$ npm run index
```
```
> @ index /home/horgix/work/blog
> hugo-algolia --config config.toml

JSON index file was created in public/algolia.json
```

Check:

```
$ cat public/algolia.json
```
```json
[]
```

Hmm... maybe the `--toml` flag is needed in order to parse the toml config or
the toml front-matter?

```json
  "scripts": {
    "index": "hugo-algolia --config config.toml --toml"
  },
```

=> 7007b094570e8d7fa60601c8d28698722b63198c


re-run index:

```
$ npm run index
```
```
> @ index /home/horgix/work/blog
> hugo-algolia --config config.toml --toml

JSON index file was created in public/algolia.json
```

```
$ wc -l public/algolia.json
```
```
258 public/algolia.json
```

Looks like it worked

Example object in this `algolia.json`:

```json
    {
        "title": "Latency: from a dream to nightmare in 100ms",
        "uri": "meetups/perf-ug_2016-04-26",
        "content": "Meetup Performance User group  31 28 avril 2016 Latency  dream nightmare 100ms   OCTO Technologies  It s network   reflex every software engineer  often right  Internet alive think  when applications online work unpredictable latency  optimise it  operating Algolia s servers 38 different datacenters around world  across various head scratching events we ll share interesting ones  Adam Surak DevOps   Security engineer  algolia Intro perfug github io Next 19 mai  3e anniversaire   adam surak algolia com  AdamSurak Algolia     Split racks avoid failure     increase latency 1ms latency 2 racks   speed light    300km Now  talk Internet   New York Paris i e  AWS multiple regions  us east vs europe     39ms   speed light reality  85ms 2 randoms points earth  maximum expected latency 133ms take  reality  Paris Sidney    322ms   Fiber not going shortest path  devices middle things  etc   millisecondsmatter   search type longer takes  impact business  100ms   1  revenue Amazon estimate Algolia   replication 3 independant servers 3 differents DCs needed    primary cluster 3 close serveurs  short latency  1ms   when communicate differents zones    100  200ms   master slave clusters  API stats 3x replication 15 regions 35  DCs 1900  network links monitored servers 400  servers 12B  search queries per month 20B  write operations per month Internet Doesn t optimise latency Doesn t follow geography Likes airports Bandwidth priority Latency via CDN    cache assets close customers possible    can t when every request different  APIs  Private low latency backbones   Trading  Google  Riot Games      Trading   ms   deal not Google  2ms  no DC France   Dedicated networks DCs Riot Games   real time game  Started buy fiber US build own network  Going close users possible best network possible Internet follows politics money Ex  Paris Singapore  10 741km  Test Adam  from office Singapore    18 hops  Interesting highlights   th2  DC Paris   paris  paris  marseille  mumbai  mumbai  chennai  singapore  singapore 160ms Paris Mumbai Test DC Paris   13 hops  path completely different   amstn102  amstn102   amsterdam   asbnva02  east coast US   snjsca04  Singapore   etc    257ms  100ms Paris     Airports Internet locations coded using IATA codes Paris    CDG New York    JFK LGA Washington DC   DCA Ashburn   IAD  heart Internet know it  Los Angeles   LAX try trace something hosted CDNs   usually names using airports acronyms production  having say hosters  hey  not really best effort network  Servers Tokyo Osaka provider 8ms average latency Suddenly  alert  Latency inside cluster    10ms  New latency   110ms  Wtf    Osaka Tokyo didn t move so something probably happened   D Traceroute Osaka Tokyo   6 hops  4hops Tokyo  10gps   Providers go Osaka Tokyo around world  they ll say  hey no problem      so took look Tokyo Osaka  Tokyo  tokyo  Los Angeles  LA  LA  Osaka  Osaka  OK Provider   no dedicated link its 2 DCs  using network provider  same Internet  Tokyo    San Jose    Osaka    Tokyo email provider  not ok   uh   impact   100ms           6h after  not resolved   creative director  handling  etc  When network engineer answered  2minutes fixed  None monitoring it  customers didn t care using DCs connect Internet  no directly DC example  OK  US   West coast ervers San Josa Customer Oregon AWS US West 2 21ms average latency Bouncing around whole west coast  San jose  boardman  seattle  back san jose 21ms 150 300ms Screenshot newrelic   everything work until doesn t least monitoring it  fix took lot time    new route via Denver 20  packet loss seattle denver      issue AWS network No timeout systems TCP retries    consequence   long latency aws  you problem    nope   ok     that s amazon ping pong Amazon Crazy idea   start proxy new DC deployed AWS Availability Zones    AWS ISP edge    ISP1 edge    Algolia ISP1 nothing solved it   ok move US west US east   Yeah ok   hahaha Nice customers  accepting move backend AWS ISP edge breaks so even didn t solve Nothing until Amazon calls its provider fix    Router fixed  connection improved  etc Now    east coast  heart Internet   Servers ashburn area 2 different providers First region  biggest region AWS majority networks data cluster spreads  different providers  so avoid issues  everything gonna ok  D    1 provider   2ms AWS  provider   8ms Factor 4 latency place one pattern  investigation trace again    DC    AWS   ashburn  ashburn       ok  ok       destination  everything ok   AWS    DC   aws  aws  aws  etc     Washington DC  DC  DC  JFK  New York   JFK  JFK  etc  DCA  back Ashburn    Ashburn  Washington DC  New York  Wahington DC  Ashburn  Bounce nothing   No one cares  So  hey guys not ok  Cogent    it s side AWS  AWS    it s side Cogent  convinced not side Escalated  network teams didn t care AWS    can please explain us why 6ms matters business impact   application   Why care    Internal procedure    needs justified something change traceroute it s inside AWS network jumps 8ms inside AWS network Took     8 months resolve  Problem inside Amazon network  side Networks mutual agreement  hasn t symetric Looking g",
        "objectID": "meetups/perf-ug_2016-04-26",
        "meetupevent": {
            "group": "PerfUG",
            "id": "230324443"
        }
    },
```

Cool things:

- It also take the metadate from the front-matter (in this case the meetup
  infos)

Less cool things:

- In my french article it looks like it stripped the accents
- The entire content is not there

The "entire content not here" is probably controlled by this settings we saw
earlier in the `--help`:

```
    -c, --content-size [value]      Content size to send to Algolia (default: 5Kb)
```

We'll play with this later.

