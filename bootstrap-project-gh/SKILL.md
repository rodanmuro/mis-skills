---
name: bootstrap-project-gh
description: Crea un proyecto nuevo dado un nombre, inicializa Git local dentro de la carpeta, crea el repositorio remoto en GitHub usando gh y hace push inicial. Luego instala skills desde un repositorio fuente (por defecto rodanmuro/mis-skills) en .claude/skills y .codex/skills del proyecto creado. Usar cuando se solicite bootstrap de proyecto con git+github+skills para agentes.
---

# Bootstrap Project GH

Ejecutar un flujo determinista para crear un proyecto nuevo con Git local, publicarlo con `gh` e instalar skills para Claude y Codex.

## Entradas

- `project_name` obligatorio. Usar exactamente ese nombre para carpeta y repo en GitHub.
- `base_dir` opcional. Si no se especifica, usar el directorio actual.
- `visibility` opcional: `private` por defecto, o `public` si se solicita.
- `skills_repo` opcional: por defecto `rodanmuro/mis-skills`.

## Flujo

1. Validar prerequisitos:
- `git` disponible.
- `gh` disponible y autenticado (`gh auth status`).
2. Definir rutas:
- `target_dir="$base_dir/$project_name"`.
3. Crear proyecto local:
- Crear carpeta `target_dir`.
- Ejecutar `git init` solo dentro de `target_dir`.
- Crear `README.md` con explicacion breve del bootstrap y de los perfiles cubiertos por `.gitignore`.
- Crear `.gitignore` base multi-stack para:
  - Frontend React + Vite
  - Python backend (FastAPI, Django, Flask)
  - PHP backend (Laravel, CodeIgniter)
  - Java backend (Spring Boot)
- Hacer commit inicial.
4. Crear repo remoto y publicar:
- Ejecutar `gh repo create "$project_name" --<visibility> --source=. --remote=origin --push` desde `target_dir`.
5. Instalar skills para agentes dentro del proyecto creado:
- Crear `.claude/skills` y `.codex/skills`.
- Clonar temporalmente `skills_repo` con `--depth 1`.
- Copiar cada carpeta de skill del repo fuente a `.claude/skills/<skill>` y `.codex/skills/<skill>`.
- No copiar la metadata Git del repo fuente (`.git`).
6. Verificar resultado:
- Confirmar que existen `.claude/skills/*/SKILL.md` y `.codex/skills/*/SKILL.md`.
7. Persistir cambios:
- Hacer commit de skills instalados.
- Hacer push.

## Script recomendado

Usar `scripts/bootstrap_project.sh` para evitar errores manuales.

Ejemplo:

```bash
bash scripts/bootstrap_project.sh orm-saber-icfes-calificacion-v2 \
  --base-dir /ruta/trabajo \
  --visibility private \
  --skills-repo rodanmuro/mis-skills
```

## Reglas

- No ejecutar `git init` fuera de la carpeta del proyecto nuevo.
- No sobrescribir una carpeta de proyecto ya existente.
- Mantener el repo fuente de skills como clon temporal y eliminarlo al final.
- Incluir en `README.md` una seccion corta que explique que el `.gitignore` ya trae perfiles para React/Vite, FastAPI/Django/Flask, Laravel/CodeIgniter y Spring Boot.
- Reportar URL del repo GitHub creado y resumen de archivos/copias realizadas.
