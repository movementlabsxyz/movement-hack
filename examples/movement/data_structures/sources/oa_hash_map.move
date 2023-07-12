// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// An open addressing hash map with linear probing
module ds_std::oa_hash_map {
    use std::option::{Self, Option};
    use std::vector;
    use std::bcs;
    use std::hash::sha2_256;

    use ds_std::from_bytes;

    /// This key already exists in the map
    const ENO_KEY_ALREADY_EXISTS: u64 = 0;

    /// This key does not exist in the map
    const ENO_KEY_DOES_NOT_EXIST: u64 = 1;

    /// Trying to access an element of the map at an invalid index
    const ENO_INDEX_OUT_OF_BOUNDS: u64 = 2;

    const ENO_BUFFER_EXHAUSTED : u64 = 3;

    struct OaHashMap<K, V> has copy, drop, store {
        size: u64,
        entries: vector<Option<Entry<K, V>>>,
        dummy : Option<Entry<K, V>>
    }

    /// An entry in the map
    struct Entry<K, V> has copy, drop, store {
        key: K,
        value: V,
    }

    public fun get_key<K, V>(entry: &Entry<K, V>):  &K {
        &entry.key
    }

    public fun get_value<K, V>(entry: &Entry<K, V>): &V {
        &entry.value
    }

    /// Create an empty `OaHashMap`
    public fun new<K, V>(size: u64): OaHashMap<K,V> {
        let entries = vector::empty<Option<Entry<K, V>>>();
        let i = 0;
        while (i < size) {
          vector::push_back(&mut entries, option::none());
          i = i + 1;
        };
        OaHashMap { 
          entries,
          size,
          dummy : option::none()
        }
    }
    
    /// Calculate `hash` index from given `key`
    public fun compute_hash_index<K>(key: &K, size: u64): u64 {
        let bytes = bcs::to_bytes(key);
        let hash_bytes = sha2_256(bytes); 
        from_bytes::read_u64(&hash_bytes) % size
    }

    public fun key_equals<K>(key1: &K, key2: &K) : bool {
        let bytes1 = bcs::to_bytes(key1);
        let bytes2 = bcs::to_bytes(key2);
        bytes1 == bytes2
    }

    public fun find<K, V>(map: &OaHashMap<K, V>, key: &K) : &Option<Entry<K, V>> {
        
        let index = compute_hash_index(key, map.size);
        let count = 0;
        loop {
            let option_value = vector::borrow(&map.entries, index % map.size);
            if (option::is_none(option_value)) {
                return option_value
            } else {
                let entry = option::borrow(option_value);
                if (key_equals(&entry.key, key)) {
                    return option_value
                }
            };
            index = index + 1;
            count = count + 1;
            if (count > map.size) {
                abort ENO_BUFFER_EXHAUSTED
            }
        }

    }

    fun find_mut<K, V>(map: &mut OaHashMap<K, V>, key: &K) : &mut Option<Entry<K, V>> {
        
        let index = compute_hash_index(key, map.size);
        let count = 0;
        loop {
            let option_value = vector::borrow_mut(&mut map.entries, index % map.size);
            if (option::is_none(option_value)) {
                return option_value
            } else {
                let entry = option::borrow(option_value);
                if (key_equals(&entry.key, key)) {
                    return option_value
                }
            };
            index = index + 1;
            count = count + 1;
            if (count > map.size) {
                abort ENO_BUFFER_EXHAUSTED
            }
        }

    }

    /// Remove the entry `key` |-> `value` from `map`. Aborts if related `value` is not found in `map`.
    public fun remove<K, V>(map: &mut OaHashMap<K, V>, key: &K): Option<Entry<K, V>> {

        // TODO: remove the comment below
        // NOTE: now we don't check whether the map contains the key
        // assert!(contains<K, V>(map, key), ENO_KEY_DOES_NOT_EXIST);
        
        let option_value = find_mut(map, key);
        if (option::is_none(option_value)) {
            option::none()
        } else {
            let entry = option::extract(option_value); // this converts the option to none
            option::some(entry)
        }

    }

