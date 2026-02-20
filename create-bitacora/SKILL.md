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
   - Maximo 5 palabras
   - Minusculas
   - Separadas con guion bajo
6. Crear el archivo `bitacoras/XXX_MM_DD_AAAA_descripcion_corta.md`.
7. Cargar `bitacoras/bitacora-template.md` como base.
8. Reemplazar el titulo por: `# Bitacora XXX_MM_DD_AAAA HH:mm:ss descripcion_corta`.
9. Completar secciones con contenido real de la sesion:
   - Que fue lo que se hizo
   - Para que se hizo
   - Que problemas se presentaron
   - Como se resolvieron
   - Que continua

## Reglas

- No sobrescribir bitacoras existentes.
- Si hay colision de nombre, ajustar `descripcion_corta` y mantener el consecutivo calculado.
- Mencionar siempre archivos creados/modificados.
- No pegar codigo completo; registrar ideas de implementacion relevantes.
- Al finalizar, reportar ruta del archivo creado y resumen breve.
