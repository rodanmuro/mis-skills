---
name: create-bitacora
description: Crea una nueva bitacora en bitacoras con consecutivo, fecha y hora usando bitacora-template.md. El nombre corto lo define el LLM segun el contenido principal registrado. Usar cuando se solicite registrar avances.
disable-model-invocation: true
---

# Create Bitacora

Crear una nueva bitacora sin recibir argumentos y sin sobrescribir archivos existentes.

## Flujo

1. Verificar si existe `bitacoras/bitacora-template.md`.
2. Listar `bitacoras/` si existe y detectar archivos que cumplan el patron `XXX_MM_DD_AAAA_descripcion_corta.md`.
3. Obtener el ultimo consecutivo `XXX` y calcular el siguiente. Si no hay archivos previos, usar `000`.
4. Obtener fecha y hora actual del sistema en formato:
   - Fecha para nombre del archivo: `MM_DD_AAAA`
   - Hora para encabezado: `HH:mm:ss` (24h)
5. Definir `descripcion_corta` automaticamente segun el contenido fundamental de la bitacora:
   - Maximo 10 palabras
   - Minusculas
   - Separadas con guion bajo
6. Crear el archivo `bitacoras/XXX_MM_DD_AAAA_descripcion_corta.md`.
7. Elegir la base de contenido:
   - Si existe `bitacoras/bitacora-template.md`, cargarlo como base.
   - Si no existe el template pero hay bitacoras previas, usar la estructura de la bitacora previa mas reciente como referencia y reemplazar todo contenido especifico por contenido real de la sesion actual.
   - Si no existe el template y tampoco hay bitacoras previas, usar la `## Plantilla` embebida en este skill como base.
8. Reemplazar o crear el titulo por: `# Bitacora XXX_MM_DD_AAAA HH:mm:ss descripcion_corta`.
9. Agregar un `## Summary` inmediatamente despues del encabezado como indice semantico breve para LLMs y agentes.
10. Intentar obtener el tiempo dedicado solo si el skill `tiempo-trabajo` esta disponible:
   - Buscar el script en estas rutas, en este orden:
     - `.claude/skills/tiempo-trabajo/scripts/tiempo.sh` (Claude Code)
     - `.agents/skills/tiempo-trabajo/scripts/tiempo.sh` (Codex)
   - Si existe en alguna ruta, ejecutar `bash <script_tiempo> consumir --peek`.
   - Si devuelve un bloque `## Tiempo`, copiarlo tal cual debajo del `## Summary`.
   - Si responde que no hay tiempos pendientes, omitir la seccion `## Tiempo`.
   - Si el archivo no existe, no es ejecutable, falla, devuelve error o no responde con un bloque valido `## Tiempo`, omitir la seccion `## Tiempo` y continuar.
   - No inventar, estimar ni recalcular horas: se usa la salida literal del script.
11. Usar subtitulos `###` dentro de las secciones principales para nombrar temas concretos de la sesion, por ejemplo modulos tocados, bugs, decisiones o pendientes.
12. Completar secciones con contenido real de la sesion:
   - Que fue lo que se hizo
   - Para que se hizo
   - Que problemas se presentaron
   - Como se resolvieron
   - Que continua
13. Si se incluyo un bloque `## Tiempo` generado por `tiempo-trabajo` y el archivo de bitacora ya existe en disco, intentar ejecutar
   `bash <script_tiempo> consumir` usando la misma ruta que funciono en el `--peek` para vaciar la bandeja de pendientes.
   Nunca vaciarla antes de que la bitacora este escrita. Si el consumo falla, reportarlo brevemente y conservar la bitacora creada.

## Reglas

