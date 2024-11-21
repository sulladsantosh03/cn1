[4]
1.Program title:
Consider a client and a server. The server is running a FTP application over TCP. The client sends a
request to download a file of size 10 MB from the server. Write a TCL script to simulate this scenario.
Let node n0 be the server and node n1 be the client. TCP packet size is 1500 Bytes.
2. Script executed in lab.
set ns [new Simulator]
set tf [open 4.tr w]
$ns trace-all $tf
set nf [open 4.nam w]
$ns namtrace-all $nf
set n0 [$ns node]
set n1 [$ns node]
$ns color 1 Blue
$n0 label "Server"
$n1 label "Client"
$ns duplex-link $n0 $n1 10Mb 22ms DropTail
$ns duplex-link-op $n0 $n1 orient right
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
$tcp set packetSize_ 1500
set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$tcp set fid_ 1
proc finish {} {
global ns tf nf
$ns flush-trace
close $tf
close $nf
exec nam 4.nam &
exec awk -f transfer.awk 4.tr &
exec awk -f convert.awk 4.tr > convert.tr
exec xgraph convert.tr -geometry 800*400 -t
"Bytes_received_at_Client" -x "Time _in_secs" -y "Bytes_in_bps" &
}
$ns at 0.01 "$ftp start"
$ns at 15.0 "$ftp stop"
$ns at 15.1 "finish"
$ns run
# transfer.awk
# AWK Script to calculate time required
BEGIN {
 count = 0;
 time = 0;
 total_bytes_received = 0;
 total_bytes_sent = 0;
}
{
 if ($1 == "r" && $4 == 1 && $5 == "tcp")
 total_bytes_received += $6;
 if ($1 == "+" && $3 == 0 && $5 == "tcp")
 total_bytes_sent += $6;
}
END {
 system("clear");
 printf("\nTransmission time required to transfer the file is %f seconds\n", time);
 printf("Actual data sent from the server is %f Mbps\n", (total_bytes_sent) / 1000000);
 printf("Data received by the client is %f Mbps\n", (total_bytes_received) / 1000000);
}
# AWK Script to convert file into graph values
BEGIN {
 count = 0;
 time = 0;
}
{
 if ($1 == "r" && $4 == 1 && $5 == "tcp") {
 count += $6;
 time = $2;
 printf("\n%f\t%f", time, (count) / 1000000);
 }
}
END {
 # No additional processing needed here
}
