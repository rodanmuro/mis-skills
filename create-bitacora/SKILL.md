---
name: create-bitacora
description: Crea una nueva bitacora en bitacoras con consecutivo, fecha y hora usando bitacora-template.md. El nombre corto lo define el LLM segun el contenido principal registrado. Usar cuando se solicite registrar avances.
disable-model-invocation: true
---

# Create Bitacora

Crear una nueva bitacora sin recibir argumentos y sin sobrescribir archivos existentes.

## Flujo

1. Verificar que exista `bitacoras/bitacora-template.md`. Si no existe, detenerse y explicar el error.
2. Listar `bitacoras/` y detectar archivos que cumplan el patron `XXX_MM_DD_AAAA_descripcion_corta.md`.
3. Obtener el ultimo consecutivo `XXX` y calcular el siguiente. Si no hay archivos previos, usar `000`.
4. Obtener fecha y hora actual del sistema en formato:
   - Fecha para nombre del archivo: `MM_DD_AAAA`
   - Hora para encabezado: `HH:mm:ss` (24h)
5. Definir `descripcion_corta` automaticamente segun el contenido fundamental de la bitacora:
   - Maximo 10 palabras
   - Minusculas
   - Separadas con guion bajo
6. Crear el archivo `bitacoras/XXX_MM_DD_AAAA_descripcion_corta.md`.
7. Cargar `bitacoras/bitacora-template.md` como base.
8. Reemplazar el titulo por: `# Bitacora XXX_MM_DD_AAAA HH:mm:ss descripcion_corta`.
9. Agregar un `## Summary` inmediatamente despues del encabezado como indice semantico breve para LLMs y agentes.
10. Usar subtitulos `###` dentro de las secciones principales para nombrar temas concretos de la sesion, por ejemplo modulos tocados, bugs, decisiones o pendientes.
11. Completar secciones con contenido real de la sesion:
   - Que fue lo que se hizo
   - Para que se hizo
   - Que problemas se presentaron
   - Como se resolvieron
   - Que continua

## Reglas

- No sobrescribir bitacoras existentes.
- Si hay colision de nombre, ajustar `descripcion_corta` y mantener el consecutivo calculado.
- El `Summary` debe quedar inmediatamente despues del titulo.
- El `Summary` debe listar los subtitulos `###` realmente usados en la bitacora, no los encabezados `##` fijos.
- El `Summary` debe funcionar como indice semantico de contenido especifico: cada linea debe apuntar a temas concretos que ayuden a ubicar informacion relevante rapidamente.
- El objetivo del `Summary` es mejorar la exploracion automatizada de bitacoras largas por parte de LLMs o agentes que necesiten ubicar antecedentes, decisiones, bugs o proximos pasos.
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
