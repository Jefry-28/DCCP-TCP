##################################################
#  ____________________________________________  #
# |---DCCP CCID 3 VS TCP Westwood Simulasi 1---| #
# |____________________________________________| #
#                                                #
##################################################

#Declare New Simulator
set ns [new Simulator]


#Setting output file
set tr [open CCID3vsTCPW.tr w]
$ns trace-all $tr
set nf [open CCID3vsTCPW.nam w]
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
$ns duplex-link $S1 $R1 10Mb 10ms DropTail
$ns duplex-link $S2 $R1 10Mb 10ms DropTail

# Link Antar Router
$ns duplex-link $R1 $R2 1Mb 100ms RED

# Link Router 2 ke Node Receiver 1 & 2
$ns duplex-link $R2 $D1 10Mb 10ms DropTail
$ns duplex-link $R2 $D2 10Mb 10ms DropTail


# Setting Node Position
$ns duplex-link-op $S1 $R1 orient right-down
$ns duplex-link-op $S2 $R1 orient right-up
$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $R2 $D1 orient right-up
$ns duplex-link-op $R2 $D2 orient right-down

# Setting Queue Length
$ns queue-limit $R1 $R2 200

#setting antrian RED
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set maxp_ 0.02
Queue/RED set q_weight_ 0.002
Queue/RED set thresh_ 15
Queue/RED set maxthresh_ 60

#Monitor the queue for link (r1-r2). (for NAM)
$ns duplex-link-op $R1 $R2 queuePos 0.5

# Setting TCP Agent
set tcp1 [new Agent/TCP/Linux]
set tcpsink1 [new Agent/TCPSink]
$ns at 0 "$tcp1 select_ca westwood"
$ns attach-agent $S1 $tcp1
$ns attach-agent $D1 $tcpsink1
$ns connect $tcp1 $tcpsink1
$tcp1 set window_ 1000
$tcp1 set fid_ 1
$ns color 1 Red

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
#$cbr1 set packetSize_ 3000
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 5Mb
$cbr1 set random_ false
#$cbr1 set interval_ 0.005 
#$cbr1 set random_ false 

#FTP
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

#tcp trace
$tcp1 attach $tr
$tcp1 tracevar cwnd_
$dccp1 attach $tr
$dccp1 tracevar cwnd_
$dccp1 trace cwnd_

$ns at 0.0 "$dccpsink1 listen"
$ns at 0.1 "$ftp1 start"
$ns at 0.1 "$cbr1 start"
$ns at 1000.0 "$cbr1 stop"
$ns at 1000.0 "$ftp1 stop"
$ns at 1000.0 "finish"


#Setting Procedure Finish
proc finish {} {
	global ns tr nf
	$ns flush-trace
	close $nf
	close $tr
	exec awk -f Hasil_TCP.awk CCID3vsTCPW.tr &
	exec awk -f Hasil_DCCP.awk CCID3vsTCPW.tr &
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
set output [open "SendingRate_CCID3.xg" w]
$ns at 0.0 "plotSendingRate $dccp1 $output"

# Plot sample RTT DCCP CCID 3
proc plotDCCPrtt {dccpSource output} {
	global ns dccp1
	set rtt [$dccpSource set s_r_sample_ ]
	set now [$ns now]
	puts $output "$now $rtt"
	$ns at [expr $now+1] "plotDCCPrtt $dccpSource $output"
}
set output [open "sampleRTT_CCID3.xg" w]
$ns at 0.0 "plotDCCPrtt $dccp1 $output"

# Plot srtt DCCP CCID 3
proc plotDCCPsrtt {dccpSource output} {
	global ns dccp1
	set srtt [$dccpSource set s_rtt_ ]
	set now [$ns now]
	puts $output "$now $srtt"
	$ns at [expr $now+1] "plotDCCPsrtt $dccpSource $output"
}
set output [open "srtt_CCID3.xg" w]
$ns at 0.0 "plotDCCPsrtt $dccp1 $output"

# Plot loss event rate DCCP CCID 3
proc plotDCCPloss {dccpSource output} {
	global ns dccp1
	set loss [$dccpSource set s_p_ ]
	set now [$ns now]
	puts $output "$now $loss"
	$ns at [expr $now+1] "plotDCCPloss $dccpSource $output"
}
set output [open "loss_CCID3.xg" w]
$ns at 0.0 "plotDCCPloss $dccp1 $output"

#run simulasi
$ns run
