import sys
import re

from enum import Enum
from typing import NamedTuple 
from typing import Union

class InstructionType(Enum):
    INVALID = 0,
    I = 1, 
    R = 2, 
    J = 3


class InstructionInfo(NamedTuple):
    type: InstructionType
    opcode: str
    operands: list[str]
    constants: dict[str, str]

C_INSTRUCTION_MAP: dict[str, InstructionInfo] = {
    "addi": InstructionInfo(
        type=InstructionType.I,
        opcode="001000",
        operands=["rt", "rs", "imm"],
        constants={}
    ),
    "add": InstructionInfo(
        type=InstructionType.R,
        opcode="000000",
        operands=["rd", "rs", "rt"],
        constants={"shamt": "00000", "funct": "100000"}
    ),
    "sub": InstructionInfo(
        type=InstructionType.R,
        opcode="000000",
        operands=["rd", "rs", "rt"],
        constants={"shamt": "00000", "funct": "100010"}
    ),
    "and": InstructionInfo(
        type=InstructionType.R,
        opcode="000000",
        operands=["rd", "rs", "rt"],
        constants={"shamt": "00000", "funct": "100100"}
    ),
    "or": InstructionInfo(
        type=InstructionType.R,
        opcode="000000",
        operands=["rd", "rs", "rt"],
        constants={"shamt": "00000", "funct": "100101"}
    ),
    "slt": InstructionInfo(
        type=InstructionType.R,
        opcode="000000",
        operands=["rd", "rs", "rt"],
        constants={"shamt": "00000", "funct": "101010"}
    ),
    "lw": InstructionInfo(
        type=InstructionType.I,
        opcode="100011",
        operands=["rt", "imm", "rs"],
        constants={}
    ),
    "sw": InstructionInfo(
        type=InstructionType.I,
        opcode="101011",
        operands=["rt", "imm", "rs"],
        constants={}
    ),
    "beq": InstructionInfo(
        type=InstructionType.I,
        opcode="000100",
        operands=["rs", "rt", "imm"],
        constants={}
    ),
    "sll": InstructionInfo(
        type=InstructionType.R,
        opcode="000000",
        operands=["rd", "rt", "shamt"],
        constants={"rs": "00000", "funct": "000000"}
    ),
    "j": InstructionInfo(
        type=InstructionType.J,
        opcode="000010",
        operands=["addr"],
        constants={}
    ),
}


g_SymbolTable: dict[str, int] = {}
    

def convertNum(decimalNum: int, radix: int) -> str:
    hexDigits: str = "0123456789ABCDEF"
    digit: str = hexDigits[decimalNum % radix]
    rest: int = decimalNum // radix
    
    if (rest == 0):
        return digit
    return convertNum(rest, radix) + digit

def pad(num: str, size: int, padStr: str = '0') -> str: 
    while len(num) < size: 
        num = padStr + num
        
    return num
    
def immediateHandler(token: str, size: int) -> str:
    num: int = 0
    paddingCh: str = '0';
    if (token[0] == '-'):
        num = int(token[1:]);
        num = (2 ** size) - num
        paddingCh = '1'
    else:
        num = int(token)
    convertedNum: str = convertNum(num, 2)
    
    return pad(convertedNum, size, paddingCh)

def registerHandler(token: str, size: int): 
    num: int = int(token.strip(",$)")) 
    num_string: str = convertNum(num, 2)
    return pad(num_string, size, '0')

def tokenHandler(token: str, size: int) -> str:
    if (token[0] == '-' or token.isdigit()):
        return immediateHandler(token, size)
    elif token[0] == '$':
        return registerHandler(token, size)
    
    jumpAddress: int = g_SymbolTable[token]
    return immediateHandler(str(jumpAddress), size)


def encodeInstruction(instruction: list[str]) -> str:
    info: InstructionInfo = C_INSTRUCTION_MAP[instruction[0]]
    encoded: str = info.opcode
    layout: dict[str, int] = {}
    
    if info.type == InstructionType.R:
        layout = {"rs":5, "rt":5, "rd":5, "shamt":5, "funct":6}
    elif info.type == InstructionType.I:
        layout = {"rs":5, "rt":5, "imm": 16}
    elif info.type == InstructionType.J:
        layout = {"addr": 26}
    else: 
        assert False, "instruction type invalid"

        
    
    operands: dict[str, str] = {}
    for i in range(0, len(info.operands)):
        operand: str = info.operands[i]
        operands[operand] = instruction[i+1]
    
    for field, size in layout.items():
        if field in operands:
            token: str = operands[field]
            encoded += tokenHandler(token, size)
        elif field in info.constants:
            encoded += info.constants[field]
        else: 
            print("uh oh, something went wrong ):")

    print(encoded)
    assert len(encoded) == 32, "instruction somehow isnt 32bits"

    return encoded
        

if __name__ == "__main__":
    machineCode: str = ""
    assemblyFileName: str = "prog.asm"

    
    with open(assemblyFileName, mode='r') as f: 
        currentAddress: int = 0
        lines: list[str] = f.read().split('\n')
        
        for line in lines:
            items: list[str] = re.split(r'[ |:]', line.strip())
            if len(line) == 0:
                continue

            if items[0] in C_INSTRUCTION_MAP:
                currentAddress += 4
            else:
                g_SymbolTable[items[0]] = currentAddress
        
        token: str = ""
        for line in lines:
            items: list[str] = re.split(r'[ |(|:|]+', line.strip())
            if len(line) == 0:
                continue
            if items[0] in C_INSTRUCTION_MAP:
                machineCode += encodeInstruction(items)
                                              

    print(machineCode)
    hexMachineCode: str = ""
    for i in range(0, len(machineCode), 8): 
        halfByte: int = int(machineCode[i: i+8], 2)
        hexNum: str = pad(convertNum(halfByte, 16), 2)
        hexMachineCode += f"x\"{hexNum}\","

    hexMachineCode += "others => x\"00\""
    print(hexMachineCode)
