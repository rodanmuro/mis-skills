#!/usr/bin/env bash
#
# tiempo.sh - Registro exacto de tiempo de trabajo.
#
# Toda hora sale de date(1) y toda aritmetica se hace aqui, nunca en el LLM.
# El agente solo invoca este script y relata su salida.
#
# Formato interno: TSV (no JSON) para poder parsear con awk sin depender de jq.
#
#   actual.tsv      epoch \t evento \t iso \t nota
#   pendientes.tsv  ini_epoch \t fin_epoch \t bruto \t pausas \t efectivo \t n_pausas \t ini_iso \t fin_iso \t nota
#   actividad.log   epoch (un latido por linea)
#
set -euo pipefail

TOPE_HORAS="${TIEMPO_TOPE_HORAS:-6}"
UMBRAL_HUECO_MIN="${TIEMPO_UMBRAL_HUECO_MIN:-15}"
MAX_LATIDOS="${TIEMPO_MAX_LATIDOS:-5000}"

# ---------------------------------------------------------------- utilidades

raiz_proyecto() {
  if [[ -n "${TIEMPO_PROYECTO:-}" ]]; then
    printf '%s\n' "$TIEMPO_PROYECTO"
    return
  fi
  local raiz
  if raiz="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    printf '%s\n' "$raiz"
  else
    pwd
  fi
}

RAIZ="$(raiz_proyecto)"
DIR="$RAIZ/bitacoras/tiempos"
ACTUAL="$DIR/actual.tsv"
PENDIENTES="$DIR/pendientes.tsv"
ACTIVIDAD="$DIR/actividad.log"

asegurar_dir() { mkdir -p "$DIR"; }

# segundos -> HH:MM:SS (soporta > 24h)
hhmmss() {
  local s=${1:-0}
  (( s < 0 )) && s=0
  printf '%02d:%02d:%02d' $((s/3600)) $((s%3600/60)) $((s%60))
}

# limpia tabuladores y saltos de linea para no romper el TSV
sanear() {
  printf '%s' "${1:-}" | tr '\t\n\r' '   ' | sed 's/  */ /g; s/^ //; s/ $//'
}

iso_de() { date -d "@$1" -Is; }
hora_de() { date -d "@$1" +%H:%M:%S; }

morir() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Reproduce el log de la sesion abierta y devuelve:
#   estado inicio marca efectivo n_pausas ultimo
calcular() {
  if [[ ! -s "$ACTUAL" ]]; then
    echo "libre 0 0 0 0 0"
    return
  fi
  awk -F'\t' '
    BEGIN { estado="libre"; inicio=0; marca=0; efectivo=0; npausas=0; ultimo=0 }
    {
      ts=$1+0; ev=$2
      if (ev=="inicio")                        { inicio=ts; marca=ts; estado="trabajando" }
      else if (ev=="pausa"  && estado=="trabajando") { efectivo+=ts-marca; estado="pausado" }
      else if (ev=="retomo" && estado=="pausado")    { marca=ts; npausas++; estado="trabajando" }
      ultimo=ts
    }
    END { print estado, inicio, marca, efectivo, npausas, ultimo }
  ' "$ACTUAL"
}

registrar() {
  local ts="$1" evento="$2" nota
  nota="$(sanear "${3:-}")"
  asegurar_dir
  printf '%s\t%s\t%s\t%s\n' "$ts" "$evento" "$(iso_de "$ts")" "$nota" >> "$ACTUAL"
}

# Ultimo latido registrado por el hook, 0 si no hay
ultimo_latido() {
  [[ -s "$ACTIVIDAD" ]] || { echo 0; return; }
  tail -n 1 "$ACTIVIDAD" | tr -dc '0-9'
  echo
}

# Interpreta --at HH:MM (o HH:MM:SS) como hora de hoy
epoch_de_hora() {
  local h="$1" ts
  ts="$(date -d "$h" +%s 2>/dev/null)" || morir "hora invalida: '$h' (usa HH:MM)"
  printf '%s\n' "$ts"
}

# ------------------------------------------------------------------ acciones

