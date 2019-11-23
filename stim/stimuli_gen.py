#!/usr/bin/env python3

import math

N = 10

def f_hex(value):
    length = math.ceil(N/4)
    return f'{"0"*(length-len(hex(value)[2:]))}{hex(value)[2:]}'

def main():
    with open('div_stimuli.txt', 'w') as f:
        for num in range(2**N):
            for den in range(2**N):
                f.write(f'{f_hex(num)} {f_hex(den)} ')
                if den == 0:
                    f.write(f'{f_hex(0)} {f_hex(0)}\n')
                else:
                    quo = int(num / den)
                    rem = num % den
                    f.write(f'{f_hex(quo)} {f_hex(rem)}\n')

if __name__ == '__main__':
    main()
