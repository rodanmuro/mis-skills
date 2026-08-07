---
description: Retoma la sesion tras una pausa
argument-hint: [nota opcional]
allowed-tools: Bash
---
!`bash "$CLAUDE_PROJECT_DIR/.claude/skills/tiempo-trabajo/scripts/tiempo.sh" retomo "$ARGUMENTS"`

Se retomo la sesion.

Reporta la salida anterior tal cual. Las horas y los totales ya vienen
calculados por el script: no los recalcules, no los estimes ni los redondees.
Si el script devolvio un error, explica que accion corresponde en su lugar.