- No sobrescribir bitacoras existentes.
- Si hay colision de nombre, ajustar `descripcion_corta` y mantener el consecutivo calculado.
- La ausencia de `bitacoras/bitacora-template.md` no debe bloquear la creacion de la bitacora.
- Si falta `bitacoras/`, crear la carpeta antes de crear la bitacora.
- Si falta el template y no hay bitacoras previas, crear la primera bitacora desde la `## Plantilla` embebida en este skill.
- Si falta el template pero hay bitacoras previas, usar la ultima solo como referencia estructural; no copiar hechos, decisiones, tiempos ni pendientes de una sesion anterior.
- El `Summary` debe quedar inmediatamente despues del titulo.
- El `Summary` debe listar los subtitulos `###` realmente usados en la bitacora, no los encabezados `##` fijos.
- El `Summary` debe funcionar como indice semantico de contenido especifico: cada linea debe apuntar a temas concretos que ayuden a ubicar informacion relevante rapidamente.
- El objetivo del `Summary` es mejorar la exploracion automatizada de bitacoras largas por parte de LLMs o agentes que necesiten ubicar antecedentes, decisiones, bugs o proximos pasos.
- La integracion con `tiempo-trabajo` es opcional y nunca debe bloquear la creacion de la bitacora.
- No asumir que `tiempo-trabajo` existe, esta instalado, esta implementado correctamente o puede ejecutarse.
- Para Claude Code, buscar skills de proyecto en `.claude/skills`.
- Para Codex, buscar skills de proyecto en `.agents/skills`.
- El bloque `## Tiempo` solo se agrega cuando `tiempo-trabajo` devuelve un bloque valido durante el `--peek`.
- Si se agrega, el bloque `## Tiempo` va inmediatamente despues del `## Summary` y antes de `## Que fue lo que se hizo`.
- Si se agrega, el bloque `## Tiempo` se copia literal de `tiempo.sh consumir --peek`; sus lineas (`inicio`, `fin`, `pausas`, `bruto`, `efectivo`) son parseables por script y no se deben reformatear.
- Vaciar los tiempos pendientes solo despues de escribir la bitacora y solo si se agrego un bloque `## Tiempo`; nunca vaciarlos antes.
- Si no hay tiempos pendientes o no se puede usar `tiempo-trabajo`, la bitacora se crea igual, sin seccion `## Tiempo`.
- Mencionar siempre archivos creados/modificados.
- Si la bitacora hace referencia a archivos especificos, usar rutas relativas dentro del proyecto.
- No pegar codigo completo; registrar ideas de implementacion relevantes.
- Al finalizar, reportar ruta del archivo creado y resumen breve.

## Plantilla

Usar esta plantilla base para crear la bitacora:

```md
# Bitacora XXX_MM_DD_AAAA HH:mm:ss descripcion_corta

## Summary
- `###` Modulo o cambio principal
- `###` Objetivo o motivacion principal
- `###` Bug, bloqueo o decision relevante
- `###` Solucion aplicada
- `###` Siguiente paso o pendiente clave

## Tiempo
- inicio: AAAA-MM-DDTHH:mm:ss-05:00
- fin: AAAA-MM-DDTHH:mm:ss-05:00
- pausas: HH:MM:SS (n)
- bruto: HH:MM:SS
- efectivo: HH:MM:SS

*(Bloque opcional generado por `tiempo-trabajo`. Copiar literal; omitir la seccion completa si no hay tiempos pendientes, si el skill no existe o si no se puede ejecutar.)*

## Que fue lo que se hizo
- Usar subtitulos `###` para separar temas concretos.
- Incluya detalles de implementacion del codigo sin copiar el codigo completo; solo ideas relevantes.
- Debe indicar que archivos fueron modificados o creados usando rutas relativas.

## Para que se hizo
- Usar subtitulos `###` para identificar objetivos concretos si hubo varios.
- Cual fue el objetivo al crear los cambios.

## Que problemas se presentaron
- Usar subtitulos `###` para distinguir cada bug, bloqueo o duda importante.
- Aquellas partes de codigo que tuvieron bugs, porque:
  - Se hicieron tests automaticos y no fueron exitosos.
  - El cliente probo manualmente y pidio correcciones.

## Como se resolvieron
- Usar subtitulos `###` para cada solucion, ajuste o decision tecnica relevante.
- Explicar con detalle como fueron solucionados los bugs.
- Agregar detalles de implementacion que sustenten la solucion.

## Que continua
- Usar subtitulos `###` para cada pendiente o siguiente paso importante.
-

*(Agregar enlaces o referencias a archivos clave usando rutas relativas si aplica.)*
```
