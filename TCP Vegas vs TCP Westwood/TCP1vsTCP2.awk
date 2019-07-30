######################################################################################################
######################################################################################################
###                                                                                                ###
###       SSSSSS       KKKK    KKKK   RRRRRRRRRR     IIII   PPPPPPPPPP         SSSSSS       IIII   ###
###    SSSSSSSSSSSS    KKKK   KKKK    RRRRRRRRRRRR   IIII   PPPPPPPPPPP     SSSSSSSSSSSS    IIII   ###
###   SSSSS     SSSS   KKKK  KKKK     RRRR    RRRR   IIII   PPPP    PPPP   SSSSS     SSSS   IIII   ###
###   SSSSS            KKKK KKKK      RRRR    RRRR   IIII   PPPP    PPPP   SSSSS            IIII   ###
###    SSSSSSSSS       KKKKKKK        RRRRRRRRRR     IIII   PPPPPPPPPPP     SSSSSSSSS       IIII   ###
###       SSSSSSSS     KKKKKKK        RRRRRRRRR      IIII   PPPPPPPPP          SSSSSSSS     IIII   ###
###            SSSSS   KKKK KKKK      RRRR  RRRR     IIII   PPPP                    SSSSS   IIII   ###
###   SSSS     SSSSS   KKKK  KKKK     RRRR   RRRR    IIII   PPPP           SSSS     SSSSS   IIII   ###
###    SSSSSSSSSSSS    KKKK   KKKK    RRRR    RRRR   IIII   PPPP            SSSSSSSSSSSS    IIII   ###
###       SSSSS        KKKK    KKKK   RRRR     RRRR  IIII   PPPP               SSSSS        IIII   ###
###                                                                                                ###
######################################################################################################
######################################################################################################

# AWK untuk cari throughput, packetloss, average E2E Delay, jitter DCCP

BEGIN 
{	
	Pktsize1		= 0;
	Pktsize2		= 0;
	recvdSize 		= 0;
	startTime 		= 1e6;
	stopTime 		= 0;
	recvdNum 		= 0;
	recvdPkt1 		= 0;
	recvdPkt2 		= 0;
	highest_pkt_id 		= 0;
	countS 			= 0;
	countR 			= 0;
	count1 			= 0;
	count2			= 0;
	dropx			= 0;
}

{
	# Trace line format: normal
	if ($2 != "-t") {
		event 		= $1;
		time 		= $2;
		from 		= $3;
		to 		= $4;
		if (event == "+" || event == "-"){ 
			node_id = $3;
		}
		if (event == "r" || event == "d"){ 
			node_id = $4;
		}
		flow_t 		= $5;
		pkt_size 	= $6;
		flow_id 	= $8; #flow DCCP
		src 		= $9;
		dst 		= $10;
		seq_no 		= $11;
		pkt_id 		= $12;
		
		
	}
	
	if (flow_id == 1 && from == 0 && start_time[pkt_id] == 0 && flow_t=="tcp") {
		if (time < startTime) {
			startTime = time;
		}
		start_time[pkt_id] = time;
		countS++;
	}

	if (flow_id == 1 && flow_t=="tcp") {
		if(event == "r"){
			if (time > stopTime) {
			stopTime = time;
			}

			if(to == 4){
			Pktsize1=Pktsize1+$6
			end_time[pkt_id] = time;
			recvdPkt1++;
			count1++;
			delayA=end_time[pkt_id]-start_time[pkt_id];
			sum1+=delayA;
			}
		}

	}

	if (flow_id == 2 && from == 1 && start_time[pkt_id] == 0 && flow_t=="tcp") {
		if (time < startTime) {
			startTime = time;
		}
		start_time[pkt_id] = time;
		countR++;
	}

	if (flow_id == 2 && flow_t=="tcp") {
		if(event == "r"){
			if (time > stopTime) {
			stopTime = time;
			}
			if(to == 5){
			Pktsize2=Pktsize2+$6
			end_time[pkt_id] = time;
			recvdPkt2++;
			count2++;
			delayB=end_time[pkt_id]-start_time[pkt_id];
			sum2+=delayB;
			delayJit[count2]=delayB;
			}
		}
	}
}

END {
	avge2eDelay1=sum1/count1;
	avge2eDelay2=sum2/count2;

	printf("\n");
	print(" ======================================================= ");
	print("+  Flow Type    : TCP                                   +");
	print("+  Simulasi     : --                                    +");
	print("+  Hasil        : Throughput,Packet Drop, Packet Loss   +");
	print("+                 Average E2E Delay, Jitter             +");
	print(" ======================================================= ");
	printf("\n");
	printf(" %30s:  %s\n", "Flow Type", this_flow);
	printf(" %30s:  %d%s\n", "Start", startTime,"s");
	printf(" %30s:  %d%s\n", "Stop", stopTime,"s");
	print(" ======================================================= ");
	printf(" %30s	:  %g%s\n", "Average Throughput[Mbps] Vegas", (Pktsize1*8/1024/1024)/$2," Mbps");
	printf(" %30s	:  %g%s\n", "Average E2E delay Vegas", avge2eDelay1*1000," ms");
	printf(" %30s	:  %g%s\n", "Paket Terkirim Vegas", countS," Paket");
	printf(" %30s	:  %g%s\n", "Paket Yang diterima Vegas", recvdPkt1," Paket");
	printf(" %30s	:  %g%s\n", "Paket Drop Vegas", countS-recvdPkt1," Paket");
	printf(" %30s	:  %g%s\n", "Paket Loss Vegas", (countS-recvdPkt1)/countS*100," %");
	printf("\n");
	printf(" %30s	:  %g%s\n", "Average Throughput[Mbps] Westwood", (Pktsize2*8/1024/1024)/$2," Mbps");
	printf(" %30s	:  %g%s\n", "Average E2E delay Westwood", avge2eDelay2*1000," ms");
	printf(" %30s	:  %g%s\n", "Paket Terkirim Westwood", countR," Paket");
	printf(" %30s	:  %g%s\n", "Paket Yang diterima Westwood", recvdPkt2," Paket");
	printf(" %30s	:  %g%s\n", "Paket Drop Westwood", countR-recvdPkt2," Paket");
	printf(" %30s	:  %g%s\n", "Paket Loss Westwood", (countR-recvdPkt2)/countR*100," %");
	printf("\n")
	
}

