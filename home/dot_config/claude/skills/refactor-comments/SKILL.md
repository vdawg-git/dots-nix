---
name: refactor
description: Find comments starting  with refactor and applies what they say
disable-modal-invocation: true
---

Find all code comments which start with "Refactor" (case-insensitive) and create a plan on how to process them.
Interview me if you need more infos.

*AFTER* you created a plan start subagents which work on the different steps.

If a comment is about code-style or things which you should know, update the CLAUDE.md so that you dont do whatever the comment says again in the future.

Do not delete the refactor comments fully, instead change them to "done-refactor" <short-explanation>

If a comment is asking a question just answer it in the chat and resolve it later.
If the question suggests a different way, explain your reasoning and interview me about it as maybe you should change it, but maybe not.
