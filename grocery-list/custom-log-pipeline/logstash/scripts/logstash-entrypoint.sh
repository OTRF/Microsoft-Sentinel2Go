#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# ********* Setting LS_JAVA_OPTS ***************
if [[ -z "$LS_JAVA_OPTS" ]]; then
  while true; do
    # Check using more accurate MB
    AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024}' /proc/meminfo)
    if [ "$AVAILABLE_MEMORY" -ge 900 ] && [ "$AVAILABLE_MEMORY" -le 1000 ]; then
      LS_MEMORY="400m"
      LS_MEMORY_HIGH="1000m"
    elif [ "$AVAILABLE_MEMORY" -ge 1001 ] && [ "$AVAILABLE_MEMORY" -le 3000 ]; then
      LS_MEMORY="700m"
      LS_MEMORY_HIGH="1300m"
    elif [ "$AVAILABLE_MEMORY" -gt 3000 ]; then
      # Set high & low, so logstash doesn't use everything unnecessarily, it will usually flux up and down in usage -- and doesn't "severely" despite what everyone seems to believe
      LS_MEMORY="$(( AVAILABLE_MEMORY / 4 ))m"
      LS_MEMORY_HIGH="$(( AVAILABLE_MEMORY / 2 ))m"
      if [ "$AVAILABLE_MEMORY" -gt 31000 ]; then
        LS_MEMORY="8000m"
        LS_MEMORY_HIGH="31000m"
      fi
    else
      echo "$HELK_ERROR_TAG $LS_MEMORY MB is not enough memory for Logstash yet.."
      sleep 1
    fi
    export LS_JAVA_OPTS="${HELK_LOGSTASH_JAVA_OPTS} -Xms${LS_MEMORY} -Xmx${LS_MEMORY_HIGH} "
    break
  done
fi
echo "Setting LS_JAVA_OPTS to $LS_JAVA_OPTS"

# ********* Setting Logstash PIPELINE_WORKERS ***************
if [[ -z "$PIPELINE_WORKERS" ]]; then
  # Get total CPUs/cores as reported by OS
  TOTAL_CORES=$(getconf _NPROCESSORS_ONLN 2>/dev/null)
  # try one more way
  [ -z "$TOTAL_CORES" ] && TOTAL_CORES=$(getconf NPROCESSORS_ONLN)
  # Unable to get reported cores
  if [ -z "$TOTAL_CORES" ]; then
    TOTAL_CORES=1
    echo "$HELK_ERROR_TAG unable to get number of CPUs/cores as reported by the OS"
  fi
  # Set workers based on available cores
  if [ "$TOTAL_CORES" -ge 1 ] && [ "$TOTAL_CORES" -le 3 ]; then
    PIPELINE_WORKERS=1
    # Divide by 2
  elif [ "$TOTAL_CORES" -ge 4 ]; then
    PIPELINE_WORKERS="$(( TOTAL_CORES / 2 ))"
  # some unknown number
  else
    echo "[!] eported CPUs/cores not an integer? not greater or equal to 1.."
    PIPELINE_WORKERS=1
  fi
  export PIPELINE_WORKERS
fi
echo "Setting PIPELINE_WORKERS to ${PIPELINE_WORKERS}"

# *** Remove Default config ****
rm -f /usr/share/logstash/pipeline/logstash.conf

# ********** Starting Logstash *****************
echo "Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint
