/* This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
   
   Email : semiconductors@varkongroup.com
   Tel   : 1-732-447-8611
   
*/

/* verilator lint_off INITIALDLY */

///convert values from  power domain to decimal domain
module GF_matrix_dec(clk,re,address_read,data_out);
parameter address_width=8;
parameter data_width=8;
parameter num_words=256;
input clk,re;
input [address_width-1:0] address_read;
output [data_width-1:0] data_out;
reg [data_width-1:0] data_out;
reg [data_width-1:0] mem [0:num_words-1];
initial
begin
mem[0]<= 'b00000000;
mem[1]<= 'b00000001;
mem[2]<= 'b00000010;
mem[3]<= 'b00000100;
mem[4]<= 'b00001000;
mem[5]<= 'b00010000;
mem[6]<= 'b00100000;
mem[7]<= 'b01000000;
mem[8]<= 'b10000000;
mem[9]<= 'b00011101;
mem[10]<= 'b00111010;
mem[11]<= 'b01110100;
mem[12]<= 'b11101000;
mem[13]<= 'b11001101;
mem[14]<= 'b10000111;
mem[15]<= 'b00010011;
mem[16]<= 'b00100110;
mem[17]<= 'b01001100;
mem[18]<= 'b10011000;
mem[19]<= 'b00101101;
mem[20]<= 'b01011010;
mem[21]<= 'b10110100;
mem[22]<= 'b01110101;
mem[23]<= 'b11101010;
mem[24]<= 'b11001001;
mem[25]<= 'b10001111;
mem[26]<= 'b00000011;
mem[27]<= 'b00000110;
mem[28]<= 'b00001100;
mem[29]<= 'b00011000;
mem[30]<= 'b00110000;
mem[31]<= 'b01100000;
mem[32]<= 'b11000000;
mem[33]<= 'b10011101;
mem[34]<= 'b00100111;
mem[35]<= 'b01001110;
mem[36]<= 'b10011100;
mem[37]<= 'b00100101;
mem[38]<= 'b01001010;
mem[39]<= 'b10010100;
mem[40]<= 'b00110101;
mem[41]<= 'b01101010;
mem[42]<= 'b11010100;
mem[43]<= 'b10110101;
mem[44]<= 'b01110111;
mem[45]<= 'b11101110;
mem[46]<= 'b11000001;
mem[47]<= 'b10011111;
mem[48]<= 'b00100011;
mem[49]<= 'b01000110;
mem[50]<= 'b10001100;
mem[51]<= 'b00000101;
mem[52]<= 'b00001010;
mem[53]<= 'b00010100;
mem[54]<= 'b00101000;
mem[55]<= 'b01010000;
mem[56]<= 'b10100000;
mem[57]<= 'b01011101;
mem[58]<= 'b10111010;
mem[59]<= 'b01101001;
mem[60]<= 'b11010010;
mem[61]<= 'b10111001;
mem[62]<= 'b01101111;
mem[63]<= 'b11011110;
mem[64]<= 'b10100001;
mem[65]<= 'b01011111;
mem[66]<= 'b10111110;
mem[67]<= 'b01100001;
mem[68]<= 'b11000010;
mem[69]<= 'b10011001;
mem[70]<= 'b00101111;
mem[71]<= 'b01011110;
mem[72]<= 'b10111100;
mem[73]<= 'b01100101;
mem[74]<= 'b11001010;
mem[75]<= 'b10001001;
mem[76]<= 'b00001111;
mem[77]<= 'b00011110;
mem[78]<= 'b00111100;
mem[79]<= 'b01111000;
mem[80]<= 'b11110000;
mem[81]<= 'b11111101;
mem[82]<= 'b11100111;
mem[83]<= 'b11010011;
mem[84]<= 'b10111011;
mem[85]<= 'b01101011;
mem[86]<= 'b11010110;
mem[87]<= 'b10110001;
mem[88]<= 'b01111111;
mem[89]<= 'b11111110;
mem[90]<= 'b11100001;
mem[91]<= 'b11011111;
mem[92]<= 'b10100011;
mem[93]<= 'b01011011;
mem[94]<= 'b10110110;
mem[95]<= 'b01110001;
mem[96]<= 'b11100010;
mem[97]<= 'b11011001;
mem[98]<= 'b10101111;
mem[99]<= 'b01000011;
mem[100]<= 'b10000110;
mem[101]<= 'b00010001;
mem[102]<= 'b00100010;
mem[103]<= 'b01000100;
mem[104]<= 'b10001000;
mem[105]<= 'b00001101;
mem[106]<= 'b00011010;
mem[107]<= 'b00110100;
mem[108]<= 'b01101000;
mem[109]<= 'b11010000;
mem[110]<= 'b10111101;
mem[111]<= 'b01100111;
mem[112]<= 'b11001110;
mem[113]<= 'b10000001;
mem[114]<= 'b00011111;
mem[115]<= 'b00111110;
mem[116]<= 'b01111100;
mem[117]<= 'b11111000;
mem[118]<= 'b11101101;
mem[119]<= 'b11000111;
mem[120]<= 'b10010011;
mem[121]<= 'b00111011;
mem[122]<= 'b01110110;
mem[123]<= 'b11101100;
mem[124]<= 'b11000101;
mem[125]<= 'b10010111;
mem[126]<= 'b00110011;
mem[127]<= 'b01100110;
mem[128]<= 'b11001100;
mem[129]<= 'b10000101;
mem[130]<= 'b00010111;
mem[131]<= 'b00101110;
mem[132]<= 'b01011100;
mem[133]<= 'b10111000;
mem[134]<= 'b01101101;
mem[135]<= 'b11011010;
mem[136]<= 'b10101001;
mem[137]<= 'b01001111;
mem[138]<= 'b10011110;
mem[139]<= 'b00100001;
mem[140]<= 'b01000010;
mem[141]<= 'b10000100;
mem[142]<= 'b00010101;
mem[143]<= 'b00101010;
mem[144]<= 'b01010100;
mem[145]<= 'b10101000;
mem[146]<= 'b01001101;
mem[147]<= 'b10011010;
mem[148]<= 'b00101001;
mem[149]<= 'b01010010;
mem[150]<= 'b10100100;
mem[151]<= 'b01010101;
mem[152]<= 'b10101010;
mem[153]<= 'b01001001;
mem[154]<= 'b10010010;
mem[155]<= 'b00111001;
mem[156]<= 'b01110010;
mem[157]<= 'b11100100;
mem[158]<= 'b11010101;
mem[159]<= 'b10110111;
mem[160]<= 'b01110011;
mem[161]<= 'b11100110;
mem[162]<= 'b11010001;
mem[163]<= 'b10111111;
mem[164]<= 'b01100011;
mem[165]<= 'b11000110;
mem[166]<= 'b10010001;
mem[167]<= 'b00111111;
mem[168]<= 'b01111110;
mem[169]<= 'b11111100;
mem[170]<= 'b11100101;
mem[171]<= 'b11010111;
mem[172]<= 'b10110011;
mem[173]<= 'b01111011;
mem[174]<= 'b11110110;
mem[175]<= 'b11110001;
mem[176]<= 'b11111111;
mem[177]<= 'b11100011;
mem[178]<= 'b11011011;
mem[179]<= 'b10101011;
mem[180]<= 'b01001011;
mem[181]<= 'b10010110;
mem[182]<= 'b00110001;
mem[183]<= 'b01100010;
mem[184]<= 'b11000100;
mem[185]<= 'b10010101;
mem[186]<= 'b00110111;
mem[187]<= 'b01101110;
mem[188]<= 'b11011100;
mem[189]<= 'b10100101;
mem[190]<= 'b01010111;
mem[191]<= 'b10101110;
mem[192]<= 'b01000001;
mem[193]<= 'b10000010;
mem[194]<= 'b00011001;
mem[195]<= 'b00110010;
mem[196]<= 'b01100100;
mem[197]<= 'b11001000;
mem[198]<= 'b10001101;
mem[199]<= 'b00000111;
mem[200]<= 'b00001110;
mem[201]<= 'b00011100;
mem[202]<= 'b00111000;
mem[203]<= 'b01110000;
mem[204]<= 'b11100000;
mem[205]<= 'b11011101;
mem[206]<= 'b10100111;
mem[207]<= 'b01010011;
mem[208]<= 'b10100110;
mem[209]<= 'b01010001;
mem[210]<= 'b10100010;
mem[211]<= 'b01011001;
mem[212]<= 'b10110010;
mem[213]<= 'b01111001;
mem[214]<= 'b11110010;
mem[215]<= 'b11111001;
mem[216]<= 'b11101111;
mem[217]<= 'b11000011;
mem[218]<= 'b10011011;
mem[219]<= 'b00101011;
mem[220]<= 'b01010110;
mem[221]<= 'b10101100;
mem[222]<= 'b01000101;
mem[223]<= 'b10001010;
mem[224]<= 'b00001001;
mem[225]<= 'b00010010;
mem[226]<= 'b00100100;
mem[227]<= 'b01001000;
mem[228]<= 'b10010000;
mem[229]<= 'b00111101;
mem[230]<= 'b01111010;
mem[231]<= 'b11110100;
mem[232]<= 'b11110101;
mem[233]<= 'b11110111;
mem[234]<= 'b11110011;
mem[235]<= 'b11111011;
mem[236]<= 'b11101011;
mem[237]<= 'b11001011;
mem[238]<= 'b10001011;
mem[239]<= 'b00001011;
mem[240]<= 'b00010110;
mem[241]<= 'b00101100;
mem[242]<= 'b01011000;
mem[243]<= 'b10110000;
mem[244]<= 'b01111101;
mem[245]<= 'b11111010;
mem[246]<= 'b11101001;
mem[247]<= 'b11001111;
mem[248]<= 'b10000011;
mem[249]<= 'b00011011;
mem[250]<= 'b00110110;
mem[251]<= 'b01101100;
mem[252]<= 'b11011000;
mem[253]<= 'b10101101;
mem[254]<= 'b01000111;
mem[255]<= 'b10001110;
end 
always @ (posedge(clk))
begin
	if (re==1'b1)
		begin
			data_out <= mem[address_read];
		end
end
endmodule
