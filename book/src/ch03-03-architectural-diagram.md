# Your dApp's architectural diagram

To create a diagram of Move Chat, start by looking at the types and functions specified in the module code:

```rust
    struct ChatRoom has key, store {
        messages: vector<Message>,
        message_count: u64,
    }

    struct Message has key, store, copy {
        sender: address,
        // Post's text.
        text: vector<u8>,
        // Post's timestamp.
        timestamp: u64,
        // Set if referencing an another object (i.e., due to a Like, Retweet, Reply etc).
        // We allow referencing any object type, not only Message NFTs.
        ref_id: Option<address>,
        // app-specific metadata. We do not enforce a metadata format and delegate this to app layer.
        metadata: vector<u8>,
    }

    fun init_module(account: &signer) {
        let room = ChatRoom {
            messages: vector::empty(),
            message_count: 0,
        };
        move_to<ChatRoom>(account, room);
    }

    /// Create a new chat room.
    public entry fun create_chat_room(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<ChatRoom>(addr), E_CHAT_ROOM_EXISTS);
        let room = ChatRoom {
            messages: vector::empty(),
            message_count: 0,
        };
        move_to(account, room);
    }

    /// Simple Message object getter.
    #[view]
    public fun get_messages(addr: address) : vector<Message> acquires ChatRoom {
        let room = borrow_global<ChatRoom>(addr);
        room.messages
    }
```

There are three main types: `ChatRoom`, `Message` and a `&signer` (`account`).

They can be represented in the following way:

![The chat dApp's init module function diagram](./img/ch03-01-diagram-chatroom-init-module.png "Diagram: The chat dApp's init module function")

`init_module` is a function that gets called once, when the module is first deployed.

`init_module` takes in a reference to a `signer` then creates a new `ChatRoom` object and moves it to the signer's account address.

Here's one way to represent that with a diagram:

![The chat dApp's init module function diagram](./img/ch03-01-diagram-chatroom-init-module.png "Diagram: The chat dApp's init module function")

In the above diagram, an asterisk (*) represents creating a new instance of some type.

The angle bracket (>) represents moving a resource to an account.

* **Step 0:** The wallet (`account`) calls the `init_module` function
* **Step 1:** `init_module` creates a new `ChatRoom` resource
* **Step 2:** The `ChatRoom` resource is moved to `account`.

## Chapter quiz: Submit user journey and architecture diagram for your dApp

<iframe data-tally-src="https://tally.so/embed/3qd7DY?alignLeft=1&hideTitle=1&transparentBackground=1&dynamicHeight=1" loading="lazy" width="100%" height="273" frameborder="0" marginheight="0" marginwidth="0" title="Movement Hack Chapter 3 Quiz"></iframe><script>var d=document,w="https://tally.so/widgets/embed.js",v=function(){"undefined"!=typeof Tally?Tally.loadEmbeds():d.querySelectorAll("iframe[data-tally-src]:not([src])").forEach((function(e){e.src=e.dataset.tallySrc}))};if("undefined"!=typeof Tally)v();else if(d.querySelector('script[src="'+w+'"]')==null){var s=d.createElement("script");s.src=w,s.onload=v,s.onerror=v,d.body.appendChild(s);}</script>