    /// Insert a new key/value pair to `map` by removing any previous entry with the same key.
    /// Returns the previous entry.
    public fun set<K, V>(map: &mut OaHashMap<K, V>, key: K, value: V) : Option<Entry<K, V>> {

        // TODO: remove the comment below
        // NOTE: now we don't check whether the map contains the key
        // assert!(!contains<K, V>(map, &key), ENO_KEY_ALREADY_EXISTS); 

        let old = remove(map, &key);
        let option_value = find_mut(map, &key);
        option::fill(option_value, new_entry(key, value));
        old

    }

    /// Get a copy of an entry from the hash map
    public fun get<K, V>(map: &OaHashMap<K, V>, key: &K) : &Option<Entry<K, V>> {

        // TODO: remove the comment below
        // NOTE: now we don't check whether the map contains the key
        // assert!(contains<K, V>(map, key), ENO_KEY_DOES_NOT_EXIST);

        let option_value = find(map, key);

        // Getting is a little different from finding.
        // If the key is not in the map,
        // we don't just want to return the next slot.
        // Instead we'll return none.
        if (option::is_none(option_value)) {
            &map.dummy
        } else {
            option_value
        }

    }

    /// Get a copy of an entry from the hash map
    public fun get_copy<K : copy, V : copy>(map: &OaHashMap<K, V>, key: &K) : Option<Entry<K, V>> {

        // TODO: remove the comment below
        // NOTE: now we don't check whether the map contains the key
        // assert!(contains<K, V>(map, key), ENO_KEY_DOES_NOT_EXIST);

        let option_value = find(map, key);

        // Getting is a little different from finding.
        // If the key is not in the map,
        // we don't just want to return the next slot.
        // Instead we'll return none.
        if (option::is_none(option_value)) {
            option::none()
        } else {
            *option_value
        }

    }

    public fun borrow<K, V>(map: &OaHashMap<K, V>, key: &K) : &V {
        let option_value = find(map, key);
        if (option::is_none(option_value)) {
            abort ENO_KEY_DOES_NOT_EXIST
        } else {
            let entry = option::borrow(option_value);
            &entry.value
        }
    }

    public fun borrow_mut<K, V>(map: &mut OaHashMap<K, V>, key: &K) : &mut V {
        let option_value = find_mut(map, key);
        if (option::is_none(option_value)) {
            abort ENO_KEY_DOES_NOT_EXIST
        } else {
            let entry = option::borrow_mut(option_value);
            &mut entry.value
        }
    }

    /// Return true if `map` contains an entry for `key`, false otherwise
    public fun contains<K, V>(map: &OaHashMap<K, V>, key: &K): bool {
        let option_val = find(map, key);
        !option::is_none(option_val)
    }

    /// Return a new entry with given key and value
    fun new_entry<K, V>(key: K, value: V): Entry<K, V> {
        Entry {
            key,
            value
        }
    }

    /// Return item counts in hash_map
    public fun length<K, V>(map: &OaHashMap<K, V>): u64 {
        let i = 0;
        let count = 0;
        while (i < map.size) {
            let v = vector::borrow(&map.entries, i);
            if (option::is_some(v)) count = count + 1;
            i = i + 1;
        };
        count
    }

    public fun iter_next<K, V>(map: &OaHashMap<K, V>, index: u64) : (u64, &Option<Entry<K, V>>) {
        
        let i = index;
        while (i < map.size) {
            let v = vector::borrow(&map.entries, i);
            if (option::is_some(v)) {
                return (i + 1, v)
            };
            i = i + 1;
        };
        (i + 1, &map.dummy)

    }

    public fun iter_next_mut<K, V>(map: &mut OaHashMap<K, V>, index: u64) : (u64, &Option<Entry<K, V>>) {
        
        let i = index;
        while (i < map.size) {
            let v = vector::borrow_mut(&mut map.entries, i);
            if (option::is_some(v)) {
                return (i + 1, v)
            };
            i = i + 1;
        };
        (i + 1, &map.dummy)

    }

