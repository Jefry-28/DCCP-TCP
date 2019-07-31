##################################################
#  ____________________________________________  #
# |---DCCP CCID 3 VS TCP Tahoe Simulasi 1---| #
# |____________________________________________| #
#                                                #
##################################################

#Declare New Simulator
set ns [new Simulator]


#Setting output file
set tr [open CCID3vsTCPTDropTail.tr w]
$ns trace-all $tr
set nf [open CCID3vsTCPTDropTail.nam w]
$ns namtrace-all $nf


#Node Sender
set S1 [$ns node]
set S2 [$ns node]

#router
set R1 [$ns node]
set R2 [$ns node]

#Node Receiver
set D1 [$ns node]
set D2 [$ns node]


# Link Node Sender 1 & 2 ke Router 1
$ns duplex-link $S1 $R1 10Mb 10ms RED
$ns duplex-link $S2 $R1 10Mb 10ms RED

# Link Antar Router
$ns duplex-link $R1 $R2 10Mb 10ms RED

# Link Router 2 ke Node Receiver 1 & 2
$ns duplex-link $R2 $D1 10Mb 10ms RED
$ns duplex-link $R2 $D2 10Mb 10ms RED


# Setting Node Position
$ns duplex-link-op $S1 $R1 orient right-down
$ns duplex-link-op $S2 $R1 orient right-up
$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $R2 $D1 orient right-up
$ns duplex-link-op $R2 $D2 orient right-down

# Setting Queue Length
$ns queue-limit $R1 $R2 3


#setting antrian RED
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
#Queue/RED set maxp_ 0.02
Queue/RED set q_weight_ 0.002
Queue/RED set thresh_ 15
Queue/RED set maxthresh_ 20

#Monitor the queue for link (r1-r2). (for NAM)
$ns duplex-link-op $R1 $R2 queuePos 0.5

# Setting TCP Agent
set tcp1 [new Agent/TCP]
set tcpsink1 [new Agent/TCPSink]
$ns at 0 
$ns attach-agent $S1 $tcp1
$ns attach-agent $D1 $tcpsink1
$ns connect $tcp1 $tcpsink1
$tcp1 set packetSize_ 1500
$tcp1 set window_ 1000
#$tcp1 set mtu_ 1500
$tcp1 set fid_ 1
$ns color 1 Red

#FTP
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

# Setting DCCP Agent
set dccp1 [new Agent/DCCP/TFRC]
set dccpsink1 [new Agent/DCCP/TFRC]
$ns attach-agent $S2 $dccp1
$ns attach-agent $D2 $dccpsink1
$ns connect $dccp1 $dccpsink1
$dccp1 set fid_ 2
$ns color 2 Blue

# CBR #1 (DCCP1)
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $dccp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1500
$cbr1 set rate_ 10Mb
$cbr1 set random_ false


#tcp trace
#$tcp1 attach $tr
#$tcp1 tracevar cwnd_
#$dccp1 attach $tr
#$dccp1 tracevar cwnd_
#$dccp1 trace cwnd_

$ns at 0.0 "$tcpsink1 listen"
$ns at 0.1 "$ftp1 start"
$ns at 0.0 "$dccpsink1 listen"
$ns at 0.1 "$cbr1 start"
$ns at 600.0 "$cbr1 stop"
$ns at 600.0 "$ftp1 stop"
$ns at 600.0 "finish"


#Setting Procedure Finish
proc finish {} {
	global ns tr nf
	$ns flush-trace
	close $nf
	close $tr
	#exec awk -f test123.awk CCID3vsTCPTDropTail.tr &
	#exec awk -f delay_tcp.awk CCID3vsTCPTDropTail.tr &
	exec awk -f Hasil_TCP.awk CCID3vsTCPTDropTail.tr &
	exec awk -f Hasil_DCCP.awk CCID3vsTCPTDropTail.tr &
	exit 0
}

# Plot Congestion Window
proc plotWindow {tcpSource output} {
	global ns tcp1
	set cwnd [$tcpSource set cwnd_ ]
	set now [$ns now]
	puts $output "$now $cwnd"
	$ns at [expr $now+0.1] "plotWindow $tcpSource $output"
}
set output [open "cwnd_TCP.xg" w]
$ns at 0.0 "plotWindow $tcp1 $output"

# Plot Sending Rate DCCP CCID 3
proc plotSendingRate {dccpSource output} {
	global ns dccp1
	set tx [$dccpSource set s_x_ ]
	set now [$ns now]
	puts $output "$now $tx"
	$ns at [expr $now+1] "plotSendingRate $dccpSource $output"
}
set output [open "SendingRate_CCID3_DT50.xg" w]
$ns at 0.0 "plotSendingRate $dccp1 $output"

# Plot sample RTT DCCP CCID 3
proc plotDCCPrtt {dccpSource output} {
	global ns dccp1
	set rtt [$dccpSource set s_r_sample_ ]
	set now [$ns now]
	puts $output "$now $rtt"
	$ns at [expr $now+1] "plotDCCPrtt $dccpSource $output"
}
set output [open "sampleRTT_CCID3_DT50.xg" w]
$ns at 0.0 "plotDCCPrtt $dccp1 $output"

# Plot srtt DCCP CCID 3
proc plotDCCPsrtt {dccpSource output} {
	global ns dccp1
	set srtt [$dccpSource set s_rtt_ ]
	set now [$ns now]
	puts $output "$now $srtt"
	$ns at [expr $now+1] "plotDCCPsrtt $dccpSource $output"
}
set output [open "srtt_CCID3_DT50.xg" w]
$ns at 0.0 "plotDCCPsrtt $dccp1 $output"

# Plot loss event rate DCCP CCID 3
proc plotDCCPloss {dccpSource output} {
	global ns dccp1
	set loss [$dccpSource set s_p_ ]
	set now [$ns now]
	puts $output "$now $loss"
	$ns at [expr $now+1] "plotDCCPloss $dccpSource $output"
}
set output [open "loss_CCID3_DT50.xg" w]
$ns at 0.0 "plotDCCPloss $dccp1 $output"




#run simulasi
$ns run
