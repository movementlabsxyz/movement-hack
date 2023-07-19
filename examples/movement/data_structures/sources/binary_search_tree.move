// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::bst {
    use std::vector;
    use std::option::{ Self, Option };
    // use std::bcs;
    use ds_std::oa_hash_map::{ Self, OaHashMap, Entry };

    /// BST struct
    struct BinarySearchTree<V> has drop, store {
        size : u64,
        adj : OaHashMap<V, [V;2]>,
    }

    public fun new<V>(size : u64) : BinarySearchTree<V> {

        BinarySearchTree {
            size : size,
            adj : oa_hash_map::new<V, [V;2]>(size)
        }

    }

    public fun insert_adj<V : drop + copy>(bst : &mut BinarySearchTree<V>, from : V, to : V) : Option<Entry<V, V>> {

        if (!oa_hash_map::contains(&bst.adj, &from)){
            oa_hash_map::set(&mut bst.adj, *&from, [V::default(), V::default()]);
        };
        
        let adj = oa_hash_map::borrow_mut(&mut bst.adj, &from);
        oa_hash_map::set(adj, *&to, *&to)

    }

    public fun remove_adj<V>(bst : &mut BinarySearchTree<V>, from : &V, to : &V) : Option<Entry<V, V>> {

        if (!oa_hash_map::contains(&bst.adj, from)){
            return option::none()
        };
        
        let adj = oa_hash_map::borrow_mut(&mut bst.adj, from);
        oa_hash_map::remove(adj, to) 

    }

    public fun borrow_adj<V>(bst : &BinarySearchTree<V>, from : &V) : &OaHashMap<V, V> {

        oa_hash_map::borrow(&bst.adj, from)

    }

    public fun borrow_adj_mut<V>(bst : &mut BinarySearchTree<V>, from : &V) : &mut OaHashMap<V, V> {

        oa_hash_map::borrow_mut(&mut bst.adj, from)

    }

}