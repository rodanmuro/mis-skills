# Contexto inicial
El agente LLM debera leer el presente archivo al iniciar una nueva sesion, pues son las ideas generales de trabajo.
Luego de leer el presente archivo, debera leer `planeacion/descripcion_fundacional_proyecto.md` para comprender de que trata este proyecto y su objetivo principal; el archivo `planeacion/descripcion_fundacional_proyecto.md` describe concretamente el software o app a desarrollar y la solucion que se quiere obtener.
Luego debera leer `bitacoras/bitacora-template.md`, un archivo que le dara las ideas generales de como crear bitacoras cada vez que se cumplan una serie de pasos dentro del desarrollo del proyecto.

# Flujo previo a codificar
El agente LLM siempre debera presentar un plan de accion; un conjunto de pasos de como piensa resolver el problema que el cliente le pide resolver, con el fin de aprobar el flujo de trabajo.

# Al codificar en general
El agente LLM siempre debe pensar en buenas practicas SOLID, modulares y testeables.
El agente LLM siempre debe pensar en descomponer tareas para cumplir el principio de Single Responsibility.
El agente LLM siempre debe pensar en software escalable, anticipando errores que se pueden presentar.
El agente LLM siempre debe preguntar al usuario si desea que escriba tests automáticos del código, luego de haber desarrollado un conjunto de funcionalidades.
El agente LLM no realizará tests end-to-end a menos que el usuario se lo solicite.

# Al codificar en el frontend
El agente LLM siempre deberá trabajar usando principios SOLID creando código modular, escalable, mantenible y testeable, no importa el framework o librería que esté usando (React-Vite, Angular, Svelte o similares).
El agente LLM siempre deberá trabajar por componentes, no importa el framework o librería que esté usando (React-Vite, Angular, Svelte o similares).
El agente LLM siempre deberá crear componentes testeables, no importa el framework o librería que esté usando (React-Vite, Angular, Svelte o similares).
El agente LLM siempre deberá crear servicios testeables, no importa el framework o librería que esté usando (React-Vite, Angular, Svelte o similares).

# Al codificar en el backend
El agente LLM siempre deberá trabajar usando principios SOLID creando código modular, escalable, mantenible y testeable, no importa el framework, lenguaje o librería que esté usando (Django, FastAPI, Spring Boot, Laravel o similares).
El agente LLM siempre deberá crear funciones testeables, no importa el framework o librería que esté usando no importa el framework, lenguaje o librería que esté usando (Django, FastAPI, Spring Boot, Laravel o similares).
El agente LLM siempre deberá crear servicios testeables, no importa el framework, lenguaje o librería que esté usando (Django, FastAPI, Spring Boot, Laravel o similares).


# Metodologia de bitacoras
Cuando el usuario lo solicite, o mediante el uso de un skill,  se deben crear bitacoras siguiendo el formato en `bitacoras/bitacora-template.md`. Los archivos de bitacora se almacenan en `bitacoras/` con nombre `XXX_MM_DD_AAAA_descripcion_corta.md`, donde:

- `XXX` es el consecutivo numerico que sigue al ultimo registro (`000`, `001`, `002`, etc.).
- `MM_DD_AAAA` representa la fecha actual del sistema (mes, dia y anio) al registrar la bitacora.
- `descripcion_corta` es una frase de maximo cinco palabras que resume lo registrado.

El contenido de cada bitacora debera mencionar logros recientes, detalles de implementacion sin escribir codigo completo (solo ideas relevantes), decisiones clave, archivos modificados o creados y proximos pasos. Siempre deben quedar documentados:

- **Que fue lo que se hizo** (con detalles de implementacion, sin copiar codigo completo).
- **Para que se hizo**.
- **Que problemas se presentaron** (cuando aplique).
- **Como se resolvieron**.
- **Que continua**.

De este modo se mantiene un historial ordenado y facil de revisar.
Puedes revisar las ultimas bitacoras en `bitacoras/` para entender en que va el proceso.
