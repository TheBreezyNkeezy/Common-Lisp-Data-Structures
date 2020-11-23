# Common Lisp Data Structures

## Overview
This ongoing side project is my way of practicing getting familiar with CLOS, which I have found to be one of the most powerful OOP frameworks I've ever used ("Hey Patrick, your Common Lisp confirmation bias is showing..."). I aim to have implemented sometime down the line the following data structures, picked mainly out of interest and progression through harder derivatives:
* "basic" array hashmap
* linked list hashmap
* [list multimap](https://en.wikipedia.org/wiki/Multimap)
* [set multimap](https://en.wikipedia.org/wiki/Multimap)
* [cuckoo hashmap](https://en.wikipedia.org/wiki/Cuckoo_hashing)
* [hash array mapped trie](https://en.wikipedia.org/wiki/Hash_array_mapped_trie)
* [concurrent hash trie](https://en.wikipedia.org/wiki/Ctrie)
* [radix tree](https://en.wikipedia.org/wiki/Radix_tree)
* [distributed hash tree](https://en.wikipedia.org/wiki/Distributed_hash_table)
* [prefix hash tree](https://en.wikipedia.org/wiki/Prefix_hash_tree)
* [Merkle tree](https://en.wikipedia.org/wiki/Merkle_tree)

## Highlights: Array Hashmap Implementation
See the [implementation here](src/hashmaps.lisp). Highlights include dynamic resizing and rehashing of buckets upon additions when necessary, an `ITERHM` method that harkens to iterators in other languages by returning an array of key-value pairs, a `DRAINHM` method that combines `ITERHM` and also clears the hashmap, and a `MERGEHM` method that combines two of these hashmaps. My implementation also makes extensive use of the `LOOP` macro, whose power I was also learning at the same time. I hope to implement the method `SETHM (key val (hm array-hashmap)` in order to return a new hashmap with the new key-value pair substituted, as well as simple `KEYHM` and `VALUEHM` methods that return arrays of all keys and values, respectively.
