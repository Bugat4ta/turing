import time

Blank = "_"

class SixHeadTuringMachine:
    def __init__(self, num_heads, transition_fn, start_state, accept_states,
                 reject_states=None, blank=Blank):
        if num_heads < 1:
            raise ValueError("num_heads must be >= 1")
        self.k = num_heads
        self.transition_fn = transition_fn
        self.start_state = start_state
        self.accept_states = set(accept_states)
        self.reject_states = set() if reject_states is None else set(reject_states)
        self.blank = blank
        self.reset()

    def reset(self):
        self.tapes = [{} for _ in range(self.k)]
        self.heads = [0] * self.k
        self.state = self.start_state
        self.steps = 0
        self.halted = False

    def load_input(self, input_str, tape_index=0, start_pos=0):
        for i, ch in enumerate(input_str):
            self.tapes[tape_index][start_pos + i] = ch
        self.heads[tape_index] = start_pos

    def read_symbols(self):
        symbols = []
        for i in range(self.k):
            pos = self.heads[i]
            symbols.append(self.tapes[i].get(pos, self.blank))
        return tuple(symbols)

    def write_symbols(self, writes):
        for i in range(self.k):
            sym = writes[i]
            if sym is not None:
                pos = self.heads[i]
                self.tapes[i][pos] = sym

    def move_heads(self, moves):
        for i in range(self.k):
            m = moves[i]
            if m == "L":
                self.heads[i] -= 1
            elif m == "R":
                self.heads[i] += 1
            elif m != "S":
                raise ValueError("Invalid move")

    def step(self):
        if self.halted:
            return True
        symbols = self.read_symbols()
        action = self.transition_fn(self.state, symbols)
        if action is None:
            self.halted = True
            return True
        new_state, writes, moves = action
        if len(writes) != self.k or len(moves) != self.k:
            raise ValueError("writes/moves length mismatch")
        self.write_symbols(writes)
        self.move_heads(moves)
        self.state = new_state
        self.steps += 1
        if self.state in self.accept_states or self.state in self.reject_states:
            self.halted = True
        return self.halted

    def dump_tape(self, tape_index, window=20):
        h = self.heads[tape_index]
        left = h - window
        right = h + window
        out = ""
        for pos in range(left, right + 1):
            sym = self.tapes[tape_index].get(pos, self.blank)
            if pos == h:
                out += "[" + sym + "]"
            else:
                out += " " + sym + " "
        return out

def copy_input_transition(state, symbols):
    k = 6
    if state == "q0":
        s0 = symbols[0]
        if s0 != Blank:
            writes = [None] * k
            writes[1] = s0
            moves = ["R", "R"] + ["S"] * (k - 2)
            return ("q0", tuple(writes), tuple(moves))
        else:
            moves = ["S"] * k
            writes = [None] * k
            return ("q_accept", tuple(writes), tuple(moves))
    return None

if __name__ == "__main__":
    tm = SixHeadTuringMachine(
        num_heads=6,
        transition_fn=copy_input_transition,
        start_state="q0",
        accept_states={"q_accept"}
    )
    tm.load_input("hi my name is alan turing")
    try:
        while True:
            print("\033[H\033[J", end="")
            print("Step:", tm.steps, "State:", tm.state)
            for i in range(tm.k):
                print("Tape", i, ":", tm.dump_tape(i))
            if tm.step():
                print("\nMachine halted. State:", tm.state)
                break
            time.sleep(0.25)
    except KeyboardInterrupt:
        print("\nStopped manually at step", tm.steps)
