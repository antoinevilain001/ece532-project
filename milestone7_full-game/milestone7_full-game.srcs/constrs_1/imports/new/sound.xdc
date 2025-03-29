## Audio PWM output (to AUD_PWM)
set_property PACKAGE_PIN A11 [get_ports {GPIO_0_tri_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_o[0]}]

## Amplifier Enable (to AUD_SD)
set_property PACKAGE_PIN C11 [get_ports {GPIO_0_tri_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_0_tri_o[1]}]


## SW0
set_property PACKAGE_PIN J15 [get_ports SW0]
set_property IOSTANDARD LVCMOS33 [get_ports SW0]
