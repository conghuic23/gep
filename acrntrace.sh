set -x
SOS_IP=10.239.153.11
adb root
adb push enable-trace-uos.sh /data
adb push copy-trace.sh /data

ssh root@$SOS_IP "echo x86-tsc >/sys/kernel/debug/tracing/trace_clock"
scp enable-trace.sh root@${SOS_IP}:/root/enable-trace.sh
scp acrntrace root@${SOS_IP}:/root/acrntrace
adb shell sh /data/enable-trace-uos.sh

ssh root@${SOS_IP} "/root/acrntrace -c -i 500 -r 64" > log_trace 2>&1 &
ssh root@$SOS_IP "/root/enable-trace.sh"
echo "collect 5s trace..."
sleep 5
ssh root@${SOS_IP} "echo 0 > /sys/kernel/debug/tracing/tracing_on"
ssh root@${SOS_IP} "pkill acrntrace"
#ssh root@${SOS_IP} "chmod +x -R /tmp/acrntrace/*"
adb shell sh /data/copy-trace.sh

ssh root@${SOS_IP} "cp /sys/kernel/debug/tracing/trace /root/trace"
scp root@${SOS_IP}:/root/trace  trace_sos
adb pull /data/trace trace_uos
for((i = 0; i < 4; i++))
do
	scp -r root@${SOS_IP}:~/$i .
	./acrntrace_format.py formats $i > $i.txt
done

#./acrn_trace.py
./gep.py trace_sos
#./ket_simple.py trace_uos
#./ket_simple.py trace_sos

#./gep.py trace_sos
