import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from cocotb.regression import TestFactory as TF
from cocotb.result import TestFailure
from utils import *

import random
import os
from scipy import signal
import numpy as np

input_w = 16
output_w = 20
fft_length = 128
clk_period = 10

random.seed()

def create_clock(dut):
    cocotb.fork(Clock(dut.i_clk, clk_period, 'ns').start())


@cocotb.coroutine
def reset(dut):
    dut.i_ce <= 0
    dut.i_sample <= 0
    dut.i_reset <= 1
    yield RisingEdge(dut.i_clk)
    yield RisingEdge(dut.i_clk)


@cocotb.coroutine
def receive(dut, buff, qty=None):
    if qty is None:
        qty = fft_length
    while True:
        yield RisingEdge(dut.i_clk)
        try:
            if dut.o_sync.value.integer:
                break
        except:
            pass

    buff.append(dut.o_result.value.integer)
    n = 1
    while n < qty:
        yield RisingEdge(dut.i_clk)
        buff.append(dut.o_result.value.integer)
        n += 1


@cocotb.coroutine
def write_data(dut, data):
    dut.i_reset <= 0
    dut.i_ce <= 1
    for d in data:
        dut.i_sample <= d
        yield RisingEdge(dut.i_clk)
    dut.i_sample <= 0


def verify_data(data_in, data_out):
    from scipy.fft import fft, ifft
    assert len(data_in) == len(data_out), (
        f'{len(data_in)} == {len(data_out)}')
    
    complex_di = rtl2complex(data_in, input_w)
    complex_do = rtl2complex(data_out, output_w)
    expected_do = fft(complex_di)
    gain = abs(complex_do[0]) / abs(expected_do[0])
    expected_do = [round(x * gain) for x in expected_do] # match amplitudes

    print(f'> complex_di:')
    print(f'> {complex_di}')
    print(f'> complex_do:')
    print(f'> {complex_do}')
    print(f'> expected:')
    print(f'> {expected_do}')
    assert len(complex_do) == len(expected_do)
    if not min(almostEqual(complex_do, expected_do)):
        # at least one element differs... dump
        with open('data_in.raw', 'w') as f:
            f.write('\n'.join([str(d) for d in data_in]))
        with open('data_out.raw', 'w') as f:
            f.write('\n'.join([str(d) for d in data_out]))
        with open('data_in.iq', 'w') as f:
            f.write('\n'.join([str(d) for d in complex_di]))
        with open('data_out.iq', 'w') as f:
            f.write('\n'.join([str(d) for d in complex_do]))
        with open('expected.iq', 'w') as f:
            f.write('\n'.join([str(d) for d in expected_do]))
        raise TestFailure('Data does not match!')

@cocotb.coroutine
def check_fft(dut, dummy=0):
    create_clock(dut)
    yield reset(dut)

    o_buff = []
    data_in = [random.getrandbits(2 * input_w) for _ in range(fft_length)]
    rx = cocotb.fork(receive(dut, o_buff, fft_length))
    yield write_data(dut, data_in)
    yield rx.join()

    verify_data(data_in, o_buff)


tf_check_fft = TF(check_fft)
# tf_check_fft.add_option('dummy', [0] * 5)
tf_check_fft.generate_tests()
