# 💫RISC-V 32bit CPU Design

## 🖊️Role

### 정은지



## 💻개발 환경 <br>

<table border="1" cellspacing="0" cellpadding="5">
  <tr>
    <td align="center" colspan="5"> Tool </td>
    <td align="center" colspan="2"> Language </td>
  </tr>
  <tr>
    <td align="center"> VCS </td>
    <td align="center"> Verdi </td>
    <td align="center"> Vivado </td>
    <td align="center"> VS Code </td>
    <td align="center"> mobaXterm </td>
    <td align="center"> Systemverilog </td>
    <td align="center"> C </td>
  </tr>
  <tr>
    <td colspan="2"><img src="/History/img/img1.png" width=300>  </td>
    <td align="center"> <img src="/History/img/img2.png" width=200>  </td>
    <td align="center"> <img src="/History/img/img3.png" width=250>  </td>
    <td align="center"> <img src="/History/img/img6.jpg" width=100>  </td>
    <td align="center"> <img src="/History/img/img4.png" width=200>  </td>
    <td align="center"> <img src="/History/img/img5.png" width=100>  </td>
  </tr>
</table>


[[연구 배경]](/History/Progress_report/overview.md)

## 🚀프로젝트 개요
 
본 프로젝트는 RV32I 기반으로 Multi-Cycle CPU 설계하고 Bubble Sort C Code를 통해 검증을 진행하였다. 
 

## 🗓️개발 일정 250812~250824

## 개발 과정

> Multi-Cycle로 진행한 이유

### (1) 블록도

<img src="/History/img/img7.png" width=600>|
--|


### (2) Verification


> ### R-type

<img src="/History/img/R-type1.png" width=1000>|
--|
<img src="/History/img/R-type2.png" width=1000>|

```systemverilog
// R Type
// rom[x] =    func7  rs2   rs1  fc3   rd   opcode           rd   rs1 rs2
rom[0] = 32'b0000000_00010_00001_000_00100_0110011; // ADD   x4   x1  x2  =>  x4:  11 + 12 => 23                 
rom[1] = 32'b0100000_00011_00001_000_00101_0110011; // SUB   x5   x1  x3  =>  x5:  11 - 13 => -2
rom[2] = 32'b0000000_00001_00011_001_00110_0110011; // SLL   x6   x3  x1  =>  x6:  13 << 11 =>  26,624
rom[3] = 32'b0000000_00001_00101_101_00111_0110011; // SRL   x7   x5  x1  =>  x7:  -2 >> 11 =>2,097,151
rom[4] = 32'b0100000_00001_00101_101_01000_0110011; // SRA   x8   x5  x1  =>  x8:  -2 >>> 11 => -1
rom[5] = 32'b0000000_00001_00101_010_01001_0110011; // SLT   x9   x5  x1  =>  x9:  (-2 < 11) ? 1 : 0 => 1       
rom[6] = 32'b0000000_00001_00101_011_01010_0110011; // SLTU  x10  x5  x1  =>  x10: ((unsigned)-2 < 11) ? 1 : 0   => 0
rom[7] = 32'b0000000_00011_00001_100_01011_0110011; // XOR   x11  x1  x3  =>  x11: (1011) ^ (1101) =>  6
rom[8] = 32'b0000000_00011_00001_110_01100_0110011; // OR    x12  x1  x3  =>  x12: (1011) | (1101) =>15
rom[9] = 32'b0000000_00011_00001_111_01101_0110011; // AND   x13  x1  x3  =>  x13: (1011) & (1101) => 9
```

- 어디를 거쳐 어떻게 어쩌구 


> ### I-type





> ### S-type

> ### L-type

> ### B-type

> ### LU, AU, J, JL-type

### (3) C test Program

## Trouble Shooting 
