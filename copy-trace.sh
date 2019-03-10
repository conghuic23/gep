set -x

echo 0 > /sys/kerenl/debug/tracing/tracing_on
cat /sys/kernel/debug/tracing/trace > /data/trace
