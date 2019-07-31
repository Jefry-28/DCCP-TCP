##################################################
#  ____________________________________________  #
# |---TCP VEGAS VS TCP WESTWOOD Simulasi 1---  | #
# |____________________________________________| #
#                                                #
##################################################

#Declare New Simulator
set ns [new Simulator]


#Setting output file
set nf [open out.nam w]
set tf [open tcpwvstcpr.tr w]
#set nf [open Cwindow.xg]
$ns trace-all $tf
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
$ns queue-limit $R1 $R2 2

#setting antrian RED
#Queue/RED set bytes_ false
#Queue/RED set queue_in_bytes_ false
#Queue/RED set gentle_ false
#Queue/RED set maxp_ 0.02
#Queue/RED set q_weight_ 0.002
#Queue/RED set thresh_ 2
#Queue/RED set maxthresh_ 20

#Monitor the queue for link (r1-r2). (for NAM)
#$ns duplex-link-op $R1 $R2 queuePos 0.5

#Setting TCP 2
set tcp1 [new Agent/TCP/Reno]
set tcpsink1 [new Agent/TCPSink]
$tcp1 set fid_ 1
$ns color 1 Red
$tcp1 set packetSize_ 1500
$tcp1 set window_ 1000
#set sink1 [new Agent/TCPSink]
#set sink2 [new Agent/TCPSink]
$ns attach-agent $S1 $tcp1
$ns attach-agent $D1 $tcpsink1
$ns connect $tcp1 $tcpsink1

# Setting TCP Agent
#set tcp1 [new Agent/TCP/Vegas]
#set tcpsink1 [new Agent/TCPSink]
#$ns at 0 
# "$tcp1 select_ca westwood"
#$ns attach-agent $S1 $tcp1
#$ns attach-agent $D1 $tcpsink1
#$ns connect $tcp1 $tcpsink1
#$tcp1 set packetSize_ 1500
#$tcp1 set window_ 1000
#$ns color 1 Red
#$tcp1 set fid_ 1

#Setting TCP 1
set tcp2 [new Agent/TCP/Linux]
set tcpsink2 [new Agent/TCPSink/Sack1]
$ns at 0 "$tcp2 select_ca westwood"
$ns attach-agent $S2 $tcp2
$ns attach-agent $D2 $tcpsink2
$ns connect $tcp2 $tcpsink2
$tcp2 set packetSize_ 1500
$tcp2 set window_ 1000
$tcp2 set fid_ 2
$ns color 2 Blue
set sink2 [new Agent/TCPSink]

#FTP
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP


#Setting Procedure Finish
proc finish {} {
	global ns tr nf
	$ns flush-trace
	close $nf
	#close $tf
	# exec awk -f TCP_throughput1.awk VEGASvsTCPW.tr &
	# exec awk -f awkthroughput_tcp.awk VEGASvsTCPW.tr &
	# exec awk -f Hasil_TCP.awk VEGASvsTCPW.tr &
	# exec awk -f throughput_newreno.awk VEGASvsTCPW.tr &
	exec awk -f awkthroughput_Gunawan.awk tcpwvstcpr.tr &
	exit 
}

# Plot Congestion Window
proc plotWindow {tcpSource1 tcpSource2 file1 file2 outfile} {
   global ns

   set time 0.1
   set now [$ns now]
   set cwnd1 [$tcpSource1 set cwnd_]
   set cwnd2 [$tcpSource2 set cwnd_]

   puts $file1 "$now $cwnd1"
   puts $file2 "$now $cwnd2"
   puts $outfile "$now $cwnd1 $cwnd2"
   $ns at [expr $now+$time] "plotWindow $tcpSource1 $tcpSource2 $file1 $file2 $outfile" 
}

set outfile [open cwnd_TCP1_TCP2.xg w]
set wf1 [open flow_1TCP.xg w]
set wf2 [open flow_2TCP.xg w]

# setup plotting cwnd
$ns at 0.1 "plotWindow $tcp1 $tcp2 $wf1 $wf2 $outfile"

# Plot sample RTT TCP
proc plotRtt {tcpSource1 tcpSource2 output} {
   global ns tcp
   set rtt1 [$tcpSource1 set rtt_ ]
   set rtt2 [$tcpSource2 set rtt_ ]
   set now [$ns now]
   puts $output "$now $rtt1 $rtt2"
   $ns at [expr $now+1] "plotRtt $tcpSource1 $tcpSource2 $output"
}

# setup plotting rtt
set output [open "sampleRTT_TCP.xg" w]
$ns at 0.1 "plotRtt $tcp1 $tcp2 $output"
$ns at 0.1 "$ftp1 start"
$ns at 0.1 "$ftp2 start"
$ns at 500 "finish"

#run simulasi
$ns run
