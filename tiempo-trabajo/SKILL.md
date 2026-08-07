---
name: tiempo-trabajo
description: Mide el tiempo real dedicado al desarrollo mediante sesiones de trabajo con inicio, pausa, retomo y fin. Todas las horas y totales los calcula scripts/tiempo.sh, nunca el LLM. Los tiempos cerrados se entregan a create-bitacora como bloque "## Tiempo". Usar para instalar el sistema en un proyecto, consultar el total dedicado o reconciliar sesiones que quedaron abiertas.
disable-model-invocation: true
---

# Tiempo Trabajo

Registrar cuanto tiempo se dedica realmente a desarrollar, sin depender de que el
LLM recuerde o estime horas.

## Principio

**Toda hora sale de `date(1)` y toda aritmetica ocurre en `scripts/tiempo.sh`.**
El agente ejecuta el script y relata su salida literal. No recalcula, no estima,
no redondea, no rellena huecos. Si el script falla, se reporta el error y se
indica la accion correcta; no se inventa el dato.

## Instalacion en un proyecto

```bash
bash scripts/tiempo.sh instalar
```

Esto hace tres cosas, y es idempotente:

1. Crea `bitacoras/tiempos/` con un `.gitignore` propio.
2. Copia los comandos de `assets/commands/` a `.claude/commands/`.
3. Agrega el hook de latido a `.claude/settings.json`, respetando lo que ya haya.

Tras instalar el hook hay que abrir `/hooks` una vez o reiniciar Claude Code para
que cargue.

## Comandos

| Comando | Accion | Que hace |
|---|---|---|
| `/it [nota]` | `inicio` | Abre una sesion de trabajo |
| `/pt [motivo]` | `pausa` | Pausa la sesion abierta |
| `/rt [nota]` | `retomo` | Reanuda tras una pausa |
| `/ft [nota] [--at HH:MM]` | `fin` | Cierra y deja el tiempo pendiente de bitacora |
| `/et` | `estado` | Que hay abierto y cuanto llevas |
| `/tt` | `reporte` | Total del proyecto |

Acciones sin comando propio, se invocan por script:

- `consumir [--peek]` — bloque `## Tiempo` para la bitacora
- `reconciliar` — reconstruye la jornada desde los latidos de actividad
- `latido` — registra actividad; lo llama el hook, nunca el usuario

## Modelo de datos

Los tiempos **no** se guardan como historico eterno. Pasan por tres estados y el
registro permanente termina siendo la bitacora:

| Estado | Archivo | Vive hasta |
|---|---|---|
| Sesion abierta | `bitacoras/tiempos/actual.tsv` | que se ejecute `fin` |
| Cerrada sin bitacora | `bitacoras/tiempos/pendientes.tsv` | que `create-bitacora` la consuma |
| Registrada | `bitacoras/XXX_*.md` → `## Tiempo` | permanente |

`actividad.log` guarda los latidos del hook como red de seguridad; se poda solo
y no es un historico.

Todo `bitacoras/tiempos/` esta en `.gitignore`: son datos transitorios. Lo que se
versiona es la bitacora.

### Por que TSV y no JSON

Para poder parsear con `awk` sin depender de `jq`, que no siempre esta instalado.
El formato interno es un detalle de implementacion: nada fuera del script lo lee.

### Por que append-only

Mientras la sesion esta abierta no se reescribe ningun total acumulado, solo se
agregan lineas. Un corte de luz o un cierre abrupto no corrompe lo ya registrado,
y el estado siempre se puede reconstruir releyendo los eventos.

## Maquina de estados

```
libre --inicio--> trabajando --pausa--> pausado --retomo--> trabajando --fin--> libre
```

Las transiciones invalidas fallan con codigo distinto de cero y mensaje explicito
(`inicio` con sesion abierta, `retomo` sin pausa previa, `fin` sin sesion). El
agente **no debe intentar corregirlas por su cuenta**: debe reportar el mensaje y
sugerir la accion que corresponde.

## Entrega a la bitacora

Orden obligatorio, para no perder datos si algo falla a mitad:

1. `tiempo.sh consumir --peek` — obtener el bloque sin vaciar nada.
2. Escribir la bitacora con ese bloque incluido.
3. `tiempo.sh consumir` — recien ahi se vacia la bandeja.

Nunca vaciar antes de que la bitacora exista en disco.

## Olvidos

El sistema asume que se van a olvidar comandos. Para eso:

- `fin` y `estado` avisan si la sesion supero `TIEMPO_TOPE_HORAS` (6 por defecto).
- `estado` propone la hora de cierre real segun el ultimo latido.
- `ft --at HH:MM` cierra con una hora pasada; el evento se agrega, nunca se edita
  el historial.
- `reconciliar` reconstruye la jornada tratando los huecos de actividad de mas de
  `TIEMPO_UMBRAL_HUECO_MIN` minutos (15 por defecto) como pausas.

## Limitaciones

- El latido **solo ve actividad dentro de Claude Code**. Si se codea a mano, se
  depura en el navegador o se lee documentacion, no se registra nada. El latido es
  un piso ("al menos estuviste activo hasta las HH:MM"), nunca la medida total.
- Los comandos manuales siguen siendo la fuente de verdad sobre la intencion: son
  los que dicen que ese rato contaba como trabajo en este proyecto.
- El registro es por proyecto. Trabajar en dos repos a la vez lleva dos sesiones
  independientes, cada una en su carpeta.

## Reglas

- No calcular ni estimar tiempos en el LLM bajo ninguna circunstancia.
- No editar a mano `actual.tsv` ni `pendientes.tsv`; usar las acciones del script.
- No versionar `bitacoras/tiempos/`.
- Reportar siempre bruto y efectivo, no solo uno de los dos.
- Al cerrar una sesion, ofrecer crear la bitacora si quedan pendientes.

## Variables de entorno

| Variable | Defecto | Efecto |
|---|---|---|
| `TIEMPO_PROYECTO` | raiz git o `pwd` | Fuerza el proyecto sobre el que se opera |
| `TIEMPO_TOPE_HORAS` | `6` | Bruto a partir del cual se avisa sesion sospechosa |
| `TIEMPO_UMBRAL_HUECO_MIN` | `15` | Hueco de actividad que cuenta como pausa |
| `TIEMPO_MAX_LATIDOS` | `5000` | Lineas antes de podar `actividad.log` |

## Recursos

- Script principal: `scripts/tiempo.sh`
- Instalador: `scripts/instalar.py`
- Comandos: `assets/commands/`
