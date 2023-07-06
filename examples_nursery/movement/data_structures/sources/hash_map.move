// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::hash_map {
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

    struct HashMap<K, V> has copy, drop, store {
        size: u64,
        entries: vector<Option<Entry<K, V>>>,
    }

    /// An entry in the map
    struct Entry<K, V> has copy, drop, store {
        key: K,
        value: V,
    }

    /// Create an empty `HashMap`
    public fun new<K, V>(size: u64): HashMap<K,V> {
        let entries = vector::empty<Option<Entry<K, V>>>();
        let i = 0;
        while (i < size) {
          vector::push_back(&mut entries, option::none());
          i = i + 1;
        };
        HashMap { 
          entries,
          size
        }
    }
    
    /// Calculate `hash` index from given `key`
    public fun get_index<K>(key: &K, size: u64): u64 {
        let bytes = bcs::to_bytes(key);
        let hash_bytes = sha2_256(bytes); 
        from_bytes::read_u64(&hash_bytes) % size
    }

    /// Insert a new key/value pair to `map`
    public fun insert<K, V>(map: &mut HashMap<K, V>, key: K, value: V) {
        let index = get_index<K>(&key, map.size);
        assert!(!contains<K, V>(map, &key), ENO_KEY_ALREADY_EXISTS);
        let non_value = vector::borrow_mut(&mut map.entries, index);
        option::fill(non_value, new_entry(key, value));
    }

    /// Remove the entry `key` |-> `value` from `map`. Aborts if related `value` is not found in `map`.
    public fun remove<K, V>(map: &mut HashMap<K, V>, key: &K): (K, V) {
        let index = get_index<K>(key, map.size);
        assert!(contains<K, V>(map, key), ENO_KEY_DOES_NOT_EXIST);
        
        let option_value = vector::borrow_mut(&mut map.entries, index);
        let Entry { key: key, value } = option::extract(option_value);
        (key, value)
    }

    /// Get a reference to the value bound to `key` in `map`.
    public fun get<K, V>(map: &HashMap<K, V>, key: &K): (&K, &V) {
        let index = get_index<K>(key, map.size);
        assert!(contains<K, V>(map, key), ENO_KEY_DOES_NOT_EXIST);
        let option_value = vector::borrow(&map.entries, index);
        let Entry { key: r_key, value: r_value } = option::borrow(option_value);
        (r_key, r_value)
    }

    /// Return true if `map` contains an entry for `key`, false otherwise
    public fun contains<K, V>(map: &HashMap<K, V>, key: &K): bool {
        let index = get_index<K>(key, map.size);
        assert!(index < map.size, ENO_INDEX_OUT_OF_BOUNDS);
       !option::is_none(vector::borrow(&map.entries, index))
    }

    /// Unpack `map` into vectors of its keys and values.
    /// The output keys and values are stored in arbitrary order, *not* in insertion order.
    public fun into_keys_values<K, V>(map: HashMap<K, V>): (vector<K>, vector<V>) {
        let HashMap { entries, size } = map;

        let i = 0;
        let keys = vector::empty();
        let values = vector::empty();
        while (i < size) {
            let v = vector::pop_back(&mut entries);
            if (option::is_some(&v)) {
                let Entry { key, value } = option::extract(&mut v);
                vector::push_back(&mut keys, key);
                vector::push_back(&mut values, value);
            };
            option::destroy_none(v);
            i = i + 1;
        };
        vector::destroy_empty(entries);
        (keys, values)
    }

    /// Returns a list of keys in the map.
    /// Do not assume any particular ordering.
    public fun keys<K: copy, V>(map: &HashMap<K, V>): vector<K> {
        let i = 0;
        let keys = vector::empty();
        while (i < map.size) {
            let option_entry = vector::borrow(&map.entries, i);
            if (option::is_some(option_entry)) {
                vector::push_back(&mut keys, option::borrow(option_entry).key);
            };
            i = i + 1;
        };
        keys
    }

    /// Returns a list of values in the map.
    /// Do not assume any particular ordering.
    public fun values<K: copy, V: copy>(map: &HashMap<K, V>): vector<V> {
        let i = 0;
        let values = vector::empty();
        while (i < map.size) {
            let option_entry = vector::borrow(&map.entries, i);
            if (option::is_some(option_entry)) {
                vector::push_back(&mut values, option::borrow(option_entry).value);
            };
            i = i + 1;
        };
        values
    }

    /// Return a new entry with given key and value
    public fun new_entry<K, V>(key: K, value: V): Entry<K, V> {
        Entry {
            key,
            value
        }
    }

    #[test]
    fun test_get_index(){

        let key : u8 = 1;
        let index = get_index(&key, 1000);
        let index2 = get_index(&key, 1000);
        assert!(index == index2, 99);

    }

     #[test]
    fun test_insert() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        insert(&mut map, key, value);
        let (_, at_1) = get(&map, &1);
        assert!(*at_1 == value, 99);

    }

    #[test]
    #[expected_failure(abort_code = ENO_KEY_ALREADY_EXISTS)]
    fun test_double_insert() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        insert(&mut map, key, value);
        let (_, at_1) = get(&map, &1);
        assert!(*at_1 == value, 99);
        insert(&mut map, key, value);

    }

    #[test]
    fun test_remove() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        insert(&mut map, key, value);
        let (_, at_1) = get(&map, &1);
        assert!(*at_1 == value, 99);
        let (k1, v1) = remove(&mut map, &1);
        assert!(k1 == key, 99);
        assert!(v1 == value, 99);

    }

    #[test]
    #[expected_failure(abort_code = ENO_KEY_DOES_NOT_EXIST)]
    fun test_remove_and_get() {
        
        let key : u8 = 1;
        let value : u8 = 42;
        let map = new<u8, u8>(1000);
        insert(&mut map, key, value);
        let (_, at_1) = get(&map, &1);
        assert!(*at_1 == value, 99);
        let (k1, v1) = remove(&mut map, &1);
        assert!(k1 == key, 99);
        assert!(v1 == value, 99);
        let (_, _) = get(&map, &1);

    }

}
