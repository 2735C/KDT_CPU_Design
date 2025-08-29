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

### (1) ISA & BlockDiagram

<img src="/History/img/ISA.png" width=600>|
--|

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

<img src="/History/img/I-type1.png" width=1000>|
--|
<img src="/History/img/I-type2.png" width=1000>|


```systemverilog
// I Type
// rom[x] =     imm(12)     rs1   f3  rd    opcode           rd   rs1 imm
rom[10] = 32'b000000001011_00001_000_00100_0010011; // ADDI  x4   x1  11  => x4:  11 + 12 => 23
rom[11] = 32'b000000001011_00101_010_01001_0010011; // SLTI  x9   x5  11  => x9:  (-2 < 11) ? 1 : 0 => 1
rom[12] = 32'b000000001011_00001_011_01010_0010011; // SLTIU x10  x5  11  => x10: ((unsigned)-2 < 11) ? 1 : 0   => 0
rom[13] = 32'b000000001101_00001_100_01011_0010011; // XORI  x11  x1  13  => x11: (1011) ^ (1101) =>  6
rom[14] = 32'b000000001101_00001_110_01100_0010011; // ORI   x12  x1  13  => x12: (1011) | (1101) =>15
rom[15] = 32'b000000001101_00001_111_01101_0010011; // ANDI  x13  x1  13  => x13: (1011) & (1101) => 9

// I Type (shift)
// rom[x] = imm(12)   shift  rs1   f3  rd    opcode           rd   rs1 imm
rom[16] = 32'b0000000_01011_00011_001_00110_0010011; // SLLI  x6   x3 11 => x6: 13 << 11 =>  26,624
rom[17] = 32'b0000000_01011_00101_101_00111_0010011; // SRLI  x7   x5 11 => x7: -2 >> 11 =>2,097,151
rom[18] = 32'b0100000_01011_00101_101_01000_0010011; // SRAI  x8   x5 11 => x8: -2 >>> 11 => -1
rom[19] = 32'b111110000000_00000_000_01110_0010011; // ADDI  x14   x0  -128  => 1000_0000 for sb 
rom[20] = 32'b100000000000_00000_000_01111_0010011; // ADDI  x15   x0  -2048 => 0000_1000_0000_0000 for sh
rom[21] = 32'b000111110100_00000_000_10000_0010011; // ADDI  x16   x0   500  => 0001 1111 0100 for sw
```

> ### S-type

<img src="/History/img/S-type1.png" width=1000>|
--|
<img src="/History/img/S-type2.png" width=1000>|

```systemverilog
// S Type
// rom[x] =    imm(7)  rs2   rs1  f3  imm(5) opcode        rs2 rs1 imm
rom[22] = 32'b0000000_01110_00000_000_01000_0100011; // SB x14  x0  16 => mem [x0 +16] = x14
rom[23] = 32'b0000000_01111_00000_001_01010_0100011; // SH x15  x0  10 => mem [x0 +10] = x15
rom[24] = 32'b0000000_10000_00000_010_01100_0100011; // SW x16  x0  12 => mem [x0 +12] = x16
```

> ### L-type


<img src="/History/img/L-type1.png" width=1000>|
--|
<img src="/History/img/L-type2.png" width=1000>|

```systemverilog
// L Type
// rom[x] =      imm(12)    rs1   f3   rd  opcode           rd  rs1 imm
rom[25] = 32'b000000001000_00000_000_00100_0000011; // LB   x4  x0  16  => regFile[x0+16] = -128   rom[26] = 32'b000000001010_00000_001_00101_0000011; // LH   x5  x0  10  => regFile[x0+10] = -2048
rom[27] = 32'b000000001100_00000_010_00110_0000011; // LW   x6  x0  12  => regFile[x0+12] = 500
rom[28] = 32'b000000001000_00000_100_00111_0000011; // LBU  x7  x0  16  => regFile[x0+16] = 128
rom[29] = 32'b000000001010_00000_101_01000_0000011; // LHU  x8  x0  10  => regFile[x0+10] = 63488
```

> ### LU, AU, J, JL-type


<img src="/History/img/things-type1.png" width=1000>|
--|
<img src="/History/img/things-type2.png" width=1000>|

