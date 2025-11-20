all: clean

zig: trie.zig
	zig build-exe trie.zig

rust: trie.rs
	rustc trie.rs

clean:
	rm trie
