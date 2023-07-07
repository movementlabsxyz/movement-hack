// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::std_map {
    use std::option::{Self, Option};
    use std::vector;

    /// This key already exists in the map
    const EKeyAlreadyExists: u64 = 0;

    /// This key does not exist in the map
    const EKeyDoesNotExist: u64 = 1;

    /// Trying to destroy a map that is not empty
    const EMapNotEmpty: u64 = 2;

    /// Trying to access an element of the map at an invalid index
    const EIndexOutOfBounds: u64 = 3;

    /// Trying to pop from a map that is empty
    const EMapEmpty: u64 = 4;

    struct Map<K: copy, V> has copy, drop, store {
        entries: vector<Entry<K, V>>,
    }

    /// An entry in the map
    struct Entry<K: copy, V> has copy, drop, store {
        key: K,
        value: V,
    }

    /// Create an empty `Map`
    public fun empty<K: copy, V>(): Map<K,V> {
        Map { entries: vector::empty() }
    }

    /// Insert the entry `key` |-> `value` into `self`.
    /// Aborts if `key` is already bound in `self`.
    public fun insert<K: copy, V>(self: &mut Map<K,V>, key: K, value: V) {
        assert!(!contains(self, &key), EKeyAlreadyExists);
        vector::push_back(&mut self.entries, Entry { key, value })
    }

    /// Remove the entry `key` |-> `value` from self. Aborts if `key` is not bound in `self`.
    public fun remove<K: copy, V>(self: &mut Map<K,V>, key: &K): (K, V) {
        let idx = get_idx(self, key);
        let Entry { key, value } = vector::remove(&mut self.entries, idx);
        (key, value)
    }

    /// Pop the most recently inserted entry from the map. Aborts if the map is empty.
    public fun pop<K: copy, V>(self: &mut Map<K,V>): (K, V) {
        assert!(!vector::is_empty(&self.entries), EMapEmpty);
        let Entry { key, value } = vector::pop_back(&mut self.entries);
        (key, value)
    }

    /// Get a mutable reference to the value bound to `key` in `self`.
    /// Aborts if `key` is not bound in `self`.
    public fun get_mut<K: copy, V>(self: &mut Map<K,V>, key: &K): &mut V {
        let idx = get_idx(self, key);
        let entry = vector::borrow_mut(&mut self.entries, idx);
        &mut entry.value
    }

    /// Get a reference to the value bound to `key` in `self`.
    /// Aborts if `key` is not bound in `self`.
    public fun get<K: copy, V>(self: &Map<K,V>, key: &K): &V {
        let idx = get_idx(self, key);
        let entry = vector::borrow(&self.entries, idx);
        &entry.value
    }

    /// Safely try borrow a value bound to `key` in `self`.
    /// Return Some(V) if the value exists, None otherwise.
    /// Only works for a "copyable" value as references cannot be stored in `vector`.
    public fun try_get<K: copy, V: copy>(self: &Map<K,V>, key: &K): Option<V> {
        if (contains(self, key)) {
            option::some(*get(self, key))
        } else {
            option::none()
        }
    }

    /// Return true if `self` contains an entry for `key`, false otherwise
    public fun contains<K: copy, V>(self: &Map<K, V>, key: &K): bool {
        option::is_some(&get_idx_opt(self, key))
    }

    /// Return the number of entries in `self`
    public fun size<K: copy, V>(self: &Map<K,V>): u64 {
        vector::length(&self.entries)
    }

    /// Return true if `self` has 0 elements, false otherwise
    public fun is_empty<K: copy, V>(self: &Map<K,V>): bool {
        size(self) == 0
    }

    /// Destroy an empty map. Aborts if `self` is not empty
    public fun destroy_empty<K: copy, V>(self: Map<K, V>) {
        let Map { entries } = self;
        assert!(vector::is_empty(&entries), EMapNotEmpty);
        vector::destroy_empty(entries)
    }

    /// Unpack `self` into vectors of its keys and values.
    /// The output keys and values are stored in insertion order, *not* sorted by key.
    public fun into_keys_values<K: copy, V>(self: Map<K, V>): (vector<K>, vector<V>) {
        let Map { entries } = self;
        // reverse the vector so the output keys and values will appear in insertion order
        vector::reverse(&mut entries);
        let i = 0;
        let n = vector::length(&entries);
        let keys = vector::empty();
        let values = vector::empty();
        while (i < n) {
            let Entry { key, value } = vector::pop_back(&mut entries);
            vector::push_back(&mut keys, key);
            vector::push_back(&mut values, value);
            i = i + 1;
        };
        vector::destroy_empty(entries);
        (keys, values)
    }

    /// Returns a list of keys in the map.
    /// Do not assume any particular ordering.
    public fun keys<K: copy, V>(self: &Map<K, V>): vector<K> {
        let i = 0;
        let n = vector::length(&self.entries);
        let keys = vector::empty();
        while (i < n) {
            let entry = vector::borrow(&self.entries, i);
            vector::push_back(&mut keys, entry.key);
            i = i + 1;
        };
        keys
    }

    /// Returns a list of values in the map.
    /// Do not assume any particular ordering.
    public fun values<K: copy, V: copy>(self: &Map<K, V>): vector<V> {
        let i = 0;
        let n = vector::length(&self.entries);
        let values = vector::empty();
        while (i < n) {
            let entry = vector::borrow(&self.entries, i);
            vector::push_back(&mut values, entry.value);
            i = i + 1;
        };
        values
    }

    /// Find the index of `key` in `self`. Return `None` if `key` is not in `self`.
    /// Note that map entries are stored in insertion order, *not* sorted by key.
    public fun get_idx_opt<K: copy, V>(self: &Map<K,V>, key: &K): Option<u64> {
        let i = 0;
        let n = size(self);
        while (i < n) {
            if (&vector::borrow(&self.entries, i).key == key) {
                return option::some(i)
            };
            i = i + 1;
        };
        option::none()
    }

    /// Find the index of `key` in `self`. Aborts if `key` is not in `self`.
    /// Note that map entries are stored in insertion order, *not* sorted by key.
    public fun get_idx<K: copy, V>(self: &Map<K,V>, key: &K): u64 {
        let idx_opt = get_idx_opt(self, key);
        assert!(option::is_some(&idx_opt), EKeyDoesNotExist);
        option::destroy_some(idx_opt)
    }

    /// Return a reference to the `idx`th entry of `self`. This gives direct access into the backing array of the map--use with caution.
    /// Note that map entries are stored in insertion order, *not* sorted by key.
    /// Aborts if `idx` is greater than or equal to `size(self)`
    public fun get_entry_by_idx<K: copy, V>(self: &Map<K, V>, idx: u64): (&K, &V) {
        assert!(idx < size(self), EIndexOutOfBounds);
        let entry = vector::borrow(&self.entries, idx);
        (&entry.key, &entry.value)
    }

    /// Return a mutable reference to the `idx`th entry of `self`. This gives direct access into the backing array of the map--use with caution.
    /// Note that map entries are stored in insertion order, *not* sorted by key.
    /// Aborts if `idx` is greater than or equal to `size(self)`
    public fun get_entry_by_idx_mut<K: copy, V>(self: &mut Map<K, V>, idx: u64): (&K, &mut V) {
        assert!(idx < size(self), EIndexOutOfBounds);
        let entry = vector::borrow_mut(&mut self.entries, idx);
        (&entry.key, &mut entry.value)
    }

    /// Remove the entry at index `idx` from self.
    /// Aborts if `idx` is greater than or equal to `size(self)`
    public fun remove_entry_by_idx<K: copy, V>(self: &mut Map<K, V>, idx: u64): (K, V) {
        assert!(idx < size(self), EIndexOutOfBounds);
        let Entry { key, value } = vector::remove(&mut self.entries, idx);
        (key, value)
    }
}
