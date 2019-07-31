BEGIN {
	Pktsize1 = 0;
	Pktsize2 = 0;
	timenow = -1;
	drop0	= 0;
	startTime = 1e6;
	rcvpaket= 0;
	recvdPkt= 0;
	dropx=0;
	highpktid=0;
}
{
	event=$1;
	time=$2;
	from=$3;
	to=$4;
	pkt_type=$5;
	pkt_size=$6;
	flow_id=$8;
	src_addr=$9;
	dst_addr=$10;
	seq_no= $11;
	pkt_id= $12;
	
	#(throughput)report pkt size rcvd,count pkt rcvd by node,pkt size rcvd by node. 
	if($1=="r" && $5=="tcp"){
		if($4==4){
			Pktsize1=Pktsize1+$6
			pktA++;		
		}
		if($4==5){
			Pktsize2=Pktsize2+$6
			pktB++;	  	
		}
		if($2>50){
			if($4==4){
			pktsizeA1=pktsizeA1+$6		
		}}
		if($2>50){
			if($4==5){
			pktsizeA2=pktsizeA2+$6		
		}}
		rcvpaket=pktA+pktB;
	}
	#report drop.
	if($1=="d" && $5=="tcp"){
		drop++;		
	}
	
}
END {
		printf("\n");
	print(" ======================================================= ");
	print("+  Flow Type    : TCP Westwood vs TCP Reno              +");
	print("+  Simulasi     : 1                                     +");
	print("+  Hasil        : Throughput,Packet Drop,   +");
	print("+                  Delay,            +");
	print(" ======================================================= ");	
	
	
	print"\nThroughput tcp1 :"(Pktsize1*8/1024/1024)/$2 " Mbps";
	print"\nThroughput tcp2 :"(Pktsize2*8/1024/1024)/$2 " Mbps";
	print"\nThroughput tcp1 @50-100 :"(pktsizeA1*8/1024/1024)/$2 " Mbps";
	print"\nThroughput tcp2 @50-100 :"(pktsizeA2*8/1024/1024)/$2 " Mbps";
	print"\nDrop		:"drop" paket";
	#print"\nA received	:"pktA;
	#print"\nB received	:"pktB;
	#print"\ntotal received	:"rcvpaket;
	
}
