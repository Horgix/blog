+++
type = "post"
author = "Author"
date = "2017-03-03"
title = "How I integrated Algolia search into my Hugo blog - Part 1"
description = "Indexing articles content into Algolia"
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

Looks like it worked!

Example object in this `algolia.json`:

{{< gist Horgix cbb4aba84bbae9ce30b4471fe3d37310 >}}

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

# Uploading the JSON to Alglia

As you might have seen in the `--help`, there is a `-s / --send` option that
sends the JSON previously built to Algolia.

let's add this to our `package.json`:

=> e4b09b8b859a255b395ccbacaeebb391ddc94b1d

Of course if we don't provide any information about our Algolia access, it
plainly fails:

```
└#master> npm run index-and-send

> @ index-and-send /home/horgix/work/blog
> hugo-algolia --config config.toml --toml -s

JSON index file was created in public/algolia.json

/home/horgix/work/blog/node_modules/algoliasearch/src/AlgoliaSearchCore.js:50
    throw new errors.AlgoliaSearchError('Please provide an application ID. ' + usage);
    ^
AlgoliaSearchError: Please provide an application ID. Usage: algoliasearch(applicationID, apiKey, opts)
    at AlgoliaSearchNodeJS.AlgoliaSearchCore (/home/horgix/work/blog/node_modules/algoliasearch/src/AlgoliaSearchCore.js:50:11)
    at AlgoliaSearchNodeJS.AlgoliaSearch (/home/horgix/work/blog/node_modules/algoliasearch/src/AlgoliaSearch.js:11:21)
    at AlgoliaSearchNodeJS.AlgoliaSearchServer (/home/horgix/work/blog/node_modules/algoliasearch/src/server/builds/AlgoliaSearchServer.js:17:17)
    at new AlgoliaSearchNodeJS (/home/horgix/work/blog/node_modules/algoliasearch/src/server/builds/node.js:79:23)
    at algoliasearch (/home/horgix/work/blog/node_modules/algoliasearch/src/server/builds/node.js:68:10)
    at HugoAlgolia.HugoAlgolia.sendIndex (/home/horgix/work/blog/node_modules/hugo-algolia/lib/index.js:184:20)
    at HugoAlgolia.HugoAlgolia.index (/home/horgix/work/blog/node_modules/hugo-algolia/lib/index.js:122:12)
    at Object.<anonymous> (/home/horgix/work/blog/node_modules/hugo-algolia/bin/index.js:23:26)
    at Module._compile (module.js:635:30)
    at Object.Module._extensions..js (module.js:646:10)
npm ERR! code ELIFECYCLE
npm ERR! errno 1
npm ERR! @ index-and-send: `hugo-algolia --config config.toml --toml -s`
npm ERR! Exit status 1
npm ERR!
npm ERR! Failed at the @ index-and-send script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

npm ERR! A complete log of this run can be found in:
npm ERR!     /home/horgix/.npm/_logs/2018-03-12T11_17_56_845Z-debug.log
```

Add Algolia screenshots here!


Add screenshots of API key gen too

So now that we have all the informations about our Algolia application, let's
pass it to hugo-algolia for sending:

We could add this to `config.toml` acccording to hugo-algolia documentation:

```
[algolia]
  index = "index-name"
  key = "[your API key]"
  appID = "[your app id]"
```

But we really don't want to write the secret key to the file and thus to the
public git repository... Luckily, we can export it in the environment under the
name `ALGOLIA_WRITE_KEY` and hugo-algolia will take it from here!


# Surprise bug

So, after defining this in the `config.toml`

0502f32c846c43590ee0635a1c968c3f60b9946c

and exporting the `ALGOLIA_WRITE_KEY` env var, it still fails with the same
error about appID...

After a bit of investigation, the problem lies in hugo-algolia:

In `node_modules/hugo-algolia/lib/index.js`the credentials are parsed with:

```
const configmeta = matter.read(self.pathtocredentials);
```

And this doesn't handle toml! We can see it later in the file when parsing
(correctly) the front matter:

```
    const meta = matter.read(filePath, {
      language: self.language,
      delims: self.delims,
      engines: {
        toml: toml.parse.bind(toml)
      }
    });
```

Ok so let's update the index.js of hugo-algolia accordingly

Oh hey open source:
https://github.com/10Dimensional/hugo-algolia/pull/11

This still doesn't work. Because our config.toml generated by Hugo doesn't have
any TOML delimiter `+++` and gray-matter is looking for it!

ccdd4abe96bf2e803161d825e76735ed25c1a43b


Ok good, try again...

```
(node:25948) UnhandledPromiseRejectionWarning: Unhandled promise rejection (rejection id: 2): AlgoliaSearchError: Index does not exist
(node:25948) [DEP0018] DeprecationWarning: Unhandled promise rejections are deprecated. In the future, promise rejections that are not handled will terminate the Node.js process with a non-zero exit code.
{ updatedAt: '2018-05-13T01:57:32.423Z', taskID: 973108002 }
```

Fails to... `Search`! because we narrowed the scope of the API token too much
it seems. Add `Search` scope to permissinos (todo screenshot)

Try again:

```
$ npm run index-and-send

> @ index-and-send /home/horgix/work/blog
> hugo-algolia --config config.toml --toml -s

JSON index file was created in public/algolia.json
{ updatedAt: '2018-05-13T02:10:15.693Z', taskID: 7726512471 }
```

YAY

https://github.com/10Dimensional/hugo-algolia/pull/12


https://www.algolia.com/doc/guides/indexing/structuring-your-data/#indexing-long-documents

Ending note:

https://github.com/duckpuppy/algolia-hugo
https://discourse.gohugo.io/t/keeping-algolia-up-to-date-automatically/8317
https://discourse.gohugo.io/t/python-script-for-creating-a-json-page-index-file-for-algolia-docsearch/3594
https://www.npmjs.com/package/atomic-algolia
https://forestry.io/blog/search-with-algolia-in-hugo/

