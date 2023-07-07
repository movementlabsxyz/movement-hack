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
    const ERootAlreadyExist: u64 = 1;

    /// BTree struct
    struct BTree<V> has copy, drop, store {
        tree_nodes: HashMap<vector<u8>, Node<V>>,
        root_node_key: vector<u8>
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
          tree_nodes: hash_map::new(size),
          root_node_key: vector::empty()
        }
    }

    /// Insert a root value to tree
    public fun insert_root<V>(tree: &mut BTree<V>, root_value: V) {
        let hashmap_key = bcs::to_bytes(&root_value);
        assert!(hash_map::length(&tree.tree_nodes) == 0, ERootAlreadyExist);
        tree.root_node_key = hashmap_key;
        hash_map::insert(&mut tree.tree_nodes, hashmap_key, new_node(root_value));
    }

    /// Get root value of tree
    public fun borrow_root_value<V>(tree: &BTree<V>): &V {
        let (_, v) = hash_map::get(&tree.tree_nodes, &tree.root_node_key);
        &v.value
    }

    /// Insert a new value to tree as a child of `parent_value`
    public fun insert<V>(tree: &mut BTree<V>, parent_value_bytes: &vector<u8>, new_value: V) {
        let hashmap_key = bcs::to_bytes(&new_value);
        assert!(!hash_map::contains(&tree.tree_nodes, &hashmap_key), EValueAreadyExist);
        hash_map::insert(&mut tree.tree_nodes, hashmap_key, new_node(new_value));
        
        let parent_key = *parent_value_bytes;

        while (true) {
            let (_, node_value) = hash_map::get_mut(&mut tree.tree_nodes, &parent_key);
            if (option::is_none(&node_value.left)) {
                node_value.left = option::some(hashmap_key);
                break
            } else if (option::is_none(&node_value.right)) {
                node_value.right = option::some(hashmap_key);
                break
            } else {
                parent_key = *option::borrow(&node_value.left);
            };
        };
    }

    /// Insert a root value to tree
    public fun length<V>(tree: &BTree<V>): u64 {
        hash_map::length(&tree.tree_nodes)
    }

    /// Return all `children` of the `parent_value` as a vector
    public fun children<V: copy>(tree: &BTree<V>, parent_value_bytes: &vector<u8>): vector<V> {
        assert!(hash_map::contains(&tree.tree_nodes, parent_value_bytes), EValueDontExist);

        let children_values: vector<V> = vector::empty();
        let queue: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut queue, *parent_value_bytes);
        while (vector::length(&queue) != 0) {
            let pnode_key = vector_pop_front(&mut queue);
            let (_, pnode) = hash_map::get(&tree.tree_nodes, &pnode_key);

            // skip parent itself
            if (parent_value_bytes != &pnode_key)
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

    /// Remove the `value` from the tree
    public fun remove<V>(tree: &mut BTree<V>, value_bytes: &vector<u8>): vector<V> {
        assert!(hash_map::contains(&tree.tree_nodes, value_bytes), EValueDontExist);

        let queue: vector<vector<u8>> = vector::empty();
        let remove_values: vector<V> = vector::empty();
        vector::push_back(&mut queue, *value_bytes);
        while (vector::length(&queue) != 0) {
            let pnode_key= vector::pop_back(&mut queue);
            let (_, pnode) = hash_map::get_mut(&mut tree.tree_nodes, &pnode_key);
            
            if (option::is_some(&pnode.left)) {
                vector::push_back(&mut queue, *option::borrow(&pnode.left));
            };
            if (option::is_some(&pnode.right)) {
                vector::push_back(&mut queue, *option::borrow(&pnode.right));
            };
            let (_, v) = hash_map::remove(&mut tree.tree_nodes, &pnode_key);
            let Node { value, left: _, right: _ } = v;
            vector::push_back(&mut remove_values, value);
        };
        remove_values
    }

    /// Replace the `old_value` in the tree with `new_value`
    public fun replace_value<V>(tree: &mut BTree<V>, old_value_bytes: &vector<u8>, new_value: V): V {
        let hashmap_key = *old_value_bytes;
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

    /// Pop from front in a given vector
    fun vector_pop_front<T>(v: &mut vector<T>): T {
        vector::reverse(v);
        let value: T = vector::pop_back(v);
        vector::reverse(v);
        value
    }

    // Let's assume that there is 2-child policy in the specified area
    // So the parent can only have at most 2 child - left and right
    #[test_only]
    struct FamilyMember has drop, copy {
        name: vector<u8>,
        age: u64
    }

    #[test_only]
    fun do_inserts(btree: &mut BTree<FamilyMember>): vector<u8> {
        insert_root(btree, FamilyMember { name: b"Rushi", age: 50 });
        assert!(length(btree) == 1, 0);
        
        let root_v = borrow_root_value(btree);
        let root_v_bytes = bcs::to_bytes(root_v);
        assert!(root_v == &FamilyMember { name: b"Rushi", age: 50 }, 1);
        
        let new_member = FamilyMember { name: b"Liam", age: 30 };
        insert(btree, &root_v_bytes, new_member);
        assert!(length(btree) == 2, 0);

        let new_member1 = FamilyMember { name: b"Jack", age: 30 };
        insert(btree, &root_v_bytes, new_member1);
        assert!(length(btree) == 3, 0);

        let new_member2 = FamilyMember { name: b"Liam's Son", age: 10 };
        insert(btree, &root_v_bytes, new_member2);
        assert!(length(btree) == 4, 0);
        root_v_bytes
    }

    #[test]
    fun insert_and_remove_test() {
        let btree = new<FamilyMember>(10);
        let root_key = do_inserts(&mut btree);
        let values = remove(&mut btree, &root_key);
        assert!(vector::length(&values) == 4, 0);
    }

    #[test]
    fun replace_and_children_test() {
        let btree = new<FamilyMember>(10);
        let root_v_bytes = do_inserts(&mut btree);

        let incorrect_member = FamilyMember { name: b"Liam's Son", age: 10 };
        let old_v = replace_value(
            &mut btree, 
            &bcs::to_bytes(&incorrect_member), 
            FamilyMember { name: b"John", age: 10 }
        );
        assert!(old_v == incorrect_member, 1);
        let values = children(&btree, &root_v_bytes);
        assert!(values == vector[
            FamilyMember { name: b"Liam", age: 30 },
            FamilyMember { name: b"Jack", age: 30 },
            FamilyMember { name: b"John", age: 10 }
        ], 2);
    }
}