# mis-skills

Repositorio de skills para agentes de IA (Claude Code y Codex).

Cubren el ciclo de trabajo completo sobre un proyecto: crearlo, darle estructura,
medir el tiempo que se le dedica y dejar registro de cada avance.

## Skills

| Skill | Qué hace | Cómo se invoca |
|---|---|---|
| [`bootstrap-project-gh`](bootstrap-project-gh/) | Crea el proyecto, `git init`, publica el repo en GitHub con `gh` e instala estos skills dentro | `/bootstrap-project-gh <nombre>` |
| [`init-project-base`](init-project-base/) | Crea `planeacion/`, `bitacoras/` y `src/` con sus plantillas base | `/init-project-base` |
| [`tiempo-trabajo`](tiempo-trabajo/) | Mide el tiempo real de desarrollo por sesiones | `/it` `/pt` `/rt` `/ft` `/et` `/tt` |
| [`create-bitacora`](create-bitacora/) | Crea la bitácora del avance, con su tiempo dedicado | `/create-bitacora` |

## Cómo encajan

```
bootstrap-project-gh          crea el proyecto y publica el repo
        └── init-project-base     estructura de carpetas y plantillas
                └── tiempo-trabajo    /it ... trabajo ... /ft
                        └── create-bitacora   registra el avance + el tiempo
                                └── /tt       total dedicado al proyecto
```

`tiempo-trabajo` y `create-bitacora` están acoplados a propósito: al cerrar una
sesión el tiempo queda pendiente, y `create-bitacora` lo consume y lo escribe
como bloque `## Tiempo` dentro de la bitácora. La bitácora es el registro
permanente; no hay una base de datos de tiempos aparte.

## Instalación

`bootstrap-project-gh` instala todos los skills automáticamente al crear un
proyecto, clonando este repositorio y copiándolos a `.claude/skills/` y
`.codex/skills/`.

Para instalarlos a mano en un proyecto que ya existe:

```bash
git clone --depth 1 git@github.com:rodanmuro/mis-skills.git /tmp/mis-skills
mkdir -p .claude/skills
cp -r /tmp/mis-skills/*/ .claude/skills/
```

`tiempo-trabajo` necesita además un paso de instalación por proyecto, que copia
sus comandos y registra el hook de actividad:

```bash
bash .claude/skills/tiempo-trabajo/scripts/tiempo.sh instalar
```

## Actualización

**Los skills instalados en un proyecto son copias congeladas.** Se copian una vez
y no se actualizan solas: una mejora hecha aquí no llega a ningún proyecto ya
creado hasta que se vuelvan a copiar.

Para actualizar un proyecto, repetir los pasos de instalación manual. Conviene
verificar antes qué difiere:

```bash
diff -r /tmp/mis-skills/create-bitacora .claude/skills/create-bitacora
```

## Convenciones

- Cada skill vive en su carpeta con un `SKILL.md` en la raíz.
- El frontmatter lleva `name` y `description`; `disable-model-invocation: true`
  en los que solo debe disparar el usuario, nunca el modelo por su cuenta.
- Los scripts van en `scripts/`, las plantillas y archivos a copiar en `assets/`.
- Lo que deba ser exacto (fechas, horas, cálculos) se resuelve en un script, no
  en el LLM.
- Las referencias a archivos usan rutas relativas dentro del proyecto.

## Referencia

Basado en la guía de Anthropic: https://code.claude.com/docs/en/skills
