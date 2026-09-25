# Task Router

Route every non-trivial request through the Context Gateway first.

1. Build a demand model.
2. Create a minimum-sufficient context package.
3. Select the smallest agent workflow that satisfies the task.
4. Escalate context or capability only when evidence requires it.

Runtime command:

```bash
python3 .clae/scripts/clae.py package --task "<task>" --task-id <id>
```
