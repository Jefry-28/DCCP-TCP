BEGIN {
	tcp=0;
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

	if ($1=="r" && $5=="tcp" && $4==4) {
		tcp=tcp+$6
	}
}

END {
	print "\nThroughput : "(tcp*8/1024/1024)/$2 " Mbps";
}
