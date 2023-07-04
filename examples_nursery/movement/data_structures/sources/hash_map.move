// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::hash_map {
    use std::option::{Self, Option};
    use std::vector;
    use std::bcs;
    use std::hash::sha2_256;

    use ds_std::from_bytes;

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
        size: u64,
        entries: vector<Entry<K, V>>,
    }

    /// An entry in the map
    struct Entry<K: copy, V> has copy, drop, store {
        key: K,
        value: V,
    }

    /// Create an empty `HashMap`
    public fun new<K: copy, V>(size: u64): HashMap<K,V> {
        HashMap { 
          entries: vector::empty(),
          size
        }
    }
    
    public fun get_index<K>(key: K, size: u64) {
      let bytes = bcs::to_bytes(&key);
      
    }

    /// Insert a new Key-Value Pair
    public fun insert<K, V>(map: &mut HashMap<K, V>, key: K, value: V) {
      
    }
}
