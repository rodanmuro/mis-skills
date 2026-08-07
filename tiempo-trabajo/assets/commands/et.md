---
description: Muestra la sesion abierta y cuanto llevas trabajado
allowed-tools: Bash
---
!`bash "$CLAUDE_PROJECT_DIR/.claude/skills/tiempo-trabajo/scripts/tiempo.sh" estado "$ARGUMENTS"`

Estado actual del registro de tiempo.

Reporta la salida anterior tal cual. Las horas y los totales ya vienen
calculados por el script: no los recalcules, no los estimes ni los redondees.
Si el script devolvio un error, explica que accion corresponde en su lugar.
