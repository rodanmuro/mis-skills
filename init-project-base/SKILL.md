---
name: init-project-base
description: Inicializa la estructura base de un proyecto con carpetas planeacion, bitacoras y src; crea fundacionales.md, metodologia.md y bitacora-template.md. Usar al iniciar un proyecto nuevo.
disable-model-invocation: true
---

# Init Project Base

Inicializar la estructura base del proyecto sin sobrescribir archivos existentes.

## Flujo

1. Verificar que estas en la raiz del proyecto.
2. Crear, si no existen, las carpetas `planeacion/`, `bitacoras/` y `src/`.
3. Crear `planeacion/descripcion_fundacional_proyecto.md` usando `assets/fundacionales.md` como base.
4. Crear `bitacoras/metodologia.md` usando `assets/metodologia.md` como base.
5. Crear `bitacoras/bitacora-template.md` usando `assets/bitacora-template.md` como base.
6. No crear carpetas tecnicas fuera de `src/`.
7. No sobrescribir archivos existentes. Si existen, reportar y continuar.

## Reglas

- Considerar `planeacion/fundacionales.md` como archivo que luego completa el usuario.
- Mantener toda estructura tecnica dentro de `src/` (codigo, `.env`, tests, frontend, backend, entornos virtuales, etc.).
- Al finalizar, reportar en formato: creados, existentes, omitidos, errores.

## Recursos

- Plantilla fundacional: `assets/fundacionales.md`
- Metodologia: `assets/metodologia.md`
- Template de bitacora: `assets/bitacora-template.md`
