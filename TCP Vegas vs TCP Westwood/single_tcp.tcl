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
$ns duplex-link $S1 $R1 12Mb 10ms DropTail
$ns duplex-link $S2 $R1 12Mb 10ms DropTail

# Link Antar Router
$ns duplex-link $R1 $R2 12Mb 10ms DropTail

# Link Router 2 ke Node Receiver 1 & 2
$ns duplex-link $R2 $D1 12Mb 10ms DropTail
$ns duplex-link $R2 $D2 12Mb 10ms DropTail


# Setting Node Position
$ns duplex-link-op $S1 $R1 orient right-down
$ns duplex-link-op $S2 $R1 orient right-up
$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $R2 $D1 orient right-up
$ns duplex-link-op $R2 $D2 orient right-down

# Setting Queue Length
$ns queue-limit $R1 $R2 3

# Monitor the queue for link (r1-r2). (for NAM)
$ns duplex-link-op $R1 $R2 queuePos 0.5

#setting antrian RED
#Queue/RED set thresh_ 15
#Queue/RED set maxthresh_ 60

# Setting TCP Agent
set tcp1 [new Agent/TCP/Linux]
set tcpsink1 [new Agent/TCPSink]
$ns at 0 "$tcp1 select_ca westwood"
$ns at 0 
$ns attach-agent $S1 $tcp1
$ns attach-agent $D1 $tcpsink1
$ns connect $tcp1 $tcpsink1
$ns color 1 Red
$tcp1 set packetSize_ 1500
$tcp1 set window_ 1000
$tcp1 set fid_ 1

# FTP
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

# Setting Procedure Finish
proc finish {} {
	global ns tr nf
	$ns flush-trace
	close $nf
	close $tr
	# exec awk -f single-throughput.awk VEGASvsTCPW.tr &
	exec awk -f single-TCP_Running .awk VEGASvsTCPW.tr &
	exit 0
}

# Plot Congestion Window 1 TCP
proc plotWindow {tcpSource outfile} {
   global ns
   set now [$ns now]
   set cwnd [$tcpSource set cwnd_]

   puts $outfile "$now $cwnd"
   $ns at [expr $now+0.1] "plotWindow $tcpSource $outfile" 
}

# setup plotting Congestion Window 1 TCP
set outfile [open "cwnd_TCP.xg" w]

# Plot sample RTT 1 TCP
proc plotRtt {tcpSource output} {
   global ns tcp
   set now [$ns now]
   set rtt [$tcpSource set rtt_ ]

   puts $output "$now $rtt"
   $ns at [expr $now+1] "plotRtt $tcpSource $output"
}

# setup plotting sample RTT 1 TCP
set output [open "sampleRTT_TCP.xg" w]


# run simulasi
$ns at 0.1 "plotWindow $tcp1 $outfile"
$ns at 0.1 "plotRtt $tcp1 $output"
$ns at 0.1 "$ftp1 start"
$ns at 500.0 "$ftp1 stop"
$ns at 500.0 "finish"
$ns run
