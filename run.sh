#!/bin/bash
# Record one WAV per paragraph of a script. Usage: run.sh script.md
[ -f "$1" ] || { echo "usage: $0 script.md"; exit 1; }
name=$(basename "${1%.*}")
mkdir -p recordings
n=0

rec() {
  n=$((n+1))
  f=$(printf "recordings/%s-%02d.wav" "$name" "$n")
  printf "\n[%d] %s\n\n" "$n" "$para"
  read -rp "Enter to start" </dev/tty
  ffmpeg -loglevel error -f avfoundation -i ":${MIC:-default}" -y "$f" </dev/null &
  pid=$!
  read -rp "Recording... Enter to stop" </dev/tty
  kill -INT "$pid"; wait "$pid"
  echo "saved $f"
}

para=""
while IFS= read -r line || [ -n "$line" ]; do
  [[ $line == \#* ]] && continue
  if [ -z "${line// }" ]; then
    [ -n "$para" ] && rec
    para=""
  else
    para="${para:+$para }$line"
  fi
done < "$1"
[ -n "$para" ] && rec