cmd_inicio() {
  local nota="${1:-}" ahora
  read -r estado inicio marca efectivo npausas ultimo <<<"$(calcular)"
  if [[ "$estado" != "libre" ]]; then
    printf 'Ya hay una sesion %s desde %s.\n' "$estado" "$(hora_de "$inicio")" >&2
    printf 'Cierrala con  ft  (o retomala con  rt  si esta pausada) antes de iniciar otra.\n' >&2
    exit 2
  fi
  ahora="$(date +%s)"
  registrar "$ahora" inicio "$nota"
  printf 'INICIO %s' "$(hora_de "$ahora")"
  [[ -n "$nota" ]] && printf '  |  %s' "$nota"
  printf '\n'
}

cmd_pausa() {
  local nota="${1:-}" ahora
  read -r estado inicio marca efectivo npausas ultimo <<<"$(calcular)"
  case "$estado" in
    libre)   morir "no hay sesion abierta. Inicia con  it" ;;
    pausado) morir "la sesion ya esta pausada desde $(hora_de "$ultimo"). Retoma con  rt" ;;
  esac
  ahora="$(date +%s)"
  registrar "$ahora" pausa "$nota"
  printf 'PAUSA  %s  |  efectivo acumulado %s\n' \
    "$(hora_de "$ahora")" "$(hhmmss $((efectivo + ahora - marca)))"
}

cmd_retomo() {
  local nota="${1:-}" ahora
  read -r estado inicio marca efectivo npausas ultimo <<<"$(calcular)"
  case "$estado" in
    libre)      morir "no hay sesion abierta. Inicia con  it" ;;
    trabajando) morir "la sesion no esta pausada; ya estas trabajando desde $(hora_de "$marca")" ;;
  esac
  ahora="$(date +%s)"
  registrar "$ahora" retomo "$nota"
  printf 'RETOMO %s  |  pausa de %s\n' "$(hora_de "$ahora")" "$(hhmmss $((ahora - ultimo)))"
}

cmd_fin() {
  local at="" nota="" fin
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --at) at="${2:-}"; shift 2 ;;
      *)    nota="${nota:+$nota }$1"; shift ;;
    esac
  done

  read -r estado inicio marca efectivo npausas ultimo <<<"$(calcular)"
  [[ "$estado" == "libre" ]] && morir "no hay sesion abierta que cerrar."

  if [[ -n "$at" ]]; then
    fin="$(epoch_de_hora "$at")"
    (( fin < ultimo )) && morir "la hora de cierre ($at) es anterior al ultimo evento ($(hora_de "$ultimo"))."
  else
    fin="$(date +%s)"
  fi

  [[ "$estado" == "trabajando" ]] && efectivo=$(( efectivo + fin - marca ))
  local bruto=$(( fin - inicio ))
  local pausas=$(( bruto - efectivo ))

  asegurar_dir
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$inicio" "$fin" "$bruto" "$pausas" "$efectivo" "$npausas" \
    "$(iso_de "$inicio")" "$(iso_de "$fin")" "$(sanear "$nota")" >> "$PENDIENTES"
  rm -f "$ACTUAL"

  printf 'FIN    %s\n' "$(hora_de "$fin")"
  printf '  inicio    %s\n' "$(hora_de "$inicio")"
  printf '  bruto     %s\n' "$(hhmmss "$bruto")"
  printf '  pausas    %s (%s)\n' "$(hhmmss "$pausas")" "$npausas"
  printf '  efectivo  %s\n' "$(hhmmss "$efectivo")"

  if (( bruto > TOPE_HORAS * 3600 )); then
    printf '\nAVISO: la sesion supero %sh de bruto. Si olvidaste  ft  revisa con  et  y corrige con  ft --at HH:MM\n' "$TOPE_HORAS"
  fi

  local n
  n="$(wc -l < "$PENDIENTES")"
  printf '\n%s sesion(es) pendiente(s) de pasar a bitacora.\n' "$n"
}

