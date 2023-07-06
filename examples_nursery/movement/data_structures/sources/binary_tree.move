// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::unique_binary_tree {
    use std::vector;
    use std::option::{ Self, Option };
    use std::bcs;
    use ds_std::hash_map::{ Self, HashMap };
    
    const EValueAreadyExist: u64 = 0;
    const EValueDontExist: u64 = 1;

    struct BTree<V> has copy, drop, store {
        tree_nodes: HashMap<vector<u8>, Node<V>>,
    }
    
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

    public fun insert<V>(tree: &mut BTree<V>, parent_value: &V, new_value: V) {
        let hashmap_key = bcs::to_bytes(&new_value);
        assert!(!hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueAreadyExist);
        hash_map::insert(&mut tree.tree_nodes, hashmap_key, new_node(new_value));
        
        let parent_key = bcs::to_bytes(parent_value);

        while (true) {
            let (_, node_value) = hash_map::get_mut(&mut tree.tree_nodes, &parent_key);
            if (option::is_none(&node_value.left)) {
                node_value.left = option::some(hashmap_key);
                break;
            } else if (option::is_none(&node_value.right)) {
                node_value.right = option::some(hashmap_key);
                break;
            } else {
                parent_key = bcs::to_bytes(node_value);
            };
        };
    }

    public fun children<V: copy>(tree: &BTree<V>, parent_value: &V): Vector<V> {
        let hashmap_key = bcs::to_bytes(&new_value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let children_values: Vector<V> = vector::empty();
        let queue = vector::empty();
        vector::push_back(&mut queue, hashmap_key);
        while (!vector::empty(queue)) {
            let pnode_key= vector::pop(queue);
            let (_, pnode) = hash_map::get(&tree.tree_nodes, pnode_key);
            
            vector::push_back(&mut children_values, pnode.value);
            if (option::is_some(&pnode.left)) {
                vector::push_back(&mut queue, pnode.left);
            };
            if (option::is_some(&node_value.right)) {
                vector::push_back(&mut queue, pnode.right);
            };
        };

        children_values
    }

    public fun get_direct_children<V>(tree: &BTree<V>, parent_value: &V): (&V, &V) {
        let hashmap_key = bcs::to_bytes(&parent_value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let (_, pnode) = hash_map::get(&tree.tree_nodes, hashmap_key);
        let (left, right) = (&pnode.value, &pnode.value);
        if (option::is_some(&pnode.left)) {
            let (_, lnode) = hash_map::get(&tree.tree_nodes, pnode.left);
            left = lnode.v;
        };
        if (option::is_some(&node_value.right)) {
            let (_, rnode) = hash_map::get(&tree.tree_nodes, pnode.right);
            right = rnode.v;
        };
        (left, right)
    }

    public fun get_mut_direct_children<V>(tree: &mut BTree<V>, parent_value: &V): (&mut V, &mut V) {
        let hashmap_key = bcs::to_bytes(&parent_value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let (_, pnode) = hash_map::get_mut(&mut tree.tree_nodes, hashmap_key);
        let (left, right) = (&pnode.value, &pnode.value);
        if (option::is_some(&pnode.left)) {
            let (_, lnode) = hash_map::get_mut(&tree.tree_nodes, &pnode.left);
            left = lnode.v;
        };
        if (option::is_some(&node_value.right)) {
            let (_, rnode) = hash_map::get_mut(&tree.tree_nodes, &pnode.right);
            right = rnode.v;
        };
        (left, right)
    }

    public fun remove<V>(tree: &mut BTree<V>, value: &V): Vector<V> {
        let hashmap_key = bcs::to_bytes(&new_value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let queue = vector::empty();
        let remove_values: Vector<V> = vector::empty();
        vector::push_back(&mut queue, hashmap_key);
        while (!vector::empty(queue)) {
            let pnode_key= vector::pop(queue);
            let (_, pnode) = hash_map::get_mut(&tree.tree_nodes, pnode_key);
            
            if (option::is_some(&pnode.left)) {
                vector::push_back(&mut queue, pnode.left);
            };
            if (option::is_some(&node_value.right)) {
                vector::push_back(&mut queue, pnode.right);
            };
            let v = hash_map::remove(pnode);
            vector::push_back(&mut remove_values, v);
        };
        remove_values
    }

    public fun replace_value<V>(tree: &mut BTree<V>, old_value: &V, new_value: V): V {
        let hashmap_key = bcs::to_bytes(&old_value);
        assert!(hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueDontExist);

        let (_, pnode) = hash_map::get_mut(&mut tree.tree_nodes, hashmap_key);
        let old_value = pnode.value;
        pnode.old_value = new_value;
        old_value
    }

    /// Return a new node with given value
    public fun new_node<V>(value: V): Node<V> {
        Node {
            value,
            left: option::none(),
            right: option::none()
        }
    }
}