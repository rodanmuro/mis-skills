#!/usr/bin/env python3
"""Instala los comandos y el hook de latido de tiempo-trabajo en un proyecto.

Uso: instalar.py <raiz_proyecto> <dir_skill>

Idempotente: se puede correr varias veces sin duplicar nada.
"""
import json
import os
import shutil
import sys

# El comando instalado lleva comillas en medio (tiempo.sh" latido), asi que la
# deteccion busca las dos piezas por separado en vez de la frase completa.
MARCAS = ("tiempo.sh", "latido")


def ruta_script(raiz, dir_skill):
    """Ruta al script para el hook: relativa al proyecto si vive dentro de el."""
    script = os.path.join(dir_skill, "scripts", "tiempo.sh")
    script = os.path.realpath(script)
    raiz_real = os.path.realpath(raiz)
    if script.startswith(raiz_real + os.sep):
        rel = os.path.relpath(script, raiz_real)
        return '"$CLAUDE_PROJECT_DIR/%s"' % rel
    return '"%s"' % script


def instalar_comandos(raiz, dir_skill):
    origen = os.path.join(dir_skill, "assets", "commands")
    destino = os.path.join(raiz, ".claude", "commands")
    if not os.path.isdir(origen):
        return []
    os.makedirs(destino, exist_ok=True)
    puestos = []
    for nombre in sorted(os.listdir(origen)):
        if not nombre.endswith(".md"):
            continue
        shutil.copy2(os.path.join(origen, nombre), os.path.join(destino, nombre))
        puestos.append("/" + nombre[:-3])
    return puestos


def instalar_hook(raiz, dir_skill):
    ruta = os.path.join(raiz, ".claude", "settings.json")
    os.makedirs(os.path.dirname(ruta), exist_ok=True)

    datos = {}
    if os.path.exists(ruta):
        with open(ruta, encoding="utf-8") as fh:
            texto = fh.read().strip()
        if texto:
            try:
                datos = json.loads(texto)
            except json.JSONDecodeError as err:
                sys.exit(
                    "ERROR: %s tiene JSON invalido (%s).\n"
                    "Corrigelo antes de instalar: un settings.json roto "
                    "desactiva TODA la configuracion de ese archivo." % (ruta, err)
                )

    hooks = datos.setdefault("hooks", {})
    eventos = hooks.setdefault("UserPromptSubmit", [])

    for grupo in eventos:
        for h in grupo.get("hooks", []):
            cmd = str(h.get("command", ""))
            if all(m in cmd for m in MARCAS):
                return ruta, False  # ya estaba

    eventos.append({
        "hooks": [{
            "type": "command",
            "command": "bash %s latido" % ruta_script(raiz, dir_skill),
            "async": True,
            "timeout": 5,
        }]
    })

    with open(ruta, "w", encoding="utf-8") as fh:
        json.dump(datos, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    return ruta, True


def preparar_datos(raiz):
    dir_t = os.path.join(raiz, "bitacoras", "tiempos")
    os.makedirs(dir_t, exist_ok=True)
    # Los archivos de tiempos son transitorios: el registro permanente
    # vive en el bloque "## Tiempo" de cada bitacora.
    gi = os.path.join(dir_t, ".gitignore")
    if not os.path.exists(gi):
        with open(gi, "w", encoding="utf-8") as fh:
            fh.write("*.tsv\n*.log\n")
    return dir_t


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    raiz, dir_skill = os.path.realpath(sys.argv[1]), os.path.realpath(sys.argv[2])

    dir_t = preparar_datos(raiz)
    comandos = instalar_comandos(raiz, dir_skill)
    ruta_cfg, nuevo = instalar_hook(raiz, dir_skill)

    print("Proyecto:  %s" % raiz)
    print("Datos:     %s" % dir_t)
    print("Comandos:  %s" % (" ".join(comandos) if comandos else "(ninguno)"))
    print("Hook:      %s%s" % (ruta_cfg, "" if nuevo else "  (ya estaba)"))
    if nuevo:
        print("\nAbre /hooks una vez (o reinicia Claude Code) para que el hook cargue.")


if __name__ == "__main__":
    main()
