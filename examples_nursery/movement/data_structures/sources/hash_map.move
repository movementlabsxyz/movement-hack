// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::hash_map {
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

    struct HashMap<K: copy, V> has copy, drop, store {
        entries: vector<Entry<K, V>>,
    }

    /// An entry in the map
    struct Entry<K: copy, V> has copy, drop, store {
        key: K,
        value: V,
    }

    /// Create an empty `Map`
    public fun new<K: copy, V>(): HashMap<K,V> {
        HashMap { entries: vector::empty() }
    }
}
