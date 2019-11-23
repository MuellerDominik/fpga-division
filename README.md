# fpga-division

> Division Algorithms in FPGAs

## Algorithms

The following two algorithms are being examined:

### Repeated subtraction (Rept. -)

#### C style pseudocode:

```C
uint<N>_t numerator = num;        // input
uint<N>_t denominator = den;      // input

uint<N>_t quotient = 0;

while (numerator >= denominator) {
  numerator -= denominator;
  ++quotient;
}

uint<N>_t quo = quotient;         // output
uint<N>_t rmn = numerator;        // output
```

### SRT division

The implemented algorithm is documented in [a `.ppt` about computer arithmetic](http://cs.uccs.edu/~cs520/) from the UCCS.

#### C style pseudocode:

```C
uint<2*N + 1>_t numerator = num;  // input
uint<N>_t denominator = den;      // input

uint<N>_t quotient = 0;
uint<N>_t remainder = 0;
uint<log2(N-1)>_t k;
uint<N>_t ap = 0;
uint<N>_t an = 0;

k = leading_zeros(denominator);
denominator <<= k;
numerator <<= k;

for (int i = 0; i < N; ++i) {
  switch (top_3_bits(numerator)) {
    case 0:
    case 7:
      ap <<= 1;
      an <<= 1;
      numerator <<= 1;
      break;
    case 4:
    case 5:
    case 6:
      ap <<= 1;
      an = (an << 1) | 1;
      numerator <<= 1;
      numerator += (denominator << N);
      break;
    default:  // case 1, 2, 3
      ap = (ap << 1) | 1;
      an <<= 1;
      numerator <<= 1;
      numerator -= (denominator << N);
      break;
  }
}

quotient = ap - an;
remainder = numerator >> N;

if (msb(numerator) == 1) {
  remainder += denominator;
  --quotient;
}

uint<N>_t quo = quotient;         // output
uint<N>_t rmn = remainder >> k;   // output
```

**Notes:**
* `ap` can be integrated into the N LSBs of the `numerator` to save N flip-flops (see VHDL code) <br>
* `numerator` is named `p` in the VHDL code (named `(P,A)` in the `.ppt`)
* `num` is named `A` and `den` is named `B` in the `.ppt`

## Performance (ATTL)

The performance of the algorithms is measured in termns of area, timing, throughput and latency (ATTL).

### Iterative Approach

<table>
  <thead>
    <tr>
      <th rowspan=2></th>
      <th colspan=2>10 bits</th>
      <th colspan=2>12 bits</th>
      <th colspan=2>N bits</th>
    </tr>
    <tr>
      <th>Rept. -</td>
      <th>SRT</td>
      <th>Rept. -</td>
      <th>SRT</td>
      <th>Rept. -</td>
      <th>SRT</td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th align="left">Area (#ff)</th>
      <td>a</td>
      <td>b</td>
      <td>c</td>
      <td>d</td>
      <td>?</td>
      <td>?</td>
    </tr>
    <tr>
      <th align="left">Timing (MHz)</th>
      <td>x</td>
      <td>y</td>
      <td>x</td>
      <td>y</td>
      <td>x</td>
      <td>y</td>
    </tr>
    <tr>
      <th align="left">Throughput (bits/clk)</th>
      <td>2.3</td>
      <td>1</td>
      <td>2.4</td>
      <td>1</td>
      <td>?</td>
      <td>1</td>
    </tr>
    <tr>
      <th align="left">Avg. Latency (#clk)</th>
      <td>4.3 *)</td>
      <td>10</td>
      <td>5.0 *)</td>
      <td>12</td>
      <td>?</td>
      <td>N</td>
    </tr>
  </tbody>
</table>

\*) Determined by Simulation <br>
**a**, **b**, **c**, **d**, **x**, **y**: TBD

### Unrolled Approach

<table>
  <thead>
    <tr>
      <th rowspan=2></th>
      <th colspan=2>10 bits</th>
      <th colspan=2>12 bits</th>
      <th colspan=2>N bits</th>
    </tr>
    <tr>
      <th>Rept. -</td>
      <th>SRT</td>
      <th>Rept. -</td>
      <th>SRT</td>
      <th>Rept. -</td>
      <th>SRT</td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th align="left">Area (#ff)</th>
      <td>a</td>
      <td>b</td>
      <td>c</td>
      <td>d</td>
      <td>?</td>
      <td>?</td>
    </tr>
    <tr>
      <th align="left">Timing (MHz)</th>
      <td>u</td>
      <td>v</td>
      <td>w</td>
      <td>x</td>
      <td>?</td>
      <td>?</td>
    </tr>
    <tr>
      <th align="left">Throughput (bits/clk)</th>
      <td>2.3 * M</td>
      <td>M</td>
      <td>2.4 * M</td>
      <td>M</td>
      <td>?</td>
      <td>M</td>
    </tr>
    <tr>
      <th align="left">Avg. Latency (#clk)</th>
      <td>4.3 / M</td>
      <td>10 / M</td>
      <td>5.0 / M</td>
      <td>12 / M</td>
      <td>?</td>
      <td>N / M</td>
    </tr>
  </tbody>
</table>

**M**: Iterations per Cycle <br>
**a**, **b**, **c**, **d**, **u**, **v**, **w**, **x**: TBD

## License

Copyright &copy; 2019 Dominik Müller and Nico Canzani

This project is licensed under the terms of the Apache License 2.0 - see the [LICENSE](LICENSE "LICENSE") file for details
