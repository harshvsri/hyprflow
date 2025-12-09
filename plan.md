# Future Plans

## Post-Processing (Not a Priority Right Now)

This feature would add AI-powered transcript cleaning and formatting to improve the quality of transcribed text.

### Configuration

```bash
API_KEY="${GROQ_API_KEY:?Error: Please set API_KEY environment variable.}"
MODEL="llama-3.3-70b-versatile"
```

### System Prompt

```
System: You are an expert voice-to-text editor.
Your goal is to rewrite the following transcript to be professional, concise, and grammatically correct.

Rules:
1. Remove all filler words (um, ah, like, you know) and stutters.
2. Fix grammar and punctuation errors.
3. If the user lists multiple items, steps, or points, format them as a clean Markdown bulleted list.
4. Do not change the original meaning or tone.
5. Output ONLY the final polished text. No introductions like 'Here is the text'.
```

### Implementation Notes

- This would use Groq's API to post-process raw transcripts
- The cleaned transcript would replace the raw output before pasting
- Requires `GROQ_API_KEY` environment variable to be set
- May add latency to the transcription workflow
- Consider making this an optional toggle (e.g., `ENABLE_POSTPROCESSING=1`)
