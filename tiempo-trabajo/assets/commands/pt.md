---
description: Pausa la sesion de trabajo en curso
argument-hint: [motivo opcional]
allowed-tools: Bash
---
!`bash "$CLAUDE_PROJECT_DIR/.claude/skills/tiempo-trabajo/scripts/tiempo.sh" pausa "$ARGUMENTS"`

Se pauso la sesion.

Reporta la salida anterior tal cual. Las horas y los totales ya vienen
calculados por el script: no los recalcules, no los estimes ni los redondees.
Si el script devolvio un error, explica que accion corresponde en su lugar.
