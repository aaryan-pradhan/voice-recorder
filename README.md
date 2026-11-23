# voice-recorder

Shows a script one paragraph at a time and records Aaryan reading each one.

## For agents

1. Write the script to a `.md` or `.txt` file. Separate clips with blank lines. Lines starting with `#` are skipped.
2. Ask Aaryan to run it in his own terminal, from the project folder (it needs a keyboard):

   ```
   ~/Documents/workspace/voice-recorder/run.sh script.md
   ```

3. Clips land in `./recordings/<script>-01.wav`, `-02.wav`, … in paragraph order.

To redo, run it again: files are overwritten. Use another mic with `MIC="MacBook Air Microphone" run.sh script.md`.
