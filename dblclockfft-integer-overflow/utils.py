import random

def twos_comp_from_int(val, bits):
    """compute the 2's complement of int value val"""
    assert val >= -2**(bits-1), f'{val} < -2**({bits}-1)'
    assert val < 2**(bits-1), f'{val} > 2**({bits}-1)'
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val & (2**bits-1)           # return positive value as is


def int_from_twos_comp(binary, bits):
    assert binary & (2**bits - 1) == binary, f'0b{binary:0b} & (2**{bits} - 1) == 0b{binary:0b}'
    val = binary & ~(2**(bits - 1)) 
    if binary & 2**(bits - 1): 
        val -= 2**(bits - 1) 
    return val


def parse_output(data, w):
    ret = []
    for comp in data:
        real = (comp >> w) & (2**w - 1)
        imag = (comp >> 0) & (2**w - 1)
        ret.append((int_from_twos_comp(real, w),
                    int_from_twos_comp(imag, w)))
    return ret

def random_complex(w):
    real, imag = random.getrandbits(w), random.getrandbits(w)
    return complex(int_from_twos_comp(real, w), int_from_twos_comp(imag, w))

def generate_data(w, length):
    return [random_complex(w) for _ in range(length)]

def almostEqual(data, ref, margin=5):
    ret = []
    for d, r in zip(data, ref):
        err = abs(d - r)
        print(f'd, r = {d, r} (err = {err})')
        ret.append(bool(err <= margin))
    return ret

def complex2rtl(data, width):
    twos_comp = [(twos_comp_from_int(int(c.real), width),
                  twos_comp_from_int(int(c.imag), width)) for c in data]
    tmp = [imag | (real << width) for real, imag in twos_comp]
    return tmp

def rtl2complex(data, width):
    do = [complex(real, imag) for real, imag in parse_output(data, width)]
    return do