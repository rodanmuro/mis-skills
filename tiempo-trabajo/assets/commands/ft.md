---
description: Cierra la sesion y deja el tiempo listo para la bitacora
argument-hint: [nota] [--at HH:MM]
allowed-tools: Bash
---
!`bash "$CLAUDE_PROJECT_DIR/.claude/skills/tiempo-trabajo/scripts/tiempo.sh" fin $ARGUMENTS`

Se cerro la sesion. Si quedan tiempos pendientes, ofrece crear la bitacora con /create-bitacora.

Reporta la salida anterior tal cual. Las horas y los totales ya vienen
calculados por el script: no los recalcules, no los estimes ni los redondees.
Si el script devolvio un error, explica que accion corresponde en su lugar.
