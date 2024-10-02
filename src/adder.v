module CLA(input [3:0] a, input [3:0] b, input c0, output [3:0] answer, output carry);
    wire g0, g1, g2, g3, p0, p1, p2, p3;
    wire c1, c2, c3;

    assign g0 = a[0] & b[0];
    assign g1 = a[1] & b[1];
    assign g2 = a[2] & b[2];
    assign g3 = a[3] & b[3];

    assign p0 = a[0] ^ b[0];
    assign p1 = a[1] ^ b[1];
    assign p2 = a[2] ^ b[2];
    assign p3 = a[3] ^ b[3];

    assign c1 = (p0 & c0) | g0;
    assign c2 = (p1 & g0) | (p1 & p0 & c0) | g1;
    assign c3 = (p2 & g1) | (p2 & p1 & g0) | (p2 & p1 & p0 & c0) | g2;
    assign carry = (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0 & c0) | g3;

    assign answer = {p3^c3, p2^c2, p1^c1, p0^c0};
endmodule

module CLA16(input [15:0] a, input [15:0] b, input c0, output [15:0] answer, output carry);
    wire [3:0] g0, g1, g2, g3, p0, p1, p2, p3;
    wire c1, c2, c3;

    CLA cla1(a[3:0], b[3:0], c0, answer[3:0], c1);
    CLA cla2(a[7:4], b[7:4], c1, answer[7:4], c2);
    CLA cla3(a[11:8], b[11:8], c2, answer[11:8], c3);
    CLA cla4(a[15:12], b[15:12], c3, answer[15:12], carry);
endmodule


module Add(input [31:0] a, input [31:0] b, output [31:0] sum);
    wire [15:0] dout1, dout2;
    wire carry1;
    wire carry; //not used in fact

    CLA16 c1(a[15:0], b[15:0], 1'b0, dout1, carry1);
    CLA16 c2(a[31:16], b[31:16], carry1, dout2, carry);

    assign sum = {dout2, dout1};
endmodule


module test;
	wire [31:0] answer;
	wire 		carry;
	reg  [31:0] a, b;
	reg	 [32:0] res;

	Add Add(a, b, answer);
	integer i;
    initial begin
		for(i=1; i<=100; i=i+1) begin
			a[31:0] = $random;
			b[31:0] = $random;
			res		= a + b;
			
			#1;
			$display("TESTCASE %d: %d + %d = %d carry: %d", i, a, b, answer, carry);

			if (answer !== res[31:0]) begin
				$display("Wrong Answer!");
			end
		end
		$display("Congratulations! You have passed all of the tests.");
		$finish;
	end
endmodule