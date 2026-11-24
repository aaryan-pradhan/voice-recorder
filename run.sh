#!/bin/bash
# Record one WAV per paragraph of a script. Usage: run.sh script.md
[ -f "$1" ] || { echo "usage: $0 script.md"; exit 1; }
name=$(basename "${1%.*}")
mkdir -p recordings

paras=() para=""
while IFS= read -r line || [ -n "$line" ]; do
  [[ $line == \#* ]] && continue
  if [ -z "${line// }" ]; then
    [ -n "$para" ] && paras+=("$para")
    para=""
  else
    para="${para:+$para }$line"
  fi
done < "$1"
[ -n "$para" ] && paras+=("$para")

clip() { printf "recordings/%s-%02d.wav" "$name" "$1"; }
show() { printf "\n[%d] %s\n\n" "$1" "${paras[$1-1]}"; }
ask() { printf '  %s\n> ' "$1"; read -r key || { echo; exit; }; }

take() {
  local f; f=$(clip "$1")
  ffmpeg -loglevel error -f avfoundation -i ":${MIC:-default}" -y "$f" </dev/null &
  local pid=$!
  printf 'Recording... Enter = stop'; read -r _
  kill -INT "$pid" 2>/dev/null; wait "$pid"
  echo "saved $f"
}

play() {
  local f; f=$(clip "$1")
  [ -f "$f" ] || { echo "no clip $1 yet"; return; }
  show "$1"; echo "playing $f"; afplay "$f"
}

# pN or rN at any prompt; then back to paragraph $2
jump() {
  if [[ $key =~ ^([pPrR])0*([0-9]+)$ ]]; then
    local k=${BASH_REMATCH[1]} n=${BASH_REMATCH[2]}
    if ((n < 1 || n > ${#paras[@]})); then echo "no paragraph $n (script has 1-${#paras[@]})"
    elif [[ $k == [pP] ]]; then play "$n"
    else record "$n"; fi
  else
    echo "unknown: $key"
  fi
  show "$2"
}

record() {
  local n=$1
  show "$n"
  while :; do
    ask "Enter = start recording · p3 = play clip 3 · r3 = record clip 3 · Ctrl-C = quit"
    [ -z "$key" ] || { jump "$n"; continue; }
    take "$n"
    while :; do
      ask "Enter = keep & next · p = play this take · r = redo · p3 = play clip 3 · r3 = record clip 3"
      case $key in
        "") done_[n]=1; return ;;
        [pP]) play "$n" ;;
        [rR]) show "$n"; continue 2 ;;
        *) jump "$n" ;;
      esac
    done
  done
}

done_=() # clips kept this session
for ((n = 1; n <= ${#paras[@]}; n++)); do
  if [ -n "${done_[n]}" ]; then printf '\n%d already recorded\n' "$n"; else record "$n"; fi
done