cmd_estado() {
  read -r estado inicio marca efectivo npausas ultimo <<<"$(calcular)"
  local ahora latido
  ahora="$(date +%s)"

  if [[ "$estado" == "libre" ]]; then
    printf 'Sin sesion abierta.\n'
  else
    local ef="$efectivo" bruto=$(( ahora - inicio ))
    [[ "$estado" == "trabajando" ]] && ef=$(( efectivo + ahora - marca ))
    printf 'Estado    %s\n' "$estado"
    printf 'Inicio    %s\n' "$(hora_de "$inicio")"
    printf 'Bruto     %s\n' "$(hhmmss "$bruto")"
    printf 'Pausas    %s (%s)\n' "$(hhmmss $((bruto - ef)))" "$npausas"
    printf 'Efectivo  %s\n' "$(hhmmss "$ef")"

    if (( bruto > TOPE_HORAS * 3600 )); then
      printf '\nAVISO: llevas mas de %sh abierta. ' "$TOPE_HORAS"
      latido="$(ultimo_latido)"
      if (( latido > 0 )); then
        printf 'Ultima actividad registrada: %s.\n' "$(hora_de "$latido")"
        printf 'Si olvidaste cerrar:  ft --at %s\n' "$(date -d "@$latido" +%H:%M)"
      else
        printf 'No hay latidos de actividad para reconciliar (hook no instalado).\n'
      fi
    fi
  fi

  if [[ -s "$PENDIENTES" ]]; then
    printf '\n%s sesion(es) cerrada(s) sin bitacora:\n' "$(wc -l < "$PENDIENTES")"
    awk -F'\t' '{ printf "  %s  efectivo %s  %s\n", substr($7,12,5), \
      sprintf("%02d:%02d:%02d", $5/3600, $5%3600/60, $5%60), $9 }' "$PENDIENTES"
  fi
}

# Bloque markdown para la bitacora. Sin --peek, vacia la bandeja.
cmd_consumir() {
  local peek=0
  [[ "${1:-}" == "--peek" ]] && peek=1
  [[ -s "$PENDIENTES" ]] || { printf 'No hay tiempos pendientes.\n'; return; }

  awk -F'\t' '
    BEGIN { n=0; bruto=0; pausas=0; efectivo=0; np=0 }
    {
      n++; bruto+=$3; pausas+=$4; efectivo+=$5; np+=$6
      if (n==1) ini=$7
      fin=$8
      det[n] = sprintf("- %s -> %s | efectivo %s%s", \
        substr($7,12,8), substr($8,12,8), \
        sprintf("%02d:%02d:%02d", $5/3600, $5%3600/60, $5%60), \
        ($9=="" ? "" : " | " $9))
    }
    END {
      printf "## Tiempo\n"
      if (n>1) printf "- sesiones: %d\n", n
      printf "- inicio: %s\n", ini
      printf "- fin: %s\n", fin
      printf "- pausas: %02d:%02d:%02d (%d)\n", pausas/3600, pausas%3600/60, pausas%60, np
      printf "- bruto: %02d:%02d:%02d\n", bruto/3600, bruto%3600/60, bruto%60
      printf "- efectivo: %02d:%02d:%02d\n", efectivo/3600, efectivo%3600/60, efectivo%60
      if (n>1) {
        printf "\n### Detalle de sesiones\n"
        for (i=1;i<=n;i++) print det[i]
      }
    }
  ' "$PENDIENTES"

  (( peek == 0 )) && rm -f "$PENDIENTES"
  return 0
}

