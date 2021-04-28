////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	fft_tb.cpp
//
// Project:	A General Purpose Pipelined FFT Implementation
//
// Purpose:	A test-bench for the main program, fftmain.v, of the double
//		clocked FFT.  This file may be run autonomously  (when
//	fully functional).  If so, the last line output will either read
//	"SUCCESS" on success, or some other failure message otherwise.
//
//	This file depends upon verilator to both compile, run, and therefore
//	test fftmain.v
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015-2020, Gisselquist Technology, LLC
//
// This program is free software (firmware): you can redistribute it and/or
// modify it under the terms of  the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program.  (It's in the $(ROOT)/doc directory.  Run make with no
// target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	GPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/gpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <fftw3.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vfftmain.h"
#include "twoc.h"

#include "fftsize.h"

using namespace std;

#define	IWIDTH	FFT_IWIDTH
#define	OWIDTH	FFT_OWIDTH
#define	LGWIDTH	FFT_LGWIDTH

#if (IWIDTH > 16)
typedef	unsigned long	ITYP;
#else
typedef	unsigned int	ITYP;
#endif

#if (OWIDTH > 16)
typedef	unsigned long	OTYP;
#else
typedef	unsigned int	OTYP;
#endif

#define	NFTLOG	16
#define	FFTLEN	(1<<LGWIDTH)

#ifdef	FFT_SKIPS_BIT_REVERSE
#define	APPLY_BITREVERSE_LOCALLY
#endif

unsigned long bitrev(const int nbits, const unsigned long vl) {
	unsigned long	r = 0;
	unsigned long	val = vl;

	for(int k=0; k<nbits; k++) {
		r<<= 1;
		r |= (val & 1);
		val >>= 1;
	}

	return r;
}

class	FFT_TB {
public:
	Vfftmain	*m_fft;
	int		m_iaddr, m_oaddr, m_ntest, m_logbase;
	bool		m_syncd;
	unsigned long	m_tickcount;
	VerilatedVcdC*	m_trace;
	vector<OTYP> output;

	FFT_TB(void) {
		m_fft = new Vfftmain;
		Verilated::traceEverOn(true);
		m_iaddr = m_oaddr = 0;

		m_syncd = false;
		m_ntest = 0;
	}

	~FFT_TB(void) {
		closetrace();
		delete m_fft;
		m_fft = NULL;
	}

	virtual void opentrace(const char *vcdname) {
		if (!m_trace) {
			m_trace = new VerilatedVcdC;
			m_fft->trace(m_trace, 99);
			m_trace->open(vcdname);
		}
	}

	virtual void closetrace(void) {
		if (m_trace) {
			m_trace->close();
			delete m_trace;
			m_trace = NULL;
		}
	}

	void	tick(void) {
		m_tickcount++;

		m_fft->i_clk = 0;
		m_fft->eval();
		if (m_trace)
			m_trace->dump((vluint64_t)(10*m_tickcount-2));
		m_fft->i_clk = 1;
		m_fft->eval();
		if (m_trace)
			m_trace->dump((vluint64_t)(10*m_tickcount));
		m_fft->i_clk = 0;
		m_fft->eval();
		if (m_trace) {
			m_trace->dump((vluint64_t)(10*m_tickcount+5));
			m_trace->flush();
		}
	}

	void	reset(void) {
		m_tickcount = 0l;
		m_fft->i_ce  = 0;
		m_fft->i_reset = 1;
		tick();
		m_fft->i_reset = 0;
		tick();

		m_iaddr = m_oaddr = m_logbase = 0;
		m_syncd = false;
		//m_tickcount = 0l;
	}

	bool	test(ITYP data) {
		m_fft->i_ce    = 1;
		m_fft->i_reset = 0;
		m_fft->i_sample  = data;

		tick();

		if (m_fft->o_sync) {
			if (!m_syncd) {
				output.push_back(m_fft->o_result);
			}
			m_syncd = true;
		}

		if (m_syncd & m_fft->o_sync) {
			return true;
		} else {
			if (m_syncd) {
				output.push_back(m_fft->o_result);
			}
			return false;
		}

	}
};


int	main(int argc, char **argv, char **envp) {
	Verilated::commandArgs(argc, argv);
	FFT_TB *fft = new FFT_TB;

	fft->opentrace("fft.vcd");
	fft->reset();

	ifstream ifs_input("data_in.raw");
	ifstream ifs_expected("expected.iq");
	vector<unsigned int> input;
	vector<string> expected;

	string line;
	while (getline(ifs_input, line)) {
		istringstream iss(line);
		unsigned int n;
		iss >> n;
		input.push_back(n);
	}

	while (getline(ifs_expected, line)) {
		istringstream iss(line);
		expected.push_back(line);
	}

	for (int k = 0; k < input.size(); k++) {
		fft->test(input[k]);
	}

	bool syncd = false;
	for (int k = 0; k < input.size()*4; k++) {
		bool w = fft->test(0);
		if (w && syncd) {
			break;
		} else if (w) {
			syncd = true;
		}
	}

	OTYP mask = (1 << FFT_OWIDTH) - 1;
	cout << "Output\t\t\tExpected" << endl;
	for (int k = 0; k < fft->output.size(); k++) {
		cout << "(";
		OTYP r = fft->output[k];
		OTYP a = (r >> FFT_OWIDTH) & mask;
		OTYP b = r & mask;
		if (a & (1 << (FFT_OWIDTH-1)))
			cout << "-" << (((~a)+1) & mask);
		else
			cout << "+" << a;
		if (b & (1 << (FFT_OWIDTH-1)))
			cout << "-" << (((~b)+1) & mask) << "j";
		else
			cout << "+" << b << "j";
		cout << ")";
		cout << "\t\t";
		cout << expected[k];
		cout << endl;
	}

	exit(0);
}