    #[test]
    fun test_set() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        set(&mut map, key, value);
        let at_1 = borrow(&map, &1);
        assert!(*at_1 == value, 99);

    }

    #[test]
    fun test_set_get() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        set(&mut map, key, value);
        let at_1 = borrow(&map, &1);
        assert!(*at_1 == value, 99);
        let option1 = get_copy(&map, &1);
        assert!(option::is_some(&option1), 99);
        let entry1 = option::borrow(&option1);
        assert!(entry1.key == key, 99);
        assert!(entry1.value == value, 99);

    }

    #[test]
    fun test_can_get_empty() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        set(&mut map, key, value);
        let at_1 = borrow(&map, &1);
        assert!(*at_1 == value, 99);
        let option1 = get(&map, &1);
        assert!(option::is_some(option1), 99);
        let entry1 = option::borrow(option1);
        assert!(entry1.key == key, 99);
        assert!(entry1.value == value, 99);

        let option2 = get(&map, &2);
        assert!(option::is_none(option2), 99);

    }

    #[test]
    fun test_can_get_copy_empty() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        set(&mut map, key, value);
        let at_1 = borrow(&map, &1);
        assert!(*at_1 == value, 99);
        let option1 = get_copy(&map, &1);
        assert!(option::is_some(&option1), 99);
        let entry1 = option::borrow(&option1);
        assert!(entry1.key == key, 99);
        assert!(entry1.value == value, 99);

        let option2 = get_copy(&map, &2);
        assert!(option::is_none(&option2), 99);

    }

    #[test]
    #[expected_failure(abort_code = ENO_KEY_DOES_NOT_EXIST)]
    fun cannot_borrow_empty() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        set(&mut map, key, value);
        let _ = borrow(&map, &2);
        
    }

    #[test]
    fun test_double_set() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        set(&mut map, key, value);
        let at_1 = borrow(&map, &1);
        assert!(*at_1 == value, 99);

        let value2 : u8 = 43;
        set(&mut map, key, value2);
        let at_1_2 = borrow(&map, &1);
        assert!(*at_1_2 == value2, 99);

    }

    #[testonly]
    struct TestStruct has drop {
        x: u8,
        y: u8,
    }

    #[test]
    fun test_set_mutate() {
        
        let key : u8 = 1;
        let x = 42;
        let y = 43;
        let value : TestStruct = TestStruct { x: x, y: y };
        let map = new<u8, TestStruct>(1000);
        set(&mut map, key, value);
        
        let at_1 = borrow(&map, &1);
        assert!(at_1.x == x, 99);
        assert!(at_1.y == y, 99);
        
        let at_1_mut = borrow_mut(&mut map, &1);
        let new_x  = 44;
        let new_y = 45;
        at_1_mut.x = new_x;
        at_1_mut.y = new_y;

        let at_1_2 = borrow(&map, &1);
        assert!(at_1_2.x == new_x, 99);
        assert!(at_1_2.y == new_y, 99);


    }

    #[test]
    fun test_lots_of_sets_and_gets() {
        
        let map = new<u64, u64>(10000);
        let i = 0;
        while (i < 1000){
            let key : u64 = i;
            let value : u64 = i+1;
            set(&mut map, key, value);
            let at_key = borrow(&map, &key);
            assert!(*at_key == value, 99);
            i = i + 1;
        }


    }

    #[test_only]
    struct DataWrapper has drop {
        len: u64,
        data: vector<u8>
    }

    #[test_only]
    struct Location has drop {
        addr: address,
        rev: u64
    }

    #[test]
    fun test_length() {
        let map = new<Location, DataWrapper>(1000);
        let k = Location { addr: @0x1, rev: 0 };
        let v = DataWrapper { len: 0, data: vector::empty() };
        set(&mut map, k, v);
        assert!(length(&map) == 1, 0);
        /*let (key, value) = remove(&mut map, &Location { addr: @0x1, rev: 0 });
        assert!(&key == &Location { addr: @0x1, rev: 0 }, 1);
        assert!(&value == &DataWrapper { len: 0, data: vector::empty() }, 2);*/
    }

}
