BEGIN {
	recvdSize=0;
	drop=0;
	time=0;
}

{
	event=$1;
	time=$2;
	from_node=$3;
	to_node=$4;
	pkt_type=$5;
	pkt_size=$6;
	flow_id=$8;
	src_addr=$9;
	dst_addr=$10;

	if (event =="r" && pkt_type == "tcp" && to_node==4) {
		recvdSize+=pkt_size;
	}
	if (event =="d" && pkt_type == "tcp"){
		drop++;
	}
}

END {
	print "\n";
	print " TCP Westwood ";
	print " Throughput [mbps] : "(recvdSize*8/1024/1024)/time" mbps";
	print " Drop TCP	: "drop" paket";
	print "\n";
}
