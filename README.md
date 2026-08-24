# mis-skills

Repositorio de skills para agentes de IA (Claude Code y Codex).

Cubren el ciclo de trabajo completo sobre un proyecto: crearlo, darle estructura,
medir el tiempo que se le dedica y dejar registro de cada avance.

## Skills

| Skill | Qué hace | Cómo se invoca |
|---|---|---|
| [`bootstrap-project-gh`](bootstrap-project-gh/) | Crea el proyecto, `git init`, publica el repo en GitHub con `gh` e instala estos skills dentro | `/bootstrap-project-gh <nombre>` |
| [`init-project-base`](init-project-base/) | Crea `planeacion/`, `bitacoras/` y `src/` con sus plantillas base | `/init-project-base` |
| [`tiempo-trabajo`](tiempo-trabajo/) | Mide el tiempo real de desarrollo por sesiones | `/it` `/pt` `/rt` `/ft` `/et` `/tt` en Claude Code, o `bash .agents/skills/tiempo-trabajo/scripts/tiempo.sh <accion>` en Codex |
| [`create-bitacora`](create-bitacora/) | Crea la bitácora del avance; incluye tiempo dedicado si `tiempo-trabajo` está disponible | `/create-bitacora` |

## Cómo encajan

```
bootstrap-project-gh          crea el proyecto y publica el repo
        └── init-project-base     estructura de carpetas y plantillas
                └── tiempo-trabajo    /it ... trabajo ... /ft
                        └── create-bitacora   registra el avance + el tiempo
                                └── /tt       total dedicado al proyecto
```

`create-bitacora` es independiente de `tiempo-trabajo`: siempre debe crear la
bitácora aunque el medidor de tiempo no exista, no esté instalado o falle. Si
`tiempo-trabajo` está disponible, `create-bitacora` puede consumir el tiempo
pendiente y escribirlo como bloque `## Tiempo`. La bitácora es el registro
permanente; no hay una base de datos de tiempos aparte.

## Rutas de instalación

Claude Code y Codex cargan skills desde carpetas distintas:

| Agente | Skills globales | Skills de proyecto |
|---|---|---|
| Claude Code | `~/.claude/skills/<skill>/SKILL.md` | `.claude/skills/<skill>/SKILL.md` |
| Codex | `~/.agents/skills/<skill>/SKILL.md` | `.agents/skills/<skill>/SKILL.md` |

Este repositorio instala skills de proyecto. Por eso cada skill debe copiarse en
ambas rutas cuando el proyecto vaya a usarse con ambos agentes.

## Instalación

`bootstrap-project-gh` instala todos los skills automáticamente al crear un
proyecto, clonando este repositorio y copiándolos a `.claude/skills/` y
`.agents/skills/`.

Para instalarlos a mano en un proyecto que ya existe:

```bash
git clone --depth 1 git@github.com:rodanmuro/mis-skills.git /tmp/mis-skills
mkdir -p .claude/skills .agents/skills
for skill in /tmp/mis-skills/*/; do
  test -f "$skill/SKILL.md" || continue
  cp -R "$skill" ".claude/skills/$(basename "$skill")"
  cp -R "$skill" ".agents/skills/$(basename "$skill")"
done
```

`tiempo-trabajo` necesita además un paso de instalación por proyecto para Claude
Code. Ese paso copia sus comandos a `.claude/commands/` y registra el hook de
actividad en `.claude/settings.json`:

```bash
bash .claude/skills/tiempo-trabajo/scripts/tiempo.sh instalar
```

En Codex no hay comandos de Claude Code ni hook `.claude/settings.json`. El
script principal queda disponible desde la copia del skill:

```bash
bash .agents/skills/tiempo-trabajo/scripts/tiempo.sh estado
```

## Actualización

**Los skills instalados en un proyecto son copias congeladas.** Se copian una vez
y no se actualizan solas: una mejora hecha aquí no llega a ningún proyecto ya
creado hasta que se vuelvan a copiar.

Para actualizar un proyecto, repetir los pasos de instalación manual. Conviene
verificar antes qué difiere:

```bash
diff -r /tmp/mis-skills/create-bitacora .claude/skills/create-bitacora
diff -r /tmp/mis-skills/create-bitacora .agents/skills/create-bitacora
```

## Convenciones

- Cada skill vive en su carpeta con un `SKILL.md` en la raíz.
- El frontmatter lleva `name` y `description`; `disable-model-invocation: true`
  en los que solo debe disparar el usuario, nunca el modelo por su cuenta.
- Los scripts van en `scripts/`, las plantillas y archivos a copiar en `assets/`.
- Lo que deba ser exacto (fechas, horas, cálculos) se resuelve en un script, no
  en el LLM.
- Las referencias a archivos usan rutas relativas dentro del proyecto.

## Referencias

- Claude Code skills: https://code.claude.com/docs/en/skills
- Codex customization: https://developers.openai.com/codex/customization/overview