# Total historico: bitacoras ya escritas + lo pendiente
cmd_reporte() {
  local dir_bit="$RAIZ/bitacoras"
  printf 'Proyecto: %s\n\n' "$RAIZ"

  local seg_bit=0 n_bit=0
  if compgen -G "$dir_bit/*.md" >/dev/null 2>&1; then
    read -r n_bit seg_bit <<<"$(
      grep -hE '^- efectivo: [0-9]{2,}:[0-9]{2}:[0-9]{2}$' "$dir_bit"/*.md 2>/dev/null \
      | awk '{ split($3,t,":"); s+=t[1]*3600+t[2]*60+t[3]; n++ } END { print n+0, s+0 }'
    )"
  fi
  printf '%-24s %3s   %s\n' 'Bitacoras con tiempo' "$n_bit" "$(hhmmss "$seg_bit")"

  local seg_pen=0 n_pen=0
  if [[ -s "$PENDIENTES" ]]; then
    read -r n_pen seg_pen <<<"$(awk -F'\t' '{ s+=$5; n++ } END { print n+0, s+0 }' "$PENDIENTES")"
  fi
  printf '%-24s %3s   %s\n' 'Pendientes sin bitacora' "$n_pen" "$(hhmmss "$seg_pen")"

  read -r estado inicio marca efectivo npausas ultimo <<<"$(calcular)"
  local seg_ab=0
  if [[ "$estado" != "libre" ]]; then
    seg_ab="$efectivo"
    [[ "$estado" == "trabajando" ]] && seg_ab=$(( efectivo + $(date +%s) - marca ))
    printf '%-24s %3s   %s\n' 'Sesion abierta' '' "$(hhmmss "$seg_ab")"
  fi

  printf '%s\n' '----------------------------------------'
  printf '%-24s %3s   %s\n' 'TOTAL EFECTIVO' '' "$(hhmmss $((seg_bit + seg_pen + seg_ab)))"
}

# Latido de actividad. Lo invoca el hook, debe ser trivial y rapido.
cmd_latido() {
  asegurar_dir
  date +%s >> "$ACTIVIDAD"
  # poda: el log de actividad no es historico, es una red de seguridad
  local n
  n="$(wc -l < "$ACTIVIDAD")"
  if (( n > MAX_LATIDOS )); then
    tail -n $(( MAX_LATIDOS / 2 )) "$ACTIVIDAD" > "$ACTIVIDAD.tmp" && mv "$ACTIVIDAD.tmp" "$ACTIVIDAD"
  fi
}

# Reconstruye la jornada a partir de los latidos cuando se olvidaron los comandos
cmd_reconciliar() {
  [[ -s "$ACTIVIDAD" ]] || morir "no hay latidos registrados. Instala el hook con:  tiempo.sh instalar"
  read -r estado inicio marca efectivo npausas ultimo <<<"$(calcular)"

  printf 'Reconstruccion desde actividad (hueco >= %s min = pausa)\n\n' "$UMBRAL_HUECO_MIN"
  awk -v umbral=$(( UMBRAL_HUECO_MIN * 60 )) -v desde="${inicio:-0}" '
    { ts=$1+0; if (ts < desde) next
      if (prev && ts-prev >= umbral) {
        printf "  hueco  %s -> %s  (%02d:%02d)\n", \
          strftime("%H:%M", prev), strftime("%H:%M", ts), (ts-prev)/3600, (ts-prev)%3600/60
        huecos += ts-prev
      }
      if (!primero) primero=ts
      prev=ts
    }
    END {
      if (!primero) { print "  sin actividad en el rango"; exit }
      printf "\n  primera actividad  %s\n", strftime("%H:%M:%S", primero)
      printf "  ultima  actividad  %s\n", strftime("%H:%M:%S", prev)
      printf "  huecos totales     %02d:%02d:%02d\n", huecos/3600, huecos%3600/60, huecos%60
      printf "  efectivo estimado  %02d:%02d:%02d\n", (prev-primero-huecos)/3600, \
        (prev-primero-huecos)%3600/60, (prev-primero-huecos)%60
    }
  ' "$ACTIVIDAD"

  if [[ "$estado" != "libre" ]]; then
    local latido; latido="$(ultimo_latido)"
    printf '\nPara cerrar con la ultima actividad real:  ft --at %s\n' "$(date -d "@$latido" +%H:%M)"
  fi
}

cmd_instalar() {
  local aqui; aqui="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  python3 "$aqui/instalar.py" "$RAIZ" "$aqui/.."
}

# --------------------------------------------------------------------- ayuda

uso() {
  cat <<'USO'
tiempo.sh <accion> [args]

  inicio [nota]        abre una sesion de trabajo
  pausa  [nota]        pausa la sesion abierta
  retomo [nota]        reanuda tras una pausa
  fin    [nota] [--at HH:MM]
                       cierra la sesion y la deja pendiente de bitacora
  estado               que hay abierto y cuanto llevas
  reporte              total del proyecto (bitacoras + pendientes + abierta)
  consumir [--peek]    imprime el bloque "## Tiempo" y vacia la bandeja
  reconciliar          reconstruye la jornada desde los latidos de actividad
  latido               registra actividad (lo llama el hook, no tu)
  instalar             instala comandos y hook en el proyecto actual

Variables: TIEMPO_PROYECTO TIEMPO_TOPE_HORAS TIEMPO_UMBRAL_HUECO_MIN
USO
}

case "${1:-}" in
  inicio|it)       shift; cmd_inicio "${1:-}" ;;
  pausa|pt)        shift; cmd_pausa "${1:-}" ;;
  retomo|rt)       shift; cmd_retomo "${1:-}" ;;
  fin|ft)          shift; cmd_fin "$@" ;;
  estado|et)       cmd_estado ;;
  reporte|tt)      cmd_reporte ;;
  consumir)        shift; cmd_consumir "${1:-}" ;;
  reconciliar)     cmd_reconciliar ;;
  latido)          cmd_latido ;;
  instalar)        cmd_instalar ;;
  ""|-h|--help)    uso ;;
  *)               morir "accion desconocida: $1" ;;
esac
