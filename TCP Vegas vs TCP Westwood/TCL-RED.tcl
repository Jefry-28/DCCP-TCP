##################################################
#  ____________________________________________  #
# |---TCP VEGAS VS TCP WESTWOOD Simulasi 1---  | #
# |____________________________________________| #
#                                                #
##################################################

# Declare New Simulator
set ns [new Simulator]

# Setting output file
set tr [open VEGASvsTCPW.tr w]
$ns trace-all $tr
set nf [open VEGASvsTCPW.nam w]
$ns namtrace-all $nf

# Node Sender
set S1 [$ns node]
set S2 [$ns node]

# router
set R1 [$ns node]
set R2 [$ns node]

# Node Receiver
set D1 [$ns node]
set D2 [$ns node]

# Link Node Sender 1 & 2 ke Router 1
$ns duplex-link $S1 $R1 12Mb 10ms RED
$ns duplex-link $S2 $R1 12Mb 10ms RED

# Link Antar Router
$ns duplex-link $R1 $R2 12Mb 10ms RED

# Link Router 2 ke Node Receiver 1 & 2
$ns duplex-link $R2 $D1 12Mb 10ms RED
$ns duplex-link $R2 $D2 12Mb 10ms RED

# Setting Node Position
$ns duplex-link-op $S1 $R1 orient right-down
$ns duplex-link-op $S2 $R1 orient right-up
$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $R2 $D1 orient right-up
$ns duplex-link-op $R2 $D2 orient right-down

# Setting Queue Length
$ns queue-limit $R1 $R2 15

# Monitor the queue for link (r1-r2). (for NAM)
$ns duplex-link-op $R1 $R2 queuePos 0.5

#setting antrian RED
Queue/RED set thresh_ 15
Queue/RED set maxthresh_ 60

# Setting TCP Agent
set tcp1 [new Agent/TCP/Vegas]
set tcpsink1 [new Agent/TCPSink]
$ns at 0 
$ns attach-agent $S1 $tcp1
$ns attach-agent $D1 $tcpsink1
$ns connect $tcp1 $tcpsink1
$ns color 1 Red
$tcp1 set packetSize_ 1500
$tcp1 set window_ 1000
$tcp1 set fid_ 1

set tcp2 [new Agent/TCP/Linux]
set tcpsink2 [new Agent/TCPSink]
$ns at 0 "$tcp2 select_ca westwood"
$ns attach-agent $S2 $tcp2
$ns attach-agent $D2 $tcpsink2
$ns connect $tcp2 $tcpsink2
$ns color 2 Blue
$tcp2 set packetSize_ 1500
$tcp2 set window_ 1000
$tcp2 set fid_ 2

# FTP
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP

# Setting Procedure Finish
proc finish {} {
	global ns tr nf
	$ns flush-trace
	close $nf
	close $tr
	exec awk -f TCP1vsTCP2.awk VEGASvsTCPW.tr &
	exit 0
}

# Plot Congestion Window 2 TCP
proc plotWindow {tcpSource1 tcpSource2 outfile} {
   global ns
   set now [$ns now]
   set cwnd1 [$tcpSource1 set cwnd_]
   set cwnd2 [$tcpSource2 set cwnd_]

   puts $outfile "$now $cwnd1 $cwnd2"
   $ns at [expr $now+0.1] "plotWindow $tcpSource1 $tcpSource2 $outfile" 
}
# setup plotting Congestion Window 2 TCP
set outfile [open "cwnd_TCP.xg" w]

# Plot sample RTT 2 TCP
proc plotRtt {tcpSource1 tcpSource2 output} {
   global ns tcp
   set now [$ns now]
   set rtt1 [$tcpSource1 set rtt_ ]
   set rtt2 [$tcpSource2 set rtt_ ]

   puts $output "$now $rtt1 $rtt2"
   $ns at [expr $now+1] "plotRtt $tcpSource1 $tcpSource2 $output"
}
# setup plotting sample RTT 2 TCP
set output [open "sampleRTT_TCP.xg" w]


# run simulasi
$ns at 0.1 "plotWindow $tcp1 $tcp2 $outfile"
$ns at 0.1 "plotRtt $tcp1 $tcp2 $output"
$ns at 0.1 "$ftp1 start"
$ns at 0.1 "$ftp2 start"
$ns at 500.0 "$ftp1 stop"
$ns at 500.0 "$ftp2 stop"
$ns at 500.0 "finish"
$ns run
