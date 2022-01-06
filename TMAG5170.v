module TMAG5170(inclk,trig,rst,spi_ready,tirg_out,channel,outdata);

//


input inclk,trig,rst,spi_ready;

output reg tirg_out;

output reg [31:0]outdata;

output reg[1:0]channel;

reg init;
reg lastTrig;


reg[5:0] t;

reg SPI_send;



always@(posedge inclk or posedge rst)
begin
	if(rst)begin//rst
		init<=1'b0;
		t<=0;
		tirg_out<=1'b0;
		
		channel<=2'b00;
		SPI_send<=1'b0;
		outdata<=0;
	end//rst
	else begin//inclk
		lastTrig<=trig;
		
		if((trig==1'b1)&&(lastTrig==1'b0))begin//trig posedge
			if(init)begin
				tirg_out<=1'b1;
			end
			else begin
				tirg_out<=1'b0;
			end
		end//trig posedge
		else begin//!trig posedge
			init=1'b1;
			tirg_out<=1'b0;
			if(tirg_out==1'b1||!init)begin//
				t<=t+1'b1;
				channel<=t[1:0];
				case(t)	
					0 :begin outdata<=32'h8d000001; end//INFO
					1 :begin outdata<=32'h00400806; end//DEVICE
					2 :begin outdata<=32'h0103aa05; end//SENSOR
					3 :begin outdata<=32'h02000000; end//SYSTEM		
					4 :begin outdata<=32'h0f000407; end//TEST
					5 :begin outdata<=32'h11000000; end//MAG
					6 :begin outdata<=32'h00002808; end//START

					7 :begin outdata<=32'h89000000; end
					8 :begin outdata<=32'h89000000; end
					9 :begin outdata<=32'h8A000004; end
					10:begin outdata<=32'h8B000009; end
					11:begin outdata<=32'h8C00000c;t<=8; end						
					default:begin t<=6'd0;init<=1'b0;tirg_out<=1'b0; end
				endcase	
			end
			else begin
			
			end				

		end//!trig posedge

	end//inclk	
end
endmodule 
