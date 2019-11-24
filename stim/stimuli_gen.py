#!/usr/bin/env python3

import math

N = 10

def f_hex(value):
    length = math.ceil(N/4)
    return f'{"0"*(length-len(hex(value)[2:]))}{hex(value)[2:]}'

def main():
    # Line format: num den quo rmn\n
    with open(f'div_stimuli_{N}bit.txt', 'w') as f:
        for num in range(2**N): # numerator
            for den in range(2**N): # denominator
                f.write(f'{f_hex(num)} {f_hex(den)} ')
                if den == 0:
                    # if den=0, quo=(2**N - 1) and rmn=(2**N - 1)
                    f.write(f'{f_hex(2**N - 1)} {f_hex(2**N - 1)}\n')
                else:
                    quo = int(num / den)
                    rmn = num % den
                    f.write(f'{f_hex(quo)} {f_hex(rmn)}\n')

if __name__ == '__main__':
    main()
