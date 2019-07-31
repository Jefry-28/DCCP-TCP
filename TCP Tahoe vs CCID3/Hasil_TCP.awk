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


BEGIN {	Pktsize1		=0;
	recvdSize 		= 0;
	startTime 		= 1e6;
	stopTime 		= 0;
	recvdNum 		= 0;
	recvdPkt 		= 0;
	highest_pkt_id 	= 0;
	countS 			= 0;
	countR 			= 0;
	count 			= 0;
	dropx			= 0;
}
{
	# Trace line format: normal
	if ($2 != "-t") {
		event 		= $1;
		time 		= $2;
		from 		= $3;
		to 			= $4;
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
			recvdPkt++;
			count++;
			delay=end_time[pkt_id]-start_time[pkt_id];
			sum+=delay;
			delayJit[count]=delay;
			}
		}
		

	}
}

END {
	
	avge2eDelay=sum/count;
	avgJitter=TotalJit/count;

	#Throughput = received data*8/data transmission period
	printf("\n");
	print(" ======================================================= ");
	print("+  Flow Type    : TCP Tahoe                             +");
	print("+  Simulasi     :                                       +");
	print("+  Hasil        : Throughput,Packet Drop, Packet Loss   +");
	print("+                 Average E2E Delay, Jitter             +");
	print(" ======================================================= ");
	printf("\n");
	printf(" %30s:  %s\n", "Flow Type", this_flow);
	printf(" %30s:  %d%s\n", "Start", startTime,"s");
	printf(" %30s:  %d%s\n", "Stop", stopTime,"s");
	printf(" %30s:  %g%s\n", "Average Throughput[Mbps]", (Pktsize1*8/1024/1024)/$2," Mbps");
	printf(" %30s:  %g%s\n", "average E2E delay", avge2eDelay*1000," ms");
	printf(" %30s:  %g%s\n", "Paket Terkirim", countS," Paket");
	printf(" %30s:  %g%s\n", "Paket Yang diterima", recvdPkt," Paket");
	printf(" %30s:  %g%s\n", "Paket Drop", countS-recvdPkt," Paket");
	printf(" %30s:  %g%s\n", "Paket Loss", (countS-recvdPkt)/countS*100," %");
	printf("\n")
	
}

