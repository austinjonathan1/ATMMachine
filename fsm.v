`timescale 1 ns / 1 ps

module fsm (
    output wire busy,
    input wire period_expired,
    input wire data_arrived,
    input wire val_match,
    output wire load_ptrs,
    output wire increment,
    output wire sample_capture,
    input wire clk
    );
    
    reg busy_temp, load_temp, incr_temp, sample_temp;
    reg [2:0] state, delay;

    always @ (posedge clk)
    begin
        if (state == 3'b000 && data_arrived == 1) // inital state 000 that waits for data to arrive in order to move to next state
        begin
            state = 3'b001;
            busy_temp = 1;
            incr_temp = 0;
            sample_temp = 0;
        end
        else if (state == 3'b000 && data_arrived == 0) // inital state 000 loops if data hasn't arrived
        begin
            state = 3'b000;
            busy_temp = 0;
            incr_temp = 0;
            sample_temp = 0;
        end
        else if (state == 3'b001) // once data has arrived we output that we are loading data in this state
        begin
            load_temp = 1;
            state = 3'b101;
        end
        else if (state == 3'b010 && period_expired == 1) // waits for the timer has counted a full sample period
        begin
            state = 3'b011;
            sample_temp = 0;
        end
        else if (state == 3'b011 && val_match == 1) // once the cycle is complete we go back to the idle state 000
        begin
            incr_temp = 1;
            state = 3'b000;
        end 
        else if (state == 3'b011 && val_match == 0) // incrementing pointer has not been completed, waiting for val_match before moving on
        begin
            incr_temp = 1;
            state = 3'b101;
        end 
        else if (state == 3'b100 && val_match == 1) // this state the data is capturing and waits until the pointer has reached its final address
        begin
            sample_temp = 1;
            state = 3'b000;
        end
        else if (state == 3'b100 && val_match == 0) // this state the data is capturing
        begin
            sample_temp = 1;
            state = 3'b010;
        end
        else if (state == 3'b101) // once the period has expired we use a delay to account for ROM read latency before moving onto capture state
        begin
            incr_temp = 0;
            load_temp = 0;
            delay <= delay + 1;
            if( state == 3'b101 && delay == 4)
            begin
                state = 3'b100;
                delay <= 0;
            end
        end
    end
    assign busy = busy_temp;
    assign load_ptrs = load_temp;
    assign increment = incr_temp;
    assign sample_capture = sample_temp;
endmodule
