# Clock
set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name external_clock -period 10.00 [get_ports clk]
# Speaker
set_property PACKAGE_PIN G18 [get_ports {speaker}]
set_property IOSTANDARD LVCMOS33 [get_ports {speaker}]

# SW0 (zero)
set_property PACKAGE_PIN R17 [get_ports {zero_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {zero_in}]
# SW1 (one)
set_property PACKAGE_PIN U20 [get_ports {one_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {one_in}]
# SW2 (two)
set_property PACKAGE_PIN R16 [get_ports {two_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {two_in}]
# SW3 (three)
set_property PACKAGE_PIN N16 [get_ports {three_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {three_in}]
# SW4 (four)
set_property PACKAGE_PIN R14 [get_ports {four_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {four_in}]
# SW5 (five)
set_property PACKAGE_PIN P14 [get_ports {five_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {five_in}]
# SW6 (six)
set_property PACKAGE_PIN L15 [get_ports {six_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {six_in}]
# SW7 (seven)
set_property PACKAGE_PIN M15 [get_ports {seven_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {seven_in}]
# SW8 (eight)
set_property PACKAGE_PIN T10 [get_ports {eight_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {eight_in}]
# SW9 (nine)
set_property PACKAGE_PIN T12 [get_ports {nine_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {nine_in}]
# SW10 (card_in)
set_property PACKAGE_PIN T11 [get_ports {card_in_t}]
set_property IOSTANDARD LVCMOS33 [get_ports {card_in_t}]
# SW11 (finish)
set_property PACKAGE_PIN T14 [get_ports {finish_t}]
set_property IOSTANDARD LVCMOS33 [get_ports {finish_t}]
# BTN0 (balance check)
set_property PACKAGE_PIN W14 [get_ports {balance_check_t}]
set_property IOSTANDARD LVCMOS33 [get_ports {balance_check_t}]
# BTN1 (rapid withdrawal)
set_property PACKAGE_PIN W13 [get_ports {rapid_withdrawal_t}]
set_property IOSTANDARD LVCMOS33 [get_ports {rapid_withdrawal_t}]
# BTN2 (withdrawal)
set_property PACKAGE_PIN P15 [get_ports {withdrawal_t}]
set_property IOSTANDARD LVCMOS33 [get_ports {withdrawal_t}]
# BTN3 (deposit)
set_property PACKAGE_PIN M14 [get_ports {deposit_t}]
set_property IOSTANDARD LVCMOS33 [get_ports {deposit_t}]

# LD0 (card valid)
set_property PACKAGE_PIN N20 [get_ports {card_valid}]
set_property IOSTANDARD LVCMOS33 [get_ports {card_valid}]
# LD1 (card invalid)
set_property PACKAGE_PIN P20 [get_ports {card_invalid}]
set_property IOSTANDARD LVCMOS33 [get_ports {card_invalid}]
# LD2 (balance check)
set_property PACKAGE_PIN R19 [get_ports {balance_check_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {balance_check_p}]
# LD3 (rapid withdrawal)
set_property PACKAGE_PIN T20 [get_ports {rapid_withdrawal_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {rapid_withdrawal_p}]
# LD4 (withdrawal)
set_property PACKAGE_PIN T19 [get_ports {withdrawal_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {withdrawal_p}]
# LD5 (deposit)
set_property PACKAGE_PIN U13 [get_ports {deposit_p}]
set_property IOSTANDARD LVCMOS33 [get_ports {deposit_p}]
# LD6 (cash in)
set_property PACKAGE_PIN V20 [get_ports {cash_in}]
set_property IOSTANDARD LVCMOS33 [get_ports {cash_in}]
# LD7 (cash dispensed)
set_property PACKAGE_PIN W20 [get_ports {cash_dispensed}]
set_property IOSTANDARD LVCMOS33 [get_ports {cash_dispensed}]
# LD11 (red)
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {red_led}];
# LD11 (green)
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {green_led}];

# 7-Segment (CA)
set_property PACKAGE_PIN K14 [get_ports {ca}]
set_property IOSTANDARD LVCMOS33 [get_ports {ca}]
# 7-Segment (CB)
set_property PACKAGE_PIN H15 [get_ports {cb}]
set_property IOSTANDARD LVCMOS33 [get_ports {cb}]
# 7-Segment (CC)
set_property PACKAGE_PIN J18 [get_ports {cc}]
set_property IOSTANDARD LVCMOS33 [get_ports {cc}]
# 7-Segment (CD)
set_property PACKAGE_PIN J15 [get_ports {cd}]
set_property IOSTANDARD LVCMOS33 [get_ports {cd}]
# 7-Segment (CE)
set_property PACKAGE_PIN M17 [get_ports {ce}]
set_property IOSTANDARD LVCMOS33 [get_ports {ce}]
# 7-Segment (CF)
set_property PACKAGE_PIN J16 [get_ports {cf}]
set_property IOSTANDARD LVCMOS33 [get_ports {cf}]
# 7-Segment (CG)
set_property PACKAGE_PIN H18 [get_ports {cg}]
set_property IOSTANDARD LVCMOS33 [get_ports {cg}]
# 7-Segment (AN0)
set_property PACKAGE_PIN K19 [get_ports {an0}]
set_property IOSTANDARD LVCMOS33 [get_ports {an0}]
# 7-Segment (AN1)
set_property PACKAGE_PIN H17 [get_ports {an1}]
set_property IOSTANDARD LVCMOS33 [get_ports {an1}]
# 7-Segment (AN2)
set_property PACKAGE_PIN M18 [get_ports {an2}]
set_property IOSTANDARD LVCMOS33 [get_ports {an2}]
# 7-Segment (AN3)
set_property PACKAGE_PIN L16 [get_ports {an3}]
set_property IOSTANDARD LVCMOS33 [get_ports {an3}]