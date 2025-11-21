all:

zig: trie.zig
	zig build-exe trie.zig

rust: trie.rs
	rustc trie.rs

rustacean: rustacean.rs
	rustc rustacean.rs -o trie

clean:
	rm -f trie trie.o
