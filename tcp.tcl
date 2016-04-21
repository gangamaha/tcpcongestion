# Creating simulator object
set ns [new Simulator]

#Colors for data flows
$ns color 1 Red
$ns color 2 Green
$ns color 3 Blue

#NAM trace file
set nf [open tcpperf.nam w]
$ns namtrace-all $nf

#Defining the finish procedure
proc finish {} {
global ns nf
$ns flush-trace
close $nf
exec nam tcpperf.nam &
exit 0
}


# Creating Nodes
set s0 [$ns node]
set s1 [$ns node]
set s2 [$ns node]
set s3 [$ns node]
set s4 [$ns node]

#Defining Links for nodes – Starting node to destination node
$ns duplex-link $s0 $s3 2Mb 10ms DropTail
$ns duplex-link $s1 $s3 2Mb 10ms DropTail
$ns duplex-link $s2 $s3 2Mb 10ms DropTail
$ns duplex-link $s3 $s4 0.5Mb 20ms DropTail


#Monitor the queue for link
$ns duplex-link-op $s3 $s4 queuePos 0.5
$ns duplex-link-op $s0 $s3 orient right-down  
$ns duplex-link-op $s1 $s3 orient right-up
$ns duplex-link-op $s2 $s3 orient down
$ns duplex-link-op $s3 $s4 orient right


#monitoring the queue limit
$ns queue-limit $s3 $s4 10

#setup a TCP Tahoe connection
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $s0 $tcp1
set sink [new Agent/TCPSink]
$ns attach-agent $s4 $sink
$ns connect $tcp1 $sink
$tcp1 set fid_ 1

#setup a TCP Reno connection
set tcp2 [new Agent/TCP/Reno]
$ns attach-agent $s1 $tcp2
set sink [new Agent/TCPSink]
$ns attach-agent $s4 $sink
$ns connect $tcp2 $sink
$tcp1 set fid_ 2

#setup a TCP Vegas connection
set tcp3 [new Agent/TCP/Vegas]
$ns attach-agent $s2 $tcp3
set sink [new Agent/TCPSink]
$ns attach-agent $s4 $sink
$ns connect $tcp3 $sink
$tcp1 set fid_ 3

# Setup a FTP
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP
$ftp1 set packet_size_ 1000
$ftp1 set rate_ 1mb
$ftp1 set random_ false

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP
$ftp2 set packet_size_ 1000
$ftp2 set rate_ 1mb
$ftp2 set random_ false

set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ftp3 set type_ FTP
$ftp3 set packet_size_ 1000
$ftp3 set rate_ 1mb
$ftp3 set random_ false

#Specify the simulation duration for each TCP Connection 
$ns at 0.1 "$ftp1 start"
$ns at 8.1 "$ftp1 stop"

$ns at 8.4 "$ftp2 start"
$ns at 16.4 "$ftp2 stop"

$ns at 16.8 "$ftp3 start"
$ns at 24.8 "$ftp3 stop"

proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
set wnd [$tcpSource set window_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}

# Using xgraph to generate comparison graphs
set print1 [open tahoeconges.tr w]
$ns at 0.0 "plotWindow $tcp1 $print1"

set print2 [open renoconges.tr w]
$ns at 0.0 "plotWindow $tcp2 $print2"

set print3 [open vegasconges.tr w]
$ns at 0.0 "plotWindow $tcp3 $print3"
$ns at 30.0 "finish"
$ns run
