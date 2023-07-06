// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::unique_binary_tree {
    use std::vector;
    use std::option::{ Self, Option };
    use std::bcs;
    use ds_std::hash_map::{ Self, HashMap };
    
    /// Errors
    const EValueAreadyExist: u64 = 0;
    const EValueDontExist: u64 = 1;

    /// BTree struct
    struct BTree<V> has copy, drop, store {
        tree_nodes: HashMap<vector<u8>, Node<V>>,
    }
    
    /// Node of `BTree`
    struct Node<V> has copy, drop, store {
        value: V,
        left: Option<vector<u8>>,
        right: Option<vector<u8>>,
    }

    /// Create an empty `BTree`
    public fun new<V>(size: u64): BTree<V> {
        BTree { 
          tree_nodes: hash_map::new(size)
        }
    }

    /// Insert a new value to tree as a child of `parent_value`
    public fun insert<V>(tree: &mut BTree<V>, parent_value: &V, new_value: V) {
        let hashmap_key = bcs::to_bytes(&new_value);
        assert!(!hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueAreadyExist);
        hash_map::insert(&mut tree.tree_nodes, hashmap_key, new_node(new_value));
        
        let parent_key = bcs::to_bytes(parent_value);

        while (true) {
            let (_, node_value) = hash_map::get_mut(&mut tree.tree_nodes, &parent_key);
            if (option::is_none(&node_value.left)) {
                node_value.left = option::some(hashmap_key);
                break
            } else if (option::is_none(&node_value.right)) {
                node_value.right = option::some(hashmap_key);
                break
            } else {
                parent_key = bcs::to_bytes(node_value);
            };
        };
    }

    /// Return all `children` of the `parent_value` as a vector
    public fun children<V: copy>(tree: &BTree<V>, parent_value: &V): vector<V> {
        let hashmap_key = bcs::to_bytes(parent_value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let children_values: vector<V> = vector::empty();
        let queue: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut queue, hashmap_key);
        while (vector::length(&queue) != 0) {
            let pnode_key= vector::pop_back(&mut queue);
            let (_, pnode) = hash_map::get(&tree.tree_nodes, &pnode_key);
            
            vector::push_back(&mut children_values, pnode.value);
            if (option::is_some(&pnode.left)) {
                vector::push_back(&mut queue, *option::borrow(&pnode.left));
            };
            if (option::is_some(&pnode.right)) {
                vector::push_back(&mut queue, *option::borrow(&pnode.right));
            };
        };

        children_values
    }

    /*
    public fun get_direct_children<V>(tree: &BTree<V>, parent_value: &V): (&V, &V) {
        let hashmap_key = bcs::to_bytes(parent_value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let (_, pnode) = hash_map::get(&tree.tree_nodes, &hashmap_key);
        let (left, right) = (&pnode.value, &pnode.value);
        if (option::is_some(&pnode.left)) {
            let (_, lnode) = hash_map::get(&tree.tree_nodes, option::borrow(&pnode.left));
            left = &lnode.value;
        };
        if (option::is_some(&pnode.right)) {
            let (_, rnode) = hash_map::get(&tree.tree_nodes, option::borrow(&pnode.right));
            right = &rnode.value;
        };
        (left, right)
    }

    public fun get_mut_direct_children<V>(tree: &mut BTree<V>, parent_value: &V): (&mut V, &mut V) {
        let hashmap_key = bcs::to_bytes(parent_value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let (_, pnode) = hash_map::get_mut(&mut tree.tree_nodes, &hashmap_key);
        let (left, right) = (&mut pnode.value, &mut pnode.value);
        if (option::is_some(&pnode.left)) {
            let (_, lnode) = hash_map::get_mut(&mut tree.tree_nodes, option::borrow(&pnode.left));
            left = &mut lnode.value;
        };
        if (option::is_some(&pnode.right)) {
            let (_, rnode) = hash_map::get_mut(&mut tree.tree_nodes, option::borrow(&pnode.right));
            right = &mut rnode.value;
        };
        (left, right)
    }*/

    /// Remove the `value` from the tree
    public fun remove<V>(tree: &mut BTree<V>, value: &V): vector<V> {
        let hashmap_key = bcs::to_bytes(value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let queue: vector<vector<u8>> = vector::empty();
        let remove_values: vector<V> = vector::empty();
        vector::push_back(&mut queue, hashmap_key);
        while (vector::length(&queue) != 0) {
            let pnode_key= vector::pop_back(&mut queue);
            let (_, pnode) = hash_map::get_mut(&mut tree.tree_nodes, &pnode_key);
            
            if (option::is_some(&pnode.left)) {
                vector::push_back(&mut queue, *option::borrow(&pnode.left));
            };
            if (option::is_some(&pnode.right)) {
                vector::push_back(&mut queue, *option::borrow(&pnode.right));
            };
            let (_, v) = hash_map::remove(&mut tree.tree_nodes, &hashmap_key);
            let Node { value, left: _, right: _ } = v;
            vector::push_back(&mut remove_values, value);
        };
        remove_values
    }

    /// Replace the `old_value` in the tree with `new_value`
    public fun replace_value<V>(tree: &mut BTree<V>, old_value: &V, new_value: V): V {
        let hashmap_key = bcs::to_bytes(old_value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let (_, pnode) = hash_map::remove(&mut tree.tree_nodes, &hashmap_key);
        let Node {left, right, value} = pnode;
        hash_map::insert(&mut tree.tree_nodes, hashmap_key, make_node(new_value, left, right));
        value
    }

    /// Return a new node with given value
    public fun new_node<V>(value: V): Node<V> {
        Node {
            value,
            left: option::none(),
            right: option::none()
        }
    }

    /// Form a node with given value and left & right
    public fun make_node<V>(value: V, left: Option<vector<u8>>, right: Option<vector<u8>>): Node<V> {
        Node {
            value,
            left,
            right
        }
    }
}