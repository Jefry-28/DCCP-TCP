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

	if (event =="r" && pkt_type == "DCCP_Data" && to_node==5) {
		recvdSize+=pkt_size;
	}
	if (event =="d" && pkt_type == "DCCP_Data"){
		drop++;
	}
}

END {
	print "\n";
	print " DCCP CCID 3";
	print " Throughput [mbps] : "(recvdSize*8/1024/1024)/time " mbps";
	print " Drop	: "drop" paket";
}
