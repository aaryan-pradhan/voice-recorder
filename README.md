# voice-recorder

Shows a script one paragraph at a time and records Aaryan reading each one.

## For agents

1. Write the script to a `.md` or `.txt` file. Separate clips with blank lines. Lines starting with `#` are skipped.
2. Ask Aaryan to run it in his own terminal, from the project folder (it needs a keyboard):

   ```
   ~/Documents/workspace/voice-recorder/run.sh script.md
   ```

3. Clips land in `./recordings/<script>-01.wav`, `-02.wav`, … in paragraph order.

Keys (each followed by Enter; the screen lists them at every prompt):

| Key | Does |
|---|---|
| Enter | start recording / stop / keep & go to next paragraph |
| `p` | play the take you just recorded |
| `r` | redo the take (paragraph shows again, Enter to start) |
| `p3` | play clip 3, with its text (`03`, `P3` also work) |
| `r3` | record clip 3, past or future, then carry on where you were |
| Ctrl-C | quit |

To fix a few bad clips without touching the rest: run it, type `r3`, `r5`, … at the first prompt, then Ctrl-C. Use another mic with `MIC="MacBook Air Microphone" run.sh script.md`. Tests: `./test.sh`.
