#Declare New Simulasi
set ns [new Simulator]

#seting output
set nf [open out.nam w]
set tf [open tcpwvstcpr.tr w]
#set nf [open Cwindow.xg]
$ns trace-all $tf
$ns namtrace-all $nf

#Setting Node
#Node Sender
set n0 [$ns node]
set n1 [$ns node]

#router
set n2 [$ns node]
set n3 [$ns node]

#Node Receiver
set n4 [$ns node]
set n5 [$ns node]

$n0 color red
$n1 color blue

#Node Pengirim
$ns duplex-link $n0 $n2 10Mb 10ms RED
$ns duplex-link $n1 $n2 10Mb 10ms RED

#Router
$ns duplex-link $n2 $n3 10Mb 10ms RED

#Node penerima
$ns duplex-link $n3 $n4 10Mb 10ms RED
$ns duplex-link $n3 $n5 10Mb 10ms RED

#Setting panjang antrian (parameter buffer yang akan di ubah2 [5,10,50,75,100,200]
$ns queue-limit $n2 $n3 8

#setting posisi
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right	
$ns duplex-link-op $n4 $n3 orient left-down
$ns duplex-link-op $n5 $n3 orient left-up

#setting antrian RED
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set maxp_ 0.02
Queue/RED set q_weight_ 0.002
Queue/RED set minthresh_ 15
Queue/RED set maxthresh_ 60

#Setting TCP 1
set tcp0 [new Agent/TCP/Linux]
$ns at 0 "$tcp0 select_ca westwood"
$tcp0 set fid_ 1
$ns color 1 red
$tcp0 set packetSize_ 1500
$tcp0 set window_ 1000
set sink0 [new Agent/TCPSink/Sack1]
set sink1 [new Agent/TCPSink]

#Setting TCP 2
set tcp1 [new Agent/TCP/Linux]
$ns at 0 "$tcp1 select_ca westwood"
$tcp1 set fid_ 2
$ns color 2 red
$tcp1 set packetSize_ 1500
$tcp1 set window_ 1000
set sink0 [new Agent/TCPSink]


$ns attach-agent $n0 $tcp0
$ns attach-agent $n1 $tcp1
$ns attach-agent $n4 $sink0
$ns attach-agent $n5 $sink1
$ns connect $tcp0 $sink0
$ns connect $tcp1 $sink1	

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

proc finish {} {
	global ns nf tf
	$ns flush-trace
	close $nf
	close $tf
	exec awk -f awkthroughput_Gunawan.awk tcpwvstcpr.tr &
	exec awk -f delay_Gunawan.awk tcpwvstcpr.tr &	
#	exec xgraph Cwindow.xg -t "TCP Reno CWND XGraph" -x "Time" -y "cwnd size" -geometry 800x400 &
	exec awk -f throughputtest.awk tcpwvstcpr.tr > dataout.xg
#	exec nam out.nam &
#	exec xgraph drop.tr -t "Drop  Reno" -x "time" -y "drop" -geometry 800x400 &
	exec awk -f drop.awk tcpwvstcpr.tr  > drop-tcp1.txt &
	exec awk -f drop.awk tcpwvstcpr.tr > drop-tcp2.txt &
	exec awk -f hitungdrop.awk tcpwvstcpr.tr  > hasilolahdrop.txt
	exit
}
proc cwnd_trace {tcpSource1 tcpSource2 outfile} {
	global ns
	set now [$ns now]
	set cwnd1 [$tcpSource1 set cwnd_]
	set cwnd2 [$tcpSource2 set cwnd_]
	puts $outfile "$now $cwnd1 $cwnd2" 
	$ns at [expr $now+0.1] "cwnd_trace $tcpSource1 $tcpSource2  $outfile"
}


set outfile [open "Cwindow.xg" w]
$ns at 0.1 "cwnd_trace $tcp0 $tcp1 $outfile"
$ns at 0.1 "$ftp0 start"
$ns at 0.1 "$ftp1 start"
$ns at 500  "finish"
$ns run
