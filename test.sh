#!/bin/bash
# Drive run.sh with fake ffmpeg/afplay and typed keys. Usage: ./test.sh
here=$(cd "$(dirname "$0")" && pwd)
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
mkdir "$t/bin"
cat > "$t/bin/ffmpeg" <<'EOF'
#!/bin/bash
echo "rec ${@: -1}" >> "$LOG"; : > "${@: -1}"
EOF
cat > "$t/bin/afplay" <<'EOF'
#!/bin/bash
echo "play $1" >> "$LOG"
EOF
chmod +x "$t/bin/"*
printf '# title\none\n\ntwo\n\nthree\n' > "$t/s.md"
fail=0

# check NAME KEYS WANT_LOG [TEXT_THE_SCREEN_MUST_SHOW]
check() {
  rm -rf "$t/recordings" "$t/log"
  out=$(cd "$t" && printf "$2" | LOG="$t/log" PATH="$t/bin:$PATH" "$here/run.sh" s.md 2>&1)
  got=$(cat "$t/log" 2>/dev/null)
  [ "$got" == "$3" ] || { printf 'FAIL %s\nwant: %s\ngot:  %s\n' "$1" "$3" "$got"; fail=1; }
  [ -z "$4" ] || grep -qF -- "$4" <<<"$out" || { echo "FAIL $1: screen lacks: $4"; fail=1; }
}

check "Enter starts, stops, keeps; clips go in order" '\n\n\n\n\n\n\n\n\n' \
'rec recordings/s-01.wav
rec recordings/s-02.wav
rec recordings/s-03.wav' 'Enter = keep & next'
check "paragraph text is shown" '\n\n\n\n\n\n\n\n\n' \
'rec recordings/s-01.wav
rec recordings/s-02.wav
rec recordings/s-03.wav' '[2] two'
check "end of input quits instead of looping" '\n\n\n\n\n' \
'rec recordings/s-01.wav
rec recordings/s-02.wav'

check "p plays this take, as often as you like" '\n\np\nP\n\n' \
'rec recordings/s-01.wav
play recordings/s-01.wav
play recordings/s-01.wav'
check "r redoes this take after Enter" '\n\nr\n\n\n\n' \
'rec recordings/s-01.wav
rec recordings/s-01.wav' 'Enter = keep & next · p = play this take · r = redo'
check "p1 before clip 1 exists says so" 'p1\n' '' 'no clip 1 yet'
check "pN plays clip N at either prompt; 01 and P work" '\n\np01\n\nP1\n' \
'rec recordings/s-01.wav
play recordings/s-01.wav
play recordings/s-01.wav' 'redo · p3 = play clip 3'
check "pN past the last paragraph says so" 'p9\n' '' 'no paragraph 9 (script has 1-3)'
check "unknown key says so" 'x\n' '' 'unknown: x'
check "rN records a future clip first, then it is skipped" 'r3\n\n\n\n\n\n\n\n\n\n' \
'rec recordings/s-03.wav
rec recordings/s-01.wav
rec recordings/s-02.wav' '3 already recorded'
check "rN from the review prompt has its own redo, then returns" '\n\nr02\n\n\nr\n\n\n\n\n\n\n\n' \
'rec recordings/s-01.wav
rec recordings/s-02.wav
rec recordings/s-02.wav
rec recordings/s-03.wav' 'redo · p3 = play clip 3 · r3 = record clip 3'
check "start prompt lists r3" 'x\n' '' 'Enter = start recording · p3 = play clip 3 · r3 = record clip 3 · Ctrl-C = quit'

[ $fail = 0 ] && echo "all tests pass"
exit $fail
