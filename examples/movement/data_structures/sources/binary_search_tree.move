// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::graph {
    use std::vector;
    use std::option::{ Self, Option };
    // use std::bcs;
    use ds_std::oa_hash_map::{ Self, OaHashMap, Entry };

    /// Graph struct
    struct Graph<V> has drop, store {
        size : u64,
        adj : OaHashMap<V, OaHashMap<V, V>>,
    }

    public fun new<V>(size : u64) : Graph<V> {

        Graph {
            size : size,
            adj : oa_hash_map::new<V, OaHashMap<V, V>>(2)
        }

    }

    public fun insert_adj<V : drop + copy>(graph : &mut Graph<V>, from : V, to : V) : Option<Entry<V, V>> {

        if (!oa_hash_map::contains(&graph.adj, &from)){
            oa_hash_map::set(&mut graph.adj, *&from, oa_hash_map::new<V, V>(graph.size));
        };
        
        let adj = oa_hash_map::borrow_mut(&mut graph.adj, &from);
        oa_hash_map::set(adj, *&to, *&to)

    }

    public fun remove_adj<V>(graph : &mut Graph<V>, from : &V, to : &V) : Option<Entry<V, V>> {

        if (!oa_hash_map::contains(&graph.adj, from)){
            return option::none()
        };
        
        let adj = oa_hash_map::borrow_mut(&mut graph.adj, from);
        oa_hash_map::remove(adj, to) 

    }

    public fun borrow_adj<V>(graph : &Graph<V>, from : &V) : &OaHashMap<V, V> {

        oa_hash_map::borrow(&graph.adj, from)

    }

    public fun borrow_adj_mut<V>(graph : &mut Graph<V>, from : &V) : &mut OaHashMap<V, V> {

        oa_hash_map::borrow_mut(&mut graph.adj, from)

    }

    public inline fun bfs<V : copy + drop>(
        graph : &Graph<V>, 
        start : &V,
        f: |&V|
    ){

        let queue = vector::empty<V>();
        vector::push_back(&mut queue, *start);
        let visited = oa_hash_map::new<V, bool>(graph.size);

        while (!vector::is_empty(&queue)) {

            let node = vector::remove(&mut queue, 0);
            if (oa_hash_map::contains(&visited, &node)) {
                continue
            };

            f(&node);
            oa_hash_map::set(&mut visited, node, true);

            if (!oa_hash_map::contains(&graph.adj, &node)) {
                continue
            };

            let adj = borrow_adj(graph, &node);
            let i = 0;
            loop {
                let (ni, value) = oa_hash_map::iter_next(adj, i);
                if (option::is_none(value)) {
                    break
                };
                i = ni;
                let value = oa_hash_map::get_value(option::borrow(value));
                if (!oa_hash_map::contains(&visited, value)) {
                    vector::push_back(&mut queue, *value);
                };
            };

        };
        

    }
    
    #[test]
    public fun test_insert(){

        let graph = new<u8>(10);
        let from = 1;
        let to = 2;
        insert_adj(&mut graph, from, to);
        let adj = borrow_adj(&graph, &from);
        assert!(oa_hash_map::contains(adj, &to), 99);

    }

    #[test]
    public fun test_multiple_insert(){

        let graph = new<u8>(10);
        let la = 1;
        let ny = 2;
        let sf = 3;
        insert_adj(&mut graph, la, ny);
        insert_adj(&mut graph, la, sf);
        let adj = borrow_adj(&graph, &la);
        assert!(oa_hash_map::contains(adj, &sf), 99);
        assert!(oa_hash_map::contains(adj, &ny), 99);

    }

    #[test]
    public fun test_borrows_adj_iterates(){

        let graph = new<u8>(10);
        let la = 1;
        let ny = 2;
        let sf = 3;
        insert_adj(&mut graph, la, ny);
        insert_adj(&mut graph, la, sf);
        let adj = borrow_adj(&graph, &la);
        
        let i = 0;
        let ny_seen = false;
        let sf_seen = false;
        loop {
           let (ni, value) = oa_hash_map::iter_next(adj, i);
           if (option::is_none(value)) {
               break
           };
           i = ni;
           if (*oa_hash_map::get_value(option::borrow(value)) == ny) {
               ny_seen = true;
           };
           if (*oa_hash_map::get_value(option::borrow(value)) == sf) {
               sf_seen = true;
           };
        };

        assert!(ny_seen && sf_seen, 99);

    }

    #[test]
    public fun test_bfs_next() {


        let count = 0;
        let graph = new<u8>(10);
        let la = 1;
        let ny = 2;
        let sf = 3;
        insert_adj(&mut graph, la, ny);
        insert_adj(&mut graph, la, sf);
        bfs(&graph, &la, |node| {
            let _ = node;
            count = count + 1;
        });
        assert!(count == 3, 99);    
    
    }

   
}