---
name: create-bitacora
description: Crea una nueva bitacora con consecutivo, fecha y hora usando el template disponible o la plantilla embebida. Detecta la carpeta de bitacoras del proyecto y define el nombre corto segun el contenido principal registrado. Usar cuando se solicite registrar avances.
disable-model-invocation: true
---

# Create Bitacora

Crear una nueva bitacora sin recibir argumentos y sin sobrescribir archivos existentes.

## Flujo

1. Definir `bitacoras_dir`:
   - Si existe `bitacoras/`, usar `bitacoras/`.
   - Si no existe `bitacoras/` pero existe `0_planeacion/bitacoras/`, usar `0_planeacion/bitacoras/`.
   - Si no existe ninguna, crear y usar `bitacoras/`.
2. Verificar si existe `<bitacoras_dir>/bitacora-template.md`.
3. Listar `<bitacoras_dir>/` y detectar archivos que cumplan alguno de estos patrones:
   - `XXX_MM_DD_AAAA_descripcion_corta.md`
   - `XXX_DD_MM_AAAA_descripcion_corta.md`
   - Si el proyecto ya tiene bitacoras previas, conservar el formato de fecha que usan esas bitacoras.
   - Si no hay bitacoras previas, usar `MM_DD_AAAA`.
4. Obtener el ultimo consecutivo `XXX` y calcular el siguiente. Si no hay archivos previos, usar `000`.
5. Obtener fecha y hora actual del sistema en formato:
   - Fecha para nombre del archivo: `MM_DD_AAAA` por defecto, o `DD_MM_AAAA` si las bitacoras previas del proyecto usan ese formato.
   - Hora para encabezado: `HH:mm:ss` (24h)
6. Definir `descripcion_corta` automaticamente segun el contenido fundamental de la bitacora:
   - Maximo 10 palabras
   - Minusculas
   - Separadas con guion bajo
7. Crear el archivo `<bitacoras_dir>/XXX_FECHA_descripcion_corta.md`.
8. Elegir la base de contenido:
   - Si existe `<bitacoras_dir>/bitacora-template.md`, cargarlo como base.
   - Si no existe el template pero hay bitacoras previas, usar la estructura de la bitacora previa mas reciente como referencia y reemplazar todo contenido especifico por contenido real de la sesion actual.
   - Si no existe el template y tampoco hay bitacoras previas, usar la `## Plantilla` embebida en este skill como base.
9. Reemplazar o crear el titulo por: `# Bitacora XXX_FECHA HH:mm:ss descripcion_corta`.
10. Agregar un `## Summary` inmediatamente despues del encabezado como indice semantico breve para LLMs y agentes.
11. Identificar el autor y su procedencia antes de escribir la bitacora. Consultar primero estas fuentes confiables y usar la primera con un valor util:
   1. `git config --get bitacora.autor` — autor configurado especificamente para las bitacoras del proyecto.
   2. `git config --get user.name` — nombre configurado en Git.
   3. La variable de entorno `BITACORA_AUTOR`.
   4. El nombre completo (campo GECOS) del usuario del sistema actual.
   5. El nombre publico de la cuenta autenticada de GitHub, solo si `gh` esta disponible y autenticado.
   - No aceptar como nombre confiable valores vacios, correos ni nombres tecnicos genericos como `admin`, `administrador`, `root`, `user`, `usuario` o `unknown`, sin importar mayusculas o minusculas.
12. Si no hay un nombre confiable, consultar `git config --get user.email` y preguntar al usuario: indicar su nombre para configurar `git user.name`, usar el correo de Git como autor o continuar sin configurar una identidad.
   - Si indica un nombre, ejecutar `git config --local user.name "<nombre>"` y usarlo como `nombre configurado en Git`.
   - Si elige usar su correo de Git, ejecutar `git config --local bitacora.autor "<correo>"` y usarlo como `autor configurado para las bitacoras del proyecto`.
   - Estas configuraciones son locales al repositorio y evitan volver a preguntar en las siguientes bitacoras.
13. Si el usuario decide continuar sin configurar una identidad, usar la primera alternativa disponible en este orden:
   1. `git config --get user.email` — `correo configurado en Git`.
   2. El nombre de usuario del sistema actual — `usuario del sistema`.
   3. El login de la cuenta autenticada de GitHub — `cuenta autenticada de GitHub`.
   4. El autor del ultimo commit que modifico `<bitacoras_dir>/`, obtenido con `git log -1 --format=%an -- <bitacoras_dir>` — `inferido del ultimo commit de bitacoras; verificar`.
   5. `No identificado` — `no se encontro una identidad disponible`.
   - No transformar correos, logins ni nombres de usuario en nombres de persona.
   - Crear `## Autor` inmediatamente despues de `## Summary`, con una linea de la forma `- <autor> (<procedencia>)`.
14. Intentar obtener el tiempo dedicado solo si el skill `tiempo-trabajo` esta disponible:
   - Buscar el script en estas rutas, en este orden:
     - `.claude/skills/tiempo-trabajo/scripts/tiempo.sh` (Claude Code)
     - `.agents/skills/tiempo-trabajo/scripts/tiempo.sh` (Codex)
   - Si existe en alguna ruta, ejecutar `bash <script_tiempo> consumir --peek`.
   - Si devuelve un bloque `## Tiempo`, copiarlo tal cual debajo del `## Summary`.
   - Si responde que no hay tiempos pendientes, omitir la seccion `## Tiempo`.
   - Si el archivo no existe, no es ejecutable, falla, devuelve error o no responde con un bloque valido `## Tiempo`, omitir la seccion `## Tiempo` y continuar.
   - No inventar, estimar ni recalcular horas: se usa la salida literal del script.
15. Usar subtitulos `###` dentro de las secciones principales para nombrar temas concretos de la sesion, por ejemplo modulos tocados, bugs, decisiones o pendientes.
16. Completar secciones con contenido real de la sesion:
   - Que fue lo que se hizo
   - Para que se hizo
   - Que problemas se presentaron
   - Como se resolvieron
   - Que continua
17. Si se incluyo un bloque `## Tiempo` generado por `tiempo-trabajo` y el archivo de bitacora ya existe en disco, intentar ejecutar
   `bash <script_tiempo> consumir` usando la misma ruta que funciono en el `--peek` para vaciar la bandeja de pendientes.
   Nunca vaciarla antes de que la bitacora este escrita. Si el consumo falla, reportarlo brevemente y conservar la bitacora creada.

## Reglas

- No sobrescribir bitacoras existentes.
- Si hay colision de nombre, ajustar `descripcion_corta` y mantener el consecutivo calculado.
- Usar siempre `bitacoras_dir` para buscar template, listar bitacoras previas y crear la nueva bitacora.
- Preferir `bitacoras/` cuando exista; usar `0_planeacion/bitacoras/` solo cuando `bitacoras/` no exista y el proyecto ya tenga esa estructura.
- La ausencia de `<bitacoras_dir>/bitacora-template.md` no debe bloquear la creacion de la bitacora.
- Si falta toda carpeta de bitacoras, crear `bitacoras/` antes de crear la bitacora.
- Si falta el template y no hay bitacoras previas, crear la primera bitacora desde la `## Plantilla` embebida en este skill.
- Si falta el template pero hay bitacoras previas, usar la ultima solo como referencia estructural; no copiar hechos, decisiones, tiempos ni pendientes de una sesion anterior.
- Si hay bitacoras previas en formato `XXX_DD_MM_AAAA_descripcion_corta.md`, conservar ese formato para no mezclar convenciones dentro del mismo proyecto.
- El `Summary` debe quedar inmediatamente despues del titulo.
- `## Autor` debe quedar inmediatamente despues de `## Summary` e incluir el valor elegido y su procedencia.
- Si no hay un nombre confiable, preguntar al usuario antes de usar una identidad debil; solo modificar `user.name` o `bitacora.autor` despues de que el usuario elija esa opcion.
- El `Summary` debe listar los subtitulos `###` realmente usados en la bitacora, no los encabezados `##` fijos.
- El `Summary` debe funcionar como indice semantico de contenido especifico: cada linea debe apuntar a temas concretos que ayuden a ubicar informacion relevante rapidamente.
- El objetivo del `Summary` es mejorar la exploracion automatizada de bitacoras largas por parte de LLMs o agentes que necesiten ubicar antecedentes, decisiones, bugs o proximos pasos.
- La integracion con `tiempo-trabajo` es opcional y nunca debe bloquear la creacion de la bitacora.
- No asumir que `tiempo-trabajo` existe, esta instalado, esta implementado correctamente o puede ejecutarse.
- Para Claude Code, buscar skills de proyecto en `.claude/skills`.
- Para Codex, buscar skills de proyecto en `.agents/skills`.
- El bloque `## Tiempo` solo se agrega cuando `tiempo-trabajo` devuelve un bloque valido durante el `--peek`.
- Si se agrega, el bloque `## Tiempo` va despues de `## Autor` y antes de `## Que fue lo que se hizo`.
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
# Bitacora XXX_FECHA HH:mm:ss descripcion_corta

## Summary
- `###` Modulo o cambio principal
- `###` Objetivo o motivacion principal
- `###` Bug, bloqueo o decision relevante
- `###` Solucion aplicada
- `###` Siguiente paso o pendiente clave

## Autor
- Nombre o identificador (procedencia de la identidad)

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