```systemverilog
// LU Type  (LUI)      
// rom[x] =         imm(20)        rd  opcode
rom[30] = 32'b00000000000000000001_00100_0110111;    // LUI x4 1  => 1 << 12 = 4096

// AU Type  (AUIPC)   
// rom[x] =         imm(20)        rd  opcode
rom[31] = 32'b00000000000000000001_00101_0010111;    // AUIPC x5 5 => PC(124) + (4096) = 4220
// J Type  (JAL) 

// rom[x] = imm([20][10:1][11][19:12])  rd  opcode
rom[32] = 32'b0_0000000100_0_00000000_00110_1101111; // JAL  x6  8 => rd = 128 + 4 = 132, PC = PC + 8 = 136

// JL Type (JALR)
// rom[x] =      imm(12)     rs1  f3  rd    opcode
rom[34] = 32'b000001111111_00011_000_00111_1100111; // JALR x7 x4 127 => rd = 136 + 4 = 140, PC = 13 + 127 = 140
```

> ### B-type

<img src="/History/img/B-type1.png" width=1000>|
--|
<img src="/History/img/B-type2.png" width=1000>|

```systemverilog
// B Type
// rom[x] =    mm(7)   rs2   rs1  f3  imm(5) opcode
rom[35] = 32'b0000000_00001_00001_000_01000_1100011; // BEQ  x1  x1  8 => 108 -> 116
rom[36] = 32'b0000000_00010_00001_001_01000_1100011; // BNE  x1  x2  8 => 116 -> 124
rom[37] = 32'b0000000_00010_00001_100_01000_1100011; // BLT  x1  x2  8 => 124 -> 132
rom[38] = 32'b0000000_00011_00001_101_01000_1100011; // BGE  x1  x3  8 => 132 -> 140
rom[39] = 32'b0000000_00010_00001_110_01000_1100011; // BLTU x1  x2  8 => 140 -> 148
rom[40] = 32'b0000000_00010_00011_111_01000_1100011; // BGEU x3  x2  8 => 148 -> 156
```


### (3) C test Program


> ### Bubble Sort(C) 

```systemverilog
void sort(int *pData, int size);
void swap(int *pA, int *pB);

int main() {
    int arData[6] = {5,4,3,2,1};
    sort(arData,5);
    return 0;
}

void sort(int *pData, int size) 
{
  for(int i=0;i<size;i++){
      for(int j=0;j<size-i-1;j++){
          if(pData[j]>pData[j+1]){
              swap(&pData[j], &pData[j+1]);
          }
      }
  }
}

void swap(int *pA, int *pB)
{
  int temp;
  temp = *pA;
  *pA = *pB;
  *pB = temp;
}
```

> ### Bubble Sort(Assembly) 

초기화 조건 | 재정렬(Swap) 조건 | Swap function|
--|--|--
<img src="/History/img/git_bubble13_assembly.png" width=450>|<img src="/History/img/git_bubble16_assembly.png" width=250>|<img src="/History/img/git_bubble15_assembly.png" width=300>|


> #### 초기화 조건

<img src="/History/img/git_bubble1.png" width=1000>|
--|
<img src="/History/img/git_bubble2.png" width=1000>|

> #### Sort 함수: Main :arrow_right:  Sort, Sort :arrow_right: Main

<img src="/History/img/git_bubble3.png" width=1000>|
--|
<img src="/History/img/git_bubble7.png" width=1000>|


> #### Swap 함수: Sort :arrow_right: Swap, Swap :arrow_right: Sort

<img src="/History/img/git_bubble4.png" width=1000>|
--|
<img src="/History/img/git_bubble5.png" width=1000>|
<img src="/History/img/git_bubble6.png" width=1000>|



## Trouble Shooting 


#### P. B-type 실행 시 ROM에 넣은 명령어가 출력되지 않음  trouble_shooting3.png

<img src="/History/img/trouble_shooting3.png" width=1000>|
--|

#### S. PC가 바뀌는 크기에 따라 ROM 번호도 같은 크기로 증가시켜 줌

<img src="/History/img/trouble_shooting4.png" width=1000>|
--|