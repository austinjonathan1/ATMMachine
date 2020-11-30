`timescale 1 ns / 1 ps

module narrator (
    input wire clk, zero_in, one_in, two_in, three_in, four_in, five_in, six_in, seven_in, eight_in, nine_in,
    input wire card_in_t, finish_t, balance_check_t, rapid_withdrawal_t, withdrawal_t, deposit_t, 
    output wire card_valid, card_invalid, balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in, cash_dispensed, red_led, green_led,
    output wire speaker, an3, an2, an1, an0, ca, cb, cc, cd, ce, cf, cg
    );
    
    wire one, two, three, four, five, six, seven, eight, nine, zero, card_in, finish, balance_check, rapid_withdrawal, withdrawal, deposit, write, busy;
    wire [1:0] digit_one_detection, digit_two_detection, digit_three_detection, digit_four_detection;
    wire [3:0] digit_one_value, digit_two_value, digit_three_value, digit_four_value;
    wire [3:0] test_one, test_two, test_three, test_four;
    wire [3:0] pass_one, pass_two, pass_three, pass_four;
    wire [3:0] bal_one, bal_two, bal_three, bal_four;
    wire [3:0] with_one, with_two, with_three, with_four;
    wire [3:0] depo_one, depo_two, depo_three, depo_four;
    
    reg clk2_r, red_led_r, green_led_r, cash_dispensed_r, balance_state, done = 0;
    reg [1:0] globalCounter, rapid_withdrawal_state, withdrawal_state, deposit_state;
    reg [5:0] data;
    reg [6:0] counter = 0;
    reg [13:0] counter_1;
    reg [15:0] total, bank_balance = 14'd99;
    reg [31:0] clock_counter;

    assign red_led = red_led_r;
    assign green_led = green_led_r;
    assign cash_dispensed = cash_dispensed_r;

    always @ (posedge clk_slow)
    begin
        clock_counter <= clock_counter + 1;
        if (finish)
        begin
            rapid_withdrawal_state <= 0;
            withdrawal_state <= 0;
            deposit_state <= 0;
            balance_state <= 0;
        end
        else if (clock_counter == 32'b11111111111111) // once this value is met, allows for more passcode attemps
        begin
            red_led_r <= 0;
            green_led_r <= 0;
            cash_dispensed_r <= 0;
            clock_counter <= 32'b0;
        end
        else if (balance_check && card_valid)
        begin
            withdrawal_state <= 0;
            rapid_withdrawal_state <= 0;
            deposit_state <= 0;
            balance_state <= balance_state + 1;
        end
        else if (rapid_withdrawal && card_valid) 
        begin
            withdrawal_state <= 0;
            deposit_state <= 0;
            balance_state <= 0;
            rapid_withdrawal_state <= rapid_withdrawal_state + 1;
        end
        else if (withdrawal && card_valid)
        begin
            rapid_withdrawal_state <= 0;
            deposit_state <= 0;
            balance_state <= 0;
            withdrawal_state <= withdrawal_state + 1;
        end
        else if (deposit && card_valid)
        begin
            rapid_withdrawal_state <= 0;
            withdrawal_state <= 0;
            balance_state <= 0;
            deposit_state <= deposit_state + 1;
        end
        else if (bank_balance >= 14'd100 && rapid_withdrawal_state == 2'b10) 
        begin
            clock_counter <= 32'b00000000;
            cash_dispensed_r <= 1;
            green_led_r <= 1;
            bank_balance <= bank_balance - 100;
            rapid_withdrawal_state <= 0;
            withdrawal_state <= 0;
            deposit_state <= 0;
            balance_state <= 0;
        end
        else if (bank_balance < 14'd100 && rapid_withdrawal_state == 2'b10) 
        begin
            clock_counter <= 32'b00000000;
            red_led_r <= 1;
            rapid_withdrawal_state <= 0;
            withdrawal_state <= 0;
            deposit_state <= 0;
            balance_state <= 0;
        end
        else if (bank_balance >= total && withdrawal_state == 2'b10) 
        begin
            clock_counter <= 32'b00000000;
            cash_dispensed_r <= 1;
            green_led_r <= 1;
            bank_balance <= bank_balance - total;
            rapid_withdrawal_state <= 0;
            withdrawal_state <= 0;
            deposit_state <= 0;
            balance_state <= 0;
        end
        else if (bank_balance < total && withdrawal_state == 2'b10) 
        begin
            clock_counter <= 32'b00000000;
            red_led_r <= 1;
            rapid_withdrawal_state <= 0;
            withdrawal_state <= 0;
            deposit_state <= 0;
            balance_state <= 0;
        end
        else if (deposit_state == 2'b11) 
        begin
            bank_balance <= bank_balance + total;
            rapid_withdrawal_state <= 0;
            withdrawal_state <= 0;
            balance_state <= 0;
            deposit_state <= 0;
        end
    end
    
    always @ (posedge clk_slow) 
    begin
        if ((one || two || three || four || five || six || seven || eight || nine || zero) && card_valid) globalCounter <= globalCounter + 1;
        else if (balance_check || withdrawal || deposit) globalCounter = 0;
    end
    
    assign bal_one = bank_balance/10**3 % 10;
    assign bal_two = bank_balance/10**2 % 10;
    assign bal_three = bank_balance/10**1 % 10;
    assign bal_four = bank_balance/10**0 % 10;
    
    always @ (posedge clk_slow) total = pass_one*10**3 + pass_two*10**2 + pass_three*10 + pass_four;
    always @ (posedge clk) if (!busy) counter <= counter + 1;
    
    always @ (posedge clk_slow)
    begin
        if (cash_dispensed || cash_in || deposit_p || withdrawal_p || rapid_withdrawal_p || balance_check_p || card_invalid) done = 1;
        else if (finish || finish_t) done = 0;
    end
    
    always @ (*)
    begin
        if (finish_t && !card_valid) // "Goodbye"
        begin
            case (counter[6:2])
                0:  data = 6'h24; // Goodbye
                1:  data = 6'h1E;
                2:  data = 6'h02;
                3:  data = 6'h15;
                4:  data = 6'h00;
                5:  data = 6'h3F;
                6:  data = 6'h18;
                7:  data = 6'h06;
                default: data = 6'h03;
            endcase
        end
        else if (green_led || cash_dispensed) // "Please take your cash"
        begin
            case (counter[6:2])
                0:  data = 6'h09; // Please
                1:  data = 6'h2D;
                2:  data = 6'h13;
                3:  data = 6'h37;
                4:  data = 6'h37;
                5:  data = 6'h03; // *pause*
                6:  data = 6'h11; // take
                7:  data = 6'h14;
                8:  data = 6'h29;
                9:  data = 6'h03; // *pause*
                10: data = 6'h19; // your
                11: data = 6'h3A;
                12: data = 6'h03; // *pause*
                13: data = 6'h2A; // cash
                14: data = 6'h1A;
                15: data = 6'h25;
                default: data = 6'h02;
            endcase
        end
        else if (deposit_p || cash_in) // "Deposit in progress"
        begin
            case (counter[6:2])
                0:  data = 6'h21; // Deposit
                1:  data = 6'h14;
                2:  data = 6'h09;
                3:  data = 6'h09;
                4:  data = 6'h18;
                5:  data = 6'h2B;
                6:  data = 6'h0C;
                7:  data = 6'h11;
                8:  data = 6'h03; // *pause*
                9:  data = 6'h0C; // in
                10: data = 6'h0B;
                11: data = 6'h03; // *pause*
                12: data = 6'h09; // progress
                13: data = 6'h0E;
                14: data = 6'h18;
                15: data = 6'h00;
                16: data = 6'h24;
                17: data = 6'h27;
                18: data = 6'h07;
                19: data = 6'h37;
                default: data = 6'h02;
            endcase
        end
        else if (withdrawal_p) // "Withdrawal in progress"
        begin
            case (counter[6:2])
                0:  data = 6'h30; // Withdrawl
                1:  data = 6'h0C;
                2:  data = 6'h0C;
                3:  data = 6'h1D;
                4:  data = 6'h00;
                5:  data = 6'h21;
                6:  data = 6'h0E;
                7:  data = 6'h20;
                8:  data = 6'h2D;
                9:  data = 6'h03; // *pause*
                10: data = 6'h0C; // in
                11: data = 6'h0B;
                12: data = 6'h03; // *pause*
                13: data = 6'h09; // progress
                14: data = 6'h0E;
                15: data = 6'h18;
                16: data = 6'h00;
                17: data = 6'h24;
                18: data = 6'h27;
                19: data = 6'h07;
                20: data = 6'h37;
                default: data = 6'h02;
            endcase
        end
        else if (rapid_withdrawal_p) // "Rapid withdrawal in progress"
        begin
            case (counter[6:2])
                0:  data = 6'h27; // Rapid
                1:  data = 6'h1A;
                2:  data = 6'h00;
                3:  data = 6'h09;
                4:  data = 6'h0C;
                5:  data = 6'h21;
                6:  data = 6'h03; // *pause*
                7:  data = 6'h30; // withdrawal
                8:  data = 6'h0C;
                9:  data = 6'h0C;
                10: data = 6'h1D;
                11: data = 6'h00;
                12: data = 6'h21;
                13: data = 6'h0E;
                14: data = 6'h20;
                15: data = 6'h2D;
                16: data = 6'h03; // *pause*
                17: data = 6'h0C; // in
                18: data = 6'h0B;
                19: data = 6'h03; // *pause*
                20: data = 6'h09; // progress
                21: data = 6'h0E;
                22: data = 6'h18;
                23: data = 6'h00;
                24: data = 6'h24;
                25: data = 6'h27;
                26: data = 6'h07;
                27: data = 6'h37;
                default: data = 6'h03;
            endcase
        end
        else if (balance_check_p) // "Balance check in progress"
        begin
            case (counter[6:2])
                1:  data = 6'h1C; // Balance
                2:  data = 6'h20;
                3:  data = 6'h2D;
                4:  data = 6'h07;
                5:  data = 6'h0B;
                6:  data = 6'h37;
                7:  data = 6'h03; // *pause*
                8:  data = 6'h32; // check
                9:  data = 6'h07;
                10: data = 6'h07;
                11: data = 6'h03;
                12: data = 6'h29;
                13: data = 6'h03; // *pause*
                14: data = 6'h0C; // in
                15: data = 6'h0B;
                16: data = 6'h03; // *pause*
                17: data = 6'h09; // progress
                18: data = 6'h0E;
                19: data = 6'h18;
                20: data = 6'h00;
                21: data = 6'h24;
                22: data = 6'h27;
                23: data = 6'h07;
                24: data = 6'h37;
                default: data = 6'h04;
            endcase
        end
        else if (card_valid && !done) // "Card accepted"
        begin
            case (counter[6:2])
                0:  data = 6'h08; // Card
                1:  data = 6'h3B;
                2:  data = 6'h00;
                3:  data = 6'h21;
                4:  data = 6'h03; // *pause*
                5:  data = 6'h07; // accepted
                6:  data = 6'h21;
                7:  data = 6'h37;
                8:  data = 6'h07;
                9:  data = 6'h09;
                10: data = 6'h02;
                11: data = 6'h15;
                default: data = 6'h04;
            endcase
        end
        else if (card_valid) // "Menu"
        begin
            case (counter[6:2])
                0:  data = 6'h10; // Menu
                1:  data = 6'h07;
                2:  data = 6'h00;
                3:  data = 6'h0B;
                4:  data = 6'h31;
                5:  data = 6'h1F;
                default: data = 6'h04;
            endcase
        end
        else
        begin
            case (counter[6:2])
                0:  data = 6'h03;
                default: data = 6'h04;
            endcase
        end
    end
    assign write = (counter[1:0] == 2'b00);

    always @ (posedge clk)     
    begin
        counter_1 <= counter_1 + 1;
        begin
            if (counter_1 == 14'd16383)
            begin 
                counter_1 <= 0;
                clk2_r <= !clk2_r;
            end
        end
    end
    assign clk_slow = clk2_r;
    
    chatter chatter_inst (.data(data), .write(write), .busy(busy), .clk(clk), .speaker(speaker));
    digitone (clk_slow, card_valid, card_in_t, one, two, three, four, five, six, seven, eight, nine, zero,
        digit_one_value[3:0], balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, globalCounter[1:0], digit_one_detection[1:0], pass_one[3:0], with_one[3:0], depo_one[3:0]
        );  
    digittwo (clk_slow, card_valid, card_in_t, one, two, three, four, five, six, seven, eight, nine, zero, digit_one_detection[1:0],
        digit_two_value[3:0], balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, globalCounter[1:0], digit_two_detection[1:0], pass_two[3:0], with_two[3:0], depo_two[3:0]
        );  
    digitthree (clk_slow, card_valid, card_in_t, one, two, three, four, five, six, seven, eight, nine, zero, digit_two_detection[1:0], digit_one_detection[1:0],
        digit_three_value[3:0], balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, globalCounter[1:0], digit_three_detection[1:0], pass_three[3:0], with_three[3:0], depo_three[3:0]
        );  
    digitfour (clk_slow, card_valid, card_in_t, one, two, three, four, five, six, seven, eight, nine, zero, digit_three_detection[1:0], digit_two_detection[1:0], digit_one_detection[1:0], 
        digit_four_value[3:0], balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, globalCounter[1:0], digit_four_detection[1:0], pass_four[3:0], with_four[3:0], depo_four[3:0]
        );  
    confirmation (clk_slow, finish_t, card_in_t, digit_four_detection[1:0], digit_three_detection[1:0], digit_two_detection[1:0], digit_one_detection[1:0], card_valid, card_invalid);
    pulse (clk_slow, zero_in, one_in, two_in, three_in, four_in, five_in, six_in, seven_in, eight_in, nine_in, card_in_t, finish_t, balance_check_t, rapid_withdrawal_t, withdrawal_t, deposit_t, 
        one, two, three, four, five, six, seven, eight, nine, zero, card_in, finish, balance_check, rapid_withdrawal, withdrawal, deposit
        );
    display (clk, test_one[3:0], test_two[3:0], test_three[3:0], test_four[3:0], an3, an2, an1, an0, ca, cb, cc, cd, ce, cf, cg, dp);
    led_control (clk_slow, card_valid, balance_state, rapid_withdrawal_state[1:0], withdrawal_state[1:0], deposit_state[1:0], balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in);
    mux (clk_slow, card_valid, balance_check_p, withdrawal_p, rapid_withdrawal_p, deposit_p, 
        pass_one [3:0], pass_two [3:0], pass_three [3:0], pass_four [3:0],
        bal_one  [3:0], bal_two  [3:0], bal_three  [3:0], bal_four  [3:0],
        with_one [3:0], with_two [3:0], with_three [3:0], with_four [3:0],
        depo_one [3:0], depo_two [3:0], depo_three [3:0], depo_four [3:0],
        test_one [3:0], test_two [3:0], test_three [3:0], test_four [3:0]
        );
endmodule
    
module led_control (
    input wire clk_slow, card_valid, balance_state, [1:0] rapid_withdrawal_state, [1:0] withdrawal_state, [1:0] deposit_state,
    output reg balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in
    );
    
    reg [31:0] clock_counter; 
    
    always @ (posedge clk_slow)
    begin
        if (card_valid)
        begin
            if (balance_state == 2'b01) {balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in} = 5'b10000;
            else if (rapid_withdrawal_state  == 2'b01) {balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in} = 5'b01000;
            else if (withdrawal_state == 2'b01) {balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in} = 5'b00100;
            else if (deposit_state == 2'b01) {balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in} = 5'b00010;
            else if (deposit_state == 2'b10) {balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in} = 5'b00011;
            else {balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in} = 5'b00000;
        end
        else {balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, cash_in} = 5'b00000;
    end
endmodule
    
module mux (
    input wire clk_slow, card_valid, balance_check_p, withdrawal_p, rapid_withdrawal_p, deposit_p,
    input wire [3:0] pass_one, pass_two, pass_three, pass_four,
    input wire [3:0] bal_one, bal_two, bal_three, bal_four,
    input wire [3:0] with_one, with_two, with_three, with_four,
    input wire [3:0] depo_one, depo_two, depo_three, depo_four,
    output wire [3:0] test_one, test_two, test_three, test_four
    );
    
    reg sel0, sel1;
    
    always @ (posedge clk_slow)
    begin
        if (deposit_p) {sel0, sel1}  = 2'b00;
        else if (balance_check_p) {sel0, sel1}  = 2'b01;
        else if (withdrawal_p || rapid_withdrawal_p) {sel0, sel1}  = 2'b10;
        else {sel0, sel1}  = 2'b11;
    end
    assign test_one = sel1 ? (sel0 ? pass_one : bal_one) : (sel0 ? with_one : depo_one);
    assign test_two = sel1 ? (sel0 ? pass_two : bal_two) : (sel0 ? with_two : depo_two);
    assign test_three = sel1 ? (sel0 ? pass_three : bal_three) : (sel0 ? with_three : depo_three);
    assign test_four = sel1 ? (sel0 ? pass_four : bal_four) : (sel0 ? with_four : depo_four);
endmodule
    
module digitone (
    input wire  clk_slow, card_valid, card_in_t, one, two, three, four, five, six, seven, eight, nine, zero, [3:0] digit_one_value,
    input wire balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, [1:0] globalCounter,
    inout wire [1:0] digit_one_detection,
    output wire [3:0] pass_one, with_one, depo_one
    );
    
    reg [1:0] test;
    reg [3:0] set;
    
    initial set <= 4'b1111;
    always @ (posedge clk_slow)
    begin
        if (card_in_t == 0) set <= 4'b1111;
        else if ((digit_one_detection == 2'b00 && card_in_t) || ((balance_check_p || rapid_withdrawal_p || withdrawal_p || deposit_p)&& globalCounter == 2'b00))
        begin
            if (zero)  set <= 4'b0000;
            else if (one)   set <= 4'b0001;
            else if (two)   set <= 4'b0010;
            else if (three) set <= 4'b0011;
            else if (four)  set <= 4'b0100;
            else if (five)  set <= 4'b0101;
            else if (six)   set <= 4'b0110;
            else if (seven) set <= 4'b0111;
            else if (eight) set <= 4'b1000;
            else if (nine)  set <= 4'b1001;
        end
    end  
    assign pass_one = set;
    assign with_one = set;
    assign depo_one = set;
    
    always @ (posedge clk_slow)   
    begin 
        if (card_in_t == 0) test <= 2'b00;
        else if (pass_one < 4'b1010)
        begin
            if ((4'b0000 == pass_one) && (digit_one_detection != 2'b01) && (digit_one_detection != 2'b10))   test <= 2'b10; // if input value matches true digit value send binary value 2 to confirmation 
            else if ((4'b0000 != pass_one) && (digit_one_detection != 2'b01) && (digit_one_detection != 2'b10)) test <= 2'b01; // if input value doesnt true digit value send binary value 1 to confirmation 
        end
    end
    assign digit_one_detection = test;
endmodule
    
module digittwo (
    input wire clk_slow, card_valid, card_in_t, one, two, three, four, five, six, seven, eight, nine, zero, [1:0] digit_one_detection, [3:0] digit_two_value,
    input wire balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, [1:0] globalCounter,
    inout wire [1:0] digit_two_detection,
    output wire [3:0] pass_two, with_two, depo_two
    );
    
    reg [1:0] test;
    reg [3:0] set;
    
    initial set <= 4'b1111;
    always @ (negedge clk_slow)
    begin
        if ((digit_one_detection == 2'b10) || (digit_one_detection == 2'b01) || card_in_t == 0) 
        begin
            if ((digit_two_detection == 2'b00) || ((balance_check_p || rapid_withdrawal_p || withdrawal_p || deposit_p) && globalCounter == 2'b01))
            begin
                if (card_in_t == 0) set <= 4'b1111;
                else if (zero)  set <= 4'b0000;
                else if (one)   set <= 4'b0001;
                else if (two)   set <= 4'b0010;
                else if (three) set <= 4'b0011;
                else if (four)  set <= 4'b0100;
                else if (five)  set <= 4'b0101;
                else if (six)   set <= 4'b0110;
                else if (seven) set <= 4'b0111;
                else if (eight) set <= 4'b1000;
                else if (nine)  set <= 4'b1001;
            end
        end
    end  
    assign pass_two = set;
    assign with_two = set;
    assign depo_two = set;
    
    always @ (posedge clk_slow)   
    begin 
        if (card_in_t == 0) test <= 2'b00;
        else if (((digit_one_detection == 2'b10) || (digit_one_detection == 2'b01)) && (pass_two < 4'b1010))
        begin
            if ((4'b0000 == pass_two) && (digit_two_detection != 2'b01) && (digit_two_detection != 2'b10)) test <= 2'b10;
            else if ((4'b0000 != pass_two) && digit_two_detection != 2'b01 && digit_two_detection != 2'b10) test <= 2'b01;
        end
    end   
    assign digit_two_detection = test;
endmodule
    
module digitthree (
    input wire clk_slow, card_valid, card_in_t, one, two, three, four, five, six, seven, eight, nine, zero, [1:0] digit_two_detection, [1:0] digit_one_detection, [3:0] digit_three_value,
    input wire balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, [1:0] globalCounter,
    output wire [1:0] digit_three_detection,
    output wire [3:0] pass_three, with_three, depo_three
    );
    
    reg [1:0] test;
    reg [3:0] set;
    
    initial set <= 4'b1111;
    always @ (negedge clk_slow)
    begin
        if ((((digit_two_detection == 2'b10) || (digit_two_detection == 2'b01)) && ((digit_one_detection == 2'b10) || (digit_one_detection == 2'b01))) || card_in_t == 0)  
        begin
            if ((digit_three_detection == 2'b00)  || ((balance_check_p || rapid_withdrawal_p || withdrawal_p || deposit_p)&& globalCounter == 2'b10))
            begin
                if (card_in_t == 0) set <= 4'b1111;
                else if (zero)  set <= 4'b0000;
                else if (one)   set <= 4'b0001;
                else if (two)   set <= 4'b0010;
                else if (three) set <= 4'b0011;
                else if (four)  set <= 4'b0100;
                else if (five)  set <= 4'b0101;
                else if (six)   set <= 4'b0110;
                else if (seven) set <= 4'b0111;
                else if (eight) set <= 4'b1000;
                else if (nine)  set <= 4'b1001;
            end
        end
    end  
    assign pass_three = set;
    assign with_three = set;
    assign depo_three = set;
    
    always @ (posedge clk_slow)   
    begin 
        if (card_in_t == 0) test <= 2'b00;
        else if (((digit_two_detection == 2'b10) || (digit_two_detection == 2'b01)) && ((digit_one_detection == 2'b10) || (digit_one_detection == 2'b01)) && (pass_three < 4'b1010))
        begin
            if (((4'b0000 == pass_three) && (digit_three_detection != 2'b01) && (digit_three_detection != 2'b10))) test <= 2'b10;
            else if (((4'b0000 != pass_three)) && (digit_three_detection != 2'b01) && (digit_three_detection != 2'b10)) test <= 2'b01;
        end
    end   
    assign digit_three_detection = test;
endmodule
    
module digitfour (
    input wire clk_slow, card_valid, card_in_t, one, two, three, four, five, six, seven, eight, nine, zero, [1:0] digit_three_detection, [1:0] digit_two_detection, [1:0] digit_one_detection, [3:0] digit_four_value,
    input wire balance_check_p, rapid_withdrawal_p, withdrawal_p, deposit_p, [1:0] globalCounter,
    inout wire [1:0] digit_four_detection,
    output wire [3:0] pass_four, with_four, depo_four
    );
    
    reg [1:0] test;
    reg [3:0] set;
    
    initial set <= 4'b1111;
    always @ (negedge clk_slow)
    begin
        if ((((digit_three_detection == 2'b10) || (digit_three_detection == 2'b01)) && ((digit_one_detection == 2'b10) || (digit_one_detection == 2'b01)) && ((digit_two_detection == 2'b10) || (digit_two_detection == 2'b01))) || card_in_t == 0)
        begin
            if ((digit_four_detection == 2'b00) || ((balance_check_p || rapid_withdrawal_p || withdrawal_p || deposit_p) && globalCounter == 2'b11))
            begin
                if (card_in_t == 0) set <= 4'b1111;
                else if (zero)  set <= 4'b0000;
                else if (one)   set <= 4'b0001;
                else if (two)   set <= 4'b0010;
                else if (three) set <= 4'b0011;
                else if (four)  set <= 4'b0100;
                else if (five)  set <= 4'b0101;
                else if (six)   set <= 4'b0110;
                else if (seven) set <= 4'b0111;
                else if (eight) set <= 4'b1000;
                else if (nine)  set <= 4'b1001;
            end
        end
    end  
    assign pass_four = set;
    assign with_four = set;
    assign depo_four = set;
    
    always @ (posedge clk_slow)   
    begin 
        if(card_in_t == 0) test <= 2'b00;
        else if(((digit_three_detection == 2'b10) || (digit_three_detection == 2'b01)) && ((digit_one_detection == 2'b10) || (digit_one_detection == 2'b01)) && ((digit_two_detection == 2'b10) || (digit_two_detection == 2'b01)) && (pass_four < 4'b1010))
        begin
            if ((4'b0000 == pass_four) && (digit_four_detection != 2'b01) && (digit_four_detection != 2'b10))  test <= 2'b10;
            else if(((4'b0000 != pass_four)) && (digit_four_detection != 2'b01) && (digit_four_detection != 2'b10)) test <= 2'b01;
        end
    end   
    assign digit_four_detection = test;
endmodule
    
module confirmation (
    input wire clk_slow, finish_t, card_in_t, [1:0] digit_four_detection, [1:0] digit_three_detection, [1:0] digit_two_detection, [1:0] digit_one_detection, 
    output wire card_valid, card_invalid
    );
    
    reg test, test_one;
    
    always @ (posedge clk_slow)    
    begin 
        if(finish_t == 1 || card_in_t == 0) 
        begin
            test_one <= 1'b0;
            test <= 1'b0;
        end
        else if ((digit_three_detection == 2'b10 || digit_three_detection == 2'b01) && (digit_one_detection == 2'b10 || digit_one_detection == 2'b01) && (digit_two_detection == 2'b10 || digit_two_detection == 2'b01) && (digit_four_detection == 2'b10 || digit_four_detection == 2'b01))
        begin
            if ((digit_four_detection == 2'b01)||(digit_one_detection == 2'b01)||(digit_two_detection == 2'b01)||(digit_three_detection == 2'b01)) test_one <= 1'b1;
            else if ((digit_one_detection == 2'b10) && (digit_two_detection == 2'b10) && (digit_three_detection == 2'b10) && (digit_four_detection == 2'b10))
            begin
                test <= 1'b1;
                test_one <= 1'b0;
            end
        end
    end   
    assign card_valid = test;
    assign card_invalid = test_one;
endmodule
    
module display (
    input wire clk, [3:0] test_one, [3:0] test_two, [3:0] test_three, [3:0] test_four,
    output reg an3, an2, an1, an0, ca, cb, cc, cd, ce, cf, cg,
    output wire dp
    );
    
    wire [1:0] LED_counter;
    reg [7:0] display0, display1, display2, display3;
    reg [19:0] led_refresh;
    
    always @ (posedge clk) led_refresh <= led_refresh + 1;
    assign LED_counter = led_refresh[19:18];
    
    always @ (*)
    begin 
        case (test_one)
            4'h0: display0 = 8'b00000001;
            4'h1: display0 = 8'b01001111;
            4'h2: display0 = 8'b00010010;
            4'h3: display0 = 8'b00000110;
            4'h4: display0 = 8'b01001100;
            4'h5: display0 = 8'b00100100;
            4'h6: display0 = 8'b00100000;
            4'h7: display0 = 8'b00001111;
            4'h8: display0 = 8'b00000000;
            4'h9: display0 = 8'b00001100;
            4'hA: display0 = 8'b11111110;
            default: display0 = 8'b11111110;
        endcase
        case (test_two)
            4'h0: display1 = 8'b00000001;
            4'h1: display1 = 8'b01001111;
            4'h2: display1 = 8'b00010010;
            4'h3: display1 = 8'b00000110;
            4'h4: display1 = 8'b01001100;
            4'h5: display1 = 8'b00100100;
            4'h6: display1 = 8'b00100000;
            4'h7: display1 = 8'b00001111;
            4'h8: display1 = 8'b00000000;
            4'h9: display1 = 8'b00001100;
            4'hA: display1 = 8'b11111110;
            default: display1 = 8'b11111110;
        endcase
        case (test_three)
            4'h0: display2 = 8'b00000001;
            4'h1: display2 = 8'b01001111;
            4'h2: display2 = 8'b00010010;
            4'h3: display2 = 8'b00000110;
            4'h4: display2 = 8'b01001100;
            4'h5: display2 = 8'b00100100;
            4'h6: display2 = 8'b00100000;
            4'h7: display2 = 8'b00001111;
            4'h8: display2 = 8'b00000000;
            4'h9: display2 = 8'b00001100;
            4'hA: display2 = 8'b11111110;
            default: display2 = 8'b11111110;
        endcase 
        case (test_four)
            4'h0: display3 = 8'b00000001;
            4'h1: display3 = 8'b01001111;
            4'h2: display3 = 8'b00010010;
            4'h3: display3 = 8'b00000110;
            4'h4: display3 = 8'b01001100;
            4'h5: display3 = 8'b00100100;
            4'h6: display3 = 8'b00100000;
            4'h7: display3 = 8'b00001111;
            4'h8: display3 = 8'b00000000;
            4'h9: display3 = 8'b00001100;
            4'hA: display3 = 8'b11111110;
            default: display3 = 8'b11111110;
        endcase
    end
    always @ (*)
    begin
        case(LED_counter)
            2'b00:
            begin
                an0 = 1'b0;
                an1 = 1'b1;
                an2 = 1'b1;
                an3 = 1'b1;
                {ca, cb, cc, cd, ce, cf, cg} = display3;
            end
            2'b01:
            begin
                an0 = 1'b1;
                an1 = 1'b0;
                an2 = 1'b1;
                an3 = 1'b1;
                {ca, cb, cc, cd, ce, cf, cg} = display2;
            end
            2'b10: 
            begin
                an0 = 1'b1;
                an1 = 1'b1;
                an2 = 1'b0;
                an3 = 1'b1;
                {ca, cb, cc, cd, ce, cf, cg} = display1;
            end
            2'b11:  
            begin
                an0 = 1'b1;
                an1 = 1'b1;
                an2 = 1'b1;
                an3 = 1'b0;
                {ca, cb, cc, cd, ce, cf, cg} = display0;
            end
            default:
            begin
                an0 = 1'b1;
                an1 = 1'b1;
                an2 = 1'b1;
                an3 = 1'b1;
                {ca, cb, cc, cd, ce, cf, cg} = display0;
            end
        endcase
    end
endmodule
    
module pulse (
    input wire clk_slow, zero_in, one_in, two_in, three_in, four_in, five_in, six_in, seven_in, eight_in, nine_in, card_in_t, finish_t, balance_check_t, rapid_withdrawal_t, withdrawal_t, deposit_t,
    output wire one, two, three, four, five, six, seven, eight, nine, zero, card_in, finish, balance_check, rapid_withdrawal, withdrawal, deposit
    );
    
    reg p_zero, p_one, p_two, p_three, p_four, p_five, p_six, p_seven, p_eight, p_nine, p_card_in, p_finish, p_balance_check, p_rapid_withdrawal, p_withdrawal, p_deposit;
    reg v_zero, v_one, v_two, v_three, v_four, v_five, v_six, v_seven, v_eight, v_nine, v_card_in, v_finish, v_balance_check, v_rapid_withdrawal, v_withdrawal, v_deposit;
    
    always @ (posedge clk_slow) // zero
    begin
        if (zero_in && !p_zero)
        begin
            p_zero <= ~p_zero;
            v_zero <= 1;
        end
        else if (!zero_in) p_zero <= 0;
        else v_zero <= 0;
    end
    
    always @ (posedge clk_slow) // one
    begin
        if (one_in && !p_one)
        begin
            p_one <= ~p_one;
            v_one <= 1;
        end
        else if (!one_in) p_one <= 0;
        else v_one <= 0;
    end
    
    always @ (posedge clk_slow) // two
    begin
        if (two_in && !p_two)
        begin
            p_two <= ~p_two;
            v_two <= 1;
        end
        else if (!two_in) p_two <= 0;
        else v_two <= 0;
    end
    
    always @ (posedge clk_slow) // three
    begin
        if (three_in && !p_three)
        begin
            p_three <= ~p_three;
            v_three <= 1;
        end
        else if (!three_in) p_three <= 0;
        else v_three <= 0;
    end
    
    always @ (posedge clk_slow) // four
    begin
        if (four_in && !p_four)
        begin
            p_four <= ~p_four;
            v_four <= 1;
        end
        else if (!four_in) p_four <= 0;
        else v_four <= 0;
    end
    
    always @ (posedge clk_slow) // five
    begin
        if (five_in && !p_five)
        begin
            p_five <= ~p_five;
            v_five <= 1;
        end
        else if (!five_in) p_five <= 0;
        else v_five <= 0;
    end
    
    always @ (posedge clk_slow) // six
    begin
        if (six_in && !p_six)
        begin
            p_six <= ~p_six;
            v_six <= 1;
        end
        else if (!six_in) p_six <= 0;
        else v_six <= 0;
    end
    
    always @ (posedge clk_slow) // seven
    begin
        if (seven_in && !p_seven)
        begin
            p_seven <= ~p_seven;
            v_seven <= 1;
        end
        else if (!seven_in) p_seven <= 0;
        else v_seven <= 0;
    end
    
    always @ (posedge clk_slow) // eight
    begin
        if (eight_in && !p_eight)
        begin
            p_eight <= ~p_eight;
            v_eight <= 1;
        end
        else if (!eight_in) p_eight <= 0;
        else v_eight <= 0;
    end
    
    always @ (posedge clk_slow) // nine
    begin
        if (nine_in && !p_nine)
        begin
            p_nine <= ~p_nine;
            v_nine <= 1;
        end
        else if (!nine_in) p_nine <= 0;
        else v_nine <= 0;
    end
    
    always @ (posedge clk_slow) // card_in
    begin
        if (card_in_t && !p_card_in)
        begin
            p_card_in <= ~p_card_in;
            v_card_in <= 1;
        end
        else if (!card_in_t) p_card_in <= 0;
        else v_card_in <= 0;
    end
    
    always @ (posedge clk_slow) // finish
    begin
        if (finish_t && !p_finish)
        begin
            p_finish <= ~p_finish;
            v_finish <= 1;
        end
        else if (!finish_t) p_finish <= 0;
        else v_finish <= 0;
    end
    
    always @ (posedge clk_slow) // balance_check
    begin
        if (balance_check_t && !p_balance_check)
        begin
            p_balance_check <= ~p_balance_check;
            v_balance_check <= 1;
        end
        else if (!balance_check_t) p_balance_check <= 0;
        else v_balance_check <= 0;
    end
    
    always @ (posedge clk_slow) // rapid_withdrawal
    begin
        if (rapid_withdrawal_t && !p_rapid_withdrawal)
        begin
            p_rapid_withdrawal <= ~p_rapid_withdrawal;
            v_rapid_withdrawal <= 1;
        end
        else if (!rapid_withdrawal_t) p_rapid_withdrawal <= 0;
        else v_rapid_withdrawal <= 0;
    end
    
    always @ (posedge clk_slow) // withdrawal
    begin
        if (withdrawal_t && !p_withdrawal)
        begin
            p_withdrawal <= ~p_withdrawal;
            v_withdrawal <= 1;
        end
        else if (!withdrawal_t) p_withdrawal <= 0;
        else v_withdrawal <= 0;
    end
    
    always @ (posedge clk_slow) // deposit
    begin
        if (deposit_t && !p_deposit)
        begin
            p_deposit <= ~p_deposit;
            v_deposit <= 1;
        end
        else if (!deposit_t) p_deposit <= 0;
        else v_deposit <= 0;
    end
    assign zero = v_zero;
    assign one = v_one;
    assign two = v_two;
    assign three = v_three;
    assign four = v_four;
    assign five = v_five;
    assign six = v_six;
    assign seven = v_seven;
    assign eight = v_eight;
    assign nine = v_nine;
    assign card_in = v_card_in;
    assign finish = v_finish;
    assign balance_check = v_balance_check;
    assign rapid_withdrawal = v_rapid_withdrawal;
    assign withdrawal = v_withdrawal;
    assign deposit = v_deposit;
endmodule