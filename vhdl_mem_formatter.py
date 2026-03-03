import os 
import time
import sys

def format_code(code: str) -> str:
    formatted_code: str = \
    "library ieee;\n" + \
    "use ieee.std_logic_1164.all;\n" + \
    "package soft_rom is\n" + \
    "\ttype t_rom is array (0 to 255) of std_logic_vector(7 downto 0);\n" + \
    "\tconstant c_soft_rom : t_rom := ("
                                     
    for i in range(0, len(code), 2): 
        formatted_code += "x\"" + code[i:i+2] + "\", "
    
    formatted_code += \
    "others => x\"00\");\n" + \
    "end package soft_rom;"
    
    return formatted_code


if __name__ == "__main__":
    c_src_filename: str = "./programs/test.hex"
    c_dst_filename: str = "./rtl/soft_rom.vhd"


    prev_timestamp: int = os.stat(c_src_filename).st_mtime_ns;
    while True:
        
        current_timestamp: int = os.stat(c_src_filename).st_mtime_ns;
        if (current_timestamp != prev_timestamp):
            print("formatting " + c_src_filename)
            formatted_code: str = ""
            with open(c_src_filename, 'r') as f: 
                code: str = ""
                for line in f: 
                    code += line.strip()
                    
                formatted_code = format_code(code)

            with open(c_dst_filename, 'w') as f:
                f.write(formatted_code)
            
        prev_timestamp = os.stat(c_src_filename).st_mtime_ns

        time.sleep(1);
