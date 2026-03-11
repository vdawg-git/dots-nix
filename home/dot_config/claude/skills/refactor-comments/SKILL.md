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

