// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::bst {
    use std::vector;
    use std::option::{ Self, Option };
    // use std::bcs;
    use ds_std::oa_hash_map::{ Self, OaHashMap, Entry };

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

    public fun preorder<V : copy + drop>(bst: &BinarySearchTree<V>, node: V, f: (V) -> ()) {

        f(node);
        if let Some(adj_list) = bst.adj.get(&node) {
            for neighbor in adj_list.iter() {
                preorder(bst, *neighbor, f);
            }
        }
    }

    public fun inorder<V : copy + drop>(bst: &BinarySearchTree<V>, node: V, f: (V) -> ()) {

        if let Some(adj_list) = bst.adj.get(&node) {
            if adj_list.len() >= 1 {
                inorder(bst, adj_list[0], f);
            }
            f(node);
            if adj_list.len() == 2 {
                inorder(bst, adj_list[1], f);
            }
        }
    }

    public fun postorder<V : copy + drop>(bst: &BinarySearchTree<V>, node: V, f: (V) -> ()) {

        if let Some(adj_list) = bst.adj.get(&node) {
            if adj_list.len() >= 1 {
                postorder(bst, adj_list[0], f);
            }
            if adj_list.len() == 2 {
                postorder(bst, adj_list[1], f);
            }
            f(node);
        }
    }

    public fun level_order<V : copy + drop>(bst: &BinarySearchTree<V>, root: V, f: (V) -> ()) {

        let mut queue = vector::empty<V>();
        vector::push_back(&mut queue, root);

        while !vector::is_empty(&queue) {
            let node = vector::remove(&mut queue, 0);
            f(node);
            if let Some(adj_list) = bst.adj.get(&node) {
                for neighbor in adj_list.iter() {
                    vector::push_back(&mut queue, *neighbor);
                }
            }
        }
    }
}




