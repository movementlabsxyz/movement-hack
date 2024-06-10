# Hello, Move

If you've installed Movement CLI, congratulations!

If not, please [return to the previous lesson](ch02-02-install-movement-cli.md) and install Movement CLI.

Now that you have Movement CLI installed, it's time to deploy something to Movement. Ideally and end-to-end (E2E) dApp.

If you'd prefer to build up your confidence first, it's fine to deploy a simple module. Just [follow this guide](https://docs.movementlabs.xyz/developers/tutorials/deploy/aptos-module). It doesn't require any coding experience.

An E2E dApp is just an on-chain module or modules paired with a front end like a Next.js or Vite app. So it's not too much more complicated than deploying a module.

In this lesson, you'll build a simple dApp that allows users to post messages to a chat room.

Just like in the module deployment guide, you don't need any coding experience to deploy this dApp. You only have to be able to follow ste-by-step directions 👍🏼

Try the app [here](https://main.d2761w90g9sxb3.amplifyapp.com/).

## Requirements

Install Movement CLI:

```bash
<(curl -fsSL https://raw.githubusercontent.com/movemntdev/M1/main/scripts/install.sh) --latest
```

Clone the dApp repository:

```bash
git clone https://github.com/movementlabsxyz/movement-dapp-workshop/
cd movement-dapp-workshop
```

## Building the Chat dApp

This dApp is built using the Aptos Move language. The dApp is located in the aptos directory. Once inside the repository, navigate to the aptos directory:

```bash
cd aptos
```

## Publish Module

Aptos language requires you to initialize the Move environment:

```bash
movement aptos init
```

Then you can publish the module:

```bash
movement aptos move publish --named-addresses chat_addr=default
```

## Test Front End

To test the front end, navigate to the frontend directory and run the following command to start the front end server.

```bash
npm i && npm run dev
```

You will be able to see your frontend at <http://localhost:3000>.

Take a look at `aptos/frontend/components/Chat.tsx`. This file contains the logic for the chat room. The Chat component is responsible for fetching the chat messages, displaying them and posting new messages to the chat room.

In line 21, replace the address after `{ "address":`  with the address of the `chat_addr` you published:

```bash
const abi = { "address": "0xYOUR_ADDRESS", (...)}"
```

Make sure the address starts with `0x` else add it. That should be available in `.aptos/config.yaml` file as the `account` field.

Now you can try running your transactions on the frontend and see the chat messages being posted.

## Chapter Quiz: Check your knowledge and earn rewards

<iframe data-tally-src="https://tally.so/embed/3XDkBL?alignLeft=1&hideTitle=1&transparentBackground=1&dynamicHeight=1" loading="lazy" width="100%" height="418" frameborder="0" marginheight="0" marginwidth="0" title="Movement Hack Chapter 2 Quiz"></iframe><script>var d=document,w="https://tally.so/widgets/embed.js",v=function(){"undefined"!=typeof Tally?Tally.loadEmbeds():d.querySelectorAll("iframe[data-tally-src]:not([src])").forEach((function(e){e.src=e.dataset.tallySrc}))};if("undefined"!=typeof Tally)v();else if(d.querySelector('script[src="'+w+'"]')==null){var s=d.createElement("script");s.src=w,s.onload=v,s.onerror=v,d.body.appendChild(s);}</script>
