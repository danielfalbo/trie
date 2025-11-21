use std::io::{self, Write};

fn c2i(c: char) -> usize {
    return (c.to_ascii_lowercase() as u8 - b'a') as usize;
}

struct Trie {
    is_word: bool,
    children: [Option<Box<Trie>>; 26],
}

impl Trie {
    fn new() -> Self {
        return Self {
            is_word: false,
            children: std::array::from_fn(|_| None),
        }
    }

    fn insert(&mut self, word: &str) {
        let mut chars = word.chars();
        match chars.next() {
            None => { self.is_word = true; },
            Some(c) => {
                let child = self.children[c2i(c)]
                    .get_or_insert_with(|| Box::new(Trie::new()));
                let rest = word.get(1..).expect("Failed to slice");
                child.insert(rest);
            },
        }
    }

    fn is_prefix(&self, prefix: &str) -> Option<&Trie> {
        let mut chars = prefix.chars();
        match chars.next() {
            None => { return Some(self); },
            Some(c) => {
                match &self.children[c2i(c)] {
                    None => return None,
                    Some(child) => {
                        let rest = prefix.get(1..).expect("Failed to slice");
                        return child.is_prefix(rest);
                    }
                }
            },
        }
    }

    fn find(&self, word: &str) -> bool {
        return self.is_prefix(word)
            .map_or(false, |node| node.is_word);
    }
}

fn help() {
    println!("Available commands: EXIT, INSERT, PREFIX, FIND.");
}

fn main() {
    let mut t = Trie::new();

    let mut input = String::new();
    loop {
        print!("> ");
        io::stdout().flush().expect("Failed to flush stdout");

        io::stdin().read_line(&mut input).expect("Failed to read input");
        let trimmed = input.trim();

        if trimmed.eq_ignore_ascii_case("EXIT") {
            break;
        }

        let command: Vec<&str> = trimmed.split_whitespace().collect();
        if command.len() != 2 {
            help();
            continue;
        }

        if command[0].eq_ignore_ascii_case("INSERT") {
            t.insert(command[1]);
        } else if command[0].eq_ignore_ascii_case("FIND") {
            println!("{}", t.find(command[1]));
        } else if command[0].eq_ignore_ascii_case("PREFIX") {
            println!("{}", t.is_prefix(command[1]).is_some());
        } else {
            help()
        }

        input.clear();
    }
}
