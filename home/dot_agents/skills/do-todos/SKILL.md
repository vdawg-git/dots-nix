---
name: do-todos
description: Find comments starting  with todo and applies what they say
disable-model-invocation: true
---

Find all code comments which start with "Todo" (case-insensitive) and create a plan on how to process them.
Interview me if you need more infos.

*AFTER* you created a plan start subagents which work on the different steps.
Load the `tdd` skill too.

If a comment is about code-style or things which you should know, update the AGENTS.md or agents.md so that you dont do whatever the comment says again in the future.

Do not delete the todo comments fully, instead change them to "done-todo" 

If a comment is asking a question just answer it in the chat and then resolve it by changing it to "done-todo" with your answer.
If the question suggests a different way, explain your reasoning and interview me about it as maybe you should change it, but maybe not.

If a comment starts with todo-later ignore it unless there are only todo-later comments left.



