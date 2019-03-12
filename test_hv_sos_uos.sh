set -x
SOS=root@10.239.153.26

adb root
adb push enable-trace-uos.sh /data
adb push copy-trace.sh /data
scp enable-trace.sh $SOS:~/
scp acrntrace $SOS:~/

ssh $SOS "rm -rf ~/0 ~/1 ~/2 ~/3"

ssh ${SOS} "/root/acrntrace -c -i 500 -r 64" > log_trace 2>&1 &
ssh $SOS "/root/enable-trace.sh"
sleep 0.2
ssh $SOS "echo > /sys/kernel/debug/tracing/trace"

adb shell sh /data/enable-trace-uos.sh
echo "!!!Start the test, please press the button within 20 seconds!!!"
sleep 10
ssh $SOS "echo 0 > /sys/kernel/debug/tracing/tracing_on"
ssh ${SOS} "pkill acrntrace"
adb shell sh /data/copy-trace.sh
adb pull /data/trace trace_uos

ssh $SOS "cp /sys/kernel/debug/tracing/trace /root/trace"
scp $SOS:/root/trace  trace_sos
sleep 1
for((i = 0; i < 4; i++))
do
	scp -r $SOS:/root/$i .
	./acrntrace_format.py formats $i > $i.txt
done
./gep.py trace_sos
#./gep.py trace_uos
