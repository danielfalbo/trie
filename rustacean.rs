use std::io::{self, Write};

#[derive(Default)]
struct Trie {
    is_word: bool,
    children: [Option<Box<Trie>>; 26],
}

impl Trie {
    fn new() -> Self {
        Self::default()
    }

    fn char_index(c: char) -> Option<usize> {
        match c {
            'a'..='z' => Some((c as u8 - b'a') as usize),
            'A'..='Z' => Some((c as u8 - b'A') as usize),
            _ => None
        }
    }

    fn insert(&mut self, word: &str) {
        let mut node = self;

        for c in word.chars() {
            if let Some(idx) = Self::char_index(c) {
                node = node.children[idx]
                    .get_or_insert_with(|| Box::new(Trie::new()));
            }
        }

        node.is_word = true;
    }

    fn find_node(&self, prefix: &str) -> Option<&Trie> {
        let mut node = self;

        for c in prefix.chars() {
            let idx = Self::char_index(c)?;

            match node.children[idx].as_ref() {
                Some(child) => node = child,
                None => return None,
            }
        }

        Some(node)
    }

    fn find(&self, word: &str) -> bool {
        self.find_node(word).map_or(false, |n| n.is_word)
    }

    fn is_prefix(&self, prefix: &str) -> bool {
        self.find_node(prefix).is_some()
    }

}

fn main() {
    let mut t = Trie::new();
    let mut input = String::new();

    println!("Available commands: EXIT, INSERT <>, PREFIX <>, FIND <>.");

    loop {
        print!("> ");
        io::stdout().flush().expect("Failed to flush stdout");

        input.clear();
        io::stdin().read_line(&mut input).expect("Failed to read input");

        let trimmed = input.trim();
        if trimmed.eq_ignore_ascii_case("EXIT") {
            break;
        }

        let mut parts = trimmed.split_whitespace();

        match (parts.next(), parts.next()) {
            (Some(cmd), Some(arg)) => {
                match cmd.to_ascii_uppercase().as_str() {
                    "INSERT" => t.insert(arg),
                    "FIND" => println!("{}", t.find(arg)),
                    "PREFIX" => println!("{}", t.is_prefix(arg)),
                    _ => println!("Unknown command"),
                }
            },
            _ => println!("Invalid format. Usage: COMMAND <arg>"),
        }
    }
}
