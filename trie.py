class Trie:
    def __init__(self):
        self.is_word = False
        self.children = {}

    def insert(self, word):
        if len(word) == 0:
            self.is_word = True
            return
        first, rest = word[0], word[1:]
        self.children[first] = self.children.get(first, Trie())
        self.children[first].insert(rest)

    def is_prefix(self, prefix):
        if len(prefix) == 0: return self
        first, rest = prefix[0], prefix[1:]
        if first not in self.children: return False
        return self.children[first].is_prefix(rest)

    def find(self, word):
        prefix = self.is_prefix(word)
        return prefix and prefix.is_word


t = Trie()
while True:
    try: s = input("> ")
    except EOFError: break
    if s.lower() == "exit": break
    if " " not in s:
        print(f"Invalid command: {s}. Available commands: EXIT, INSERT, PREFIX, FIND.")
        continue
    [command, parameter] = s.split(" ")
    command = command.lower()
    if command == "insert": print(t.insert(parameter))
    elif command == "prefix": print(bool(t.is_prefix(parameter)))
    elif command == "find": print(t.find(parameter))
    else: print(f"Invalid command: {command}. Available commands: EXIT, INSERT, PREFIX, FIND.")
