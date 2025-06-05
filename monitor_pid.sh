#!/bin/bash

PID=$1
INTERVAL=5  # Change this to how many seconds you want between checks

if [ -z "$PID" ]; then
  echo "Usage: $0 <PID>"
  exit 1
fi

if [ ! -d "/proc/$PID" ]; then
  echo "Error: Process $PID does not exist."
  exit 1
fi

LOGFILE="pid_${PID}_monitor_$(date '+%Y%m%d_%H%M%S').log"

echo "Monitoring PID $PID every $INTERVAL seconds..."
echo "Logging to: $LOGFILE"
echo ""

while [ -d "/proc/$PID" ]; do
  {
    echo "=== Process Analysis for PID: $PID ==="
    echo "Timestamp: $(date)"
    echo ""

    CMDLINE=$(tr -d '\0' < /proc/$PID/cmdline)
    echo "🧠 Command Line: $CMDLINE"
    echo ""

    echo "📊 CPU and Memory Usage:"
    ps -p $PID -o pid,ppid,%cpu,%mem,rss,vsz,cmd
    echo ""

    echo "📁 Open File Descriptors:"
    FD_COUNT=$(ls /proc/$PID/fd 2>/dev/null | wc -l)
    echo "Total open files: $FD_COUNT"
    echo ""

    echo "💽 Disk I/O (bytes):"
    cat /proc/$PID/io | grep -E 'read_bytes|write_bytes'
    echo ""

    echo "🌐 Network Recv-Q and Send-Q:"
    ss -ntp | grep -w "$PID" | awk '{print "Recv-Q: " $2 ", Send-Q: " $3 ", Local: " $4 ", Remote: " $5}' || echo "No TCP connections found."
    echo ""

    echo "🕒 Wait Channel (WCHAN):"
    ps -o pid,wchan,cmd -p $PID
    echo ""

    echo "📈 Real-time Resource View (1s snapshot):"
    top -b -n1 -p $PID | grep $PID
    echo ""

    echo "=== End of Report ==="
    echo ""

  } | tee -a "$LOGFILE"

  sleep $INTERVAL
done

echo "Process $PID has exited. Monitoring stopped." | tee -a "$LOGFILE"
