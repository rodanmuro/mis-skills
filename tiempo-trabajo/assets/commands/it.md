---
description: Inicia una sesion de trabajo y marca la hora exacta
argument-hint: [nota opcional]
allowed-tools: Bash
---
!`bash "$CLAUDE_PROJECT_DIR/.claude/skills/tiempo-trabajo/scripts/tiempo.sh" inicio "$ARGUMENTS"`

Se abrio una sesion de trabajo.

Reporta la salida anterior tal cual. Las horas y los totales ya vienen
calculados por el script: no los recalcules, no los estimes ni los redondees.
Si el script devolvio un error, explica que accion corresponde en su lugar.
