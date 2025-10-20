
class QRegister:
    def __init__(self, n):
        self.bits = [0] * n

    def __getitem__(self, i):
        return self.bits[i]

    def __setitem__(self, i, v):
        self.bits[i] = v & 1

    def __len__(self):
        return len(self.bits)

    def __repr__(self):
        return "|" + "".join(str(b) for b in self.bits) + ">"

def gate_x(q, args):
    i = args[0]
    q[i] ^= 1

def gate_cx(q, args):
    ctrl, targ = args
    if q[ctrl]:
        q[targ] ^= 1

def gate_swap(q, args):
    i, j = args
    q[i], q[j] = q[j], q[i]

def gate_measure(q, args):
    i = args[0]
    print(f"measure q[{i}] -> {q[i]}")

GATES = {
    "x": gate_x,
    "cx": gate_cx,
    "swap": gate_swap,
    "measure": gate_measure,
}


def parse_instruction(line):
    line = line.strip().lower()
    if not line or line.startswith("#"):
        return None
    parts = line.replace(",", " ").split()
    op = parts[0]
    args = [int(a) for a in parts[1:]]
    return op, args


def run_qasm(program, qreg):
    for line in program:
        parsed = parse_instruction(line)
        if not parsed:
            continue
        op, args = parsed
        if op in GATES:
            GATES[op](qreg, args)
        else:
            raise ValueError(f"Unknown gate: {op}")


num_heads = 6
tape_len = 8
tapes = [QRegister(tape_len) for _ in range(num_heads)]

encode = {"a": 0, "b": 1, "0": 0, "1": 1}
input_str = "abba01"
for i, ch in enumerate(input_str):
    tapes[0][i] = encode[ch]

print("Initial state:")
for i, t in enumerate(tapes):
    print(f"Tape{i}:", t)

program = []
for bit in range(len(input_str)):
    for t in range(1, num_heads):
        program.append(f"cx {bit},{bit}") 

for bit in range(len(input_str)):
    ctrl_val = tapes[0][bit]
    for t in range(1, num_heads):
        if ctrl_val == 1:
            tapes[t][bit] ^= 1

print("\nAfter 'QASM copy' broadcast:")
for i, t in enumerate(tapes):
    print(f"Tape{i}:", t)

print("\nMeasurements:")
for i, t in enumerate(tapes):
    print(f"Tape{i} ->", ''.join(str(b) for b in t.bits))
