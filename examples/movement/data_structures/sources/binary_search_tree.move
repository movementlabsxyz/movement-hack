module ds_std::unique_binary_tree {
    use std::vector;
    use std::option::{ Self, Option };
    use std::bcs;
    use ds_std::hash_map::{ Self, HashMap };
    
    /// Errors
    const ENO_VALUE_ALREADY_EXISTS: u64 = 0;
    const ENO_VALUE_DOESNT_EXIST: u64 = 1;
    const ENO_ROOT_ALREADY_EXISTSt: u64 = 1;

    /// BinaryTree struct
    struct BinaryTree<V> has copy, drop, store {
        tree_nodes: HashMap<vector<u8>, Node<V>>,
        root_node_key: vector<u8>
    }
    
    /// Node of `BinaryTree`
    /// NOTE: Move does not support recursive types, so you need to to use a 
    /// a backing store to store the children of the node.
    struct Node<V> has copy, drop, store {
        value: V,
        left: Option<vector<u8>>,
        right: Option<vector<u8>>,
    }

    /// Create an empty `BinaryTree`
    public fun new<V>(size: u64): BinaryTree<V> {
        BinaryTree { 
          tree_nodes: hash_map::new(size),
          root_node_key: vector::empty()
        }
    }

    public fun insert_value<V>(tree: BinaryTree<V>, given_value: V) {
        let hashmap_key = bcs::to_bytes(&given_value);

        /// Insert as root
        if (hash_map::length(&tree.tree_nodes) == 0) {
            tree.root_node_key = hashmap_key;
            hash_map::insert(&mut tree.tree_nodes, hashmap_key, new_node(given_value));
        } else {
            let mut curr_node_key = tree.root_node_key.unwrap();
            let mut curr_node = move_from<Node<V>>(tree.tree_nodes.get_mut(&curr_node_key));

            while (curr_node != move_from<Node<V>>(None)) {
                
            }

            }
        }
    }

    /// Insert a root value to tree
    public fun insert_root<V>(tree: &mut BinaryTree<V>, root_value: V) {
        let hashmap_key = bcs::to_bytes(&root_value);
        assert!(hash_map::length(&tree.tree_nodes) == 0, ENO_ROOT_ALREADY_EXISTSt);
        tree.root_node_key = hashmap_key;
        hash_map::insert(&mut tree.tree_nodes, hashmap_key, new_node(root_value));
    }

    /// Get root value of tree
    public fun borrow_root_value<V>(tree: &BinaryTree<V>): &V {
        let (_, v) = hash_map::get(&tree.tree_nodes, &tree.root_node_key);
        &v.value
    }
    
    /// Insert a value into tree


