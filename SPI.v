module SPI(inclk,rst,trig,indata,
SDO,
ready, 
outdata,
N_CS,SDI,SCLK
);

parameter SPI_LENGTH=32;

input inclk,trig,rst;
input [SPI_LENGTH-1:0]indata;

input SDO;

output reg N_CS,SDI,SCLK;

output reg ready;

output reg [SPI_LENGTH-1:0]outdata;

reg init;//if SPI is inited
reg busy;//if SPI is busy
reg lastTrig;
reg [SPI_LENGTH-1:0]TXBUF;//  bits to send
reg [7:0]w;

reg[4:0] t;




always@(posedge inclk or posedge rst)
begin
	if(rst)begin//rst
		init<=1'b0;
		busy<=1'b0;
		ready<=1'b0;
		t<=5'd0;
	end
	else begin//inclk 
		if(!init)begin//
			t<=t+1'b1;
			case(t)	
				5'd1:begin N_CS<=1'b1; end
				5'd2:begin SCLK<=1'b0; end
				5'd3:begin t<=5'd0;init<=1'b1;ready<=1'b1; end
			endcase
		end
		else begin//inited
			lastTrig<=trig;
			if((trig==1'b1)&&(lastTrig==1'b0))begin//trig posedge
				busy<=1'b1;
				ready<=1'b0;
			end//trig posedge
			else begin//inclk
				if(busy)begin//busy=1
					t<=t+1'b1;
					case(t)
						5'd0:begin N_CS<=1'b0;TXBUF<=indata;w<=SPI_LENGTH-1; end
						5'd1:begin SDI<=TXBUF[w]; end
						5'd2:begin SCLK<=1'b1; end
						5'd3:begin
									outdata[w]<=SDO;
									SCLK<=1'b0; 
									if(w==8'd0)begin//done,goto 4
										t<=5'd4;
									end
									else begin//n,goto 1
										w<=w-1'b1;
										t<=5'd1;
									end
								end
						5'd4:begin busy<=0;ready<=1'b1;t<=5'd0;N_CS<=1'b1; end
						default:begin t<=5'd0; end
					endcase
				end//busy=1
				else begin//busy=0
				
				end
			end//inclk	
		end	
	end
end
endmodule 
