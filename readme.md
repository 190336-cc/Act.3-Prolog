# Sistema Experto de Asignación de Profesores — Facultad de Ciencias de la Información (UNACAR)

Sistema experto desarrollado en **SWI-Prolog** que resuelve el problema de asignar profesores a **academias**, **cuerpos académicos**, **proyectos**, **cursos a impartir** y **cursos de capacitación**, de acuerdo con su perfil de estudios, especialidad, acreditaciones y capacitación. También permite buscar un profesor y consultar todas sus asignaciones.

El sistema evalúa el perfil de cada profesor con un motor de puntuación (grado académico, acreditaciones vigentes, horas de capacitación, dominio de cursos y afinidad con la academia/línea/tema) y expone los resultados mediante una **API HTTP con 14 endpoints** en formato JSON. También permite registrar asignaciones compatibles mediante `POST` y conservarlas entre ejecuciones.

## Estructura del Proyecto

```
broken-cauldron/
├── baseconocimiento/
│   └── base_conocimiento.pl   # Hechos, relaciones y reglas del sistema experto
├── servidor/
│   └── servidor.pl            # Servidor web HTTP y manejadores de rutas
├── asignaciones.pl            # Validacion y persistencia de asignaciones
├── asignaciones_db.pl         # Archivo de datos generado al ejecutar el servidor
└── readme.md                  # Este archivo
```

## Instrucciones de Ejecución

1. Abre tu terminal (PowerShell, Git Bash o terminal de VS Code) y colócate en la carpeta `servidor`:

   ```bash
   cd broken-cauldron/servidor
   ```

2. Inicia SWI-Prolog cargando el archivo del servidor:

   ```bash
   swipl -s servidor.pl
   ```

   El servidor inicia automáticamente en el puerto `8080`; no es necesario
   ejecutar otro predicado para levantarlo.

3. Abre `http://localhost:8080/home` en el navegador para ver la página inicial,
   o consulta los endpoints desde el navegador o con `curl`.

Para detener el servidor desde la consola interactiva de Prolog:

```prolog
?- http_stop_server(8080, []).
?- halt.
```

La raíz `http://localhost:8080/` también muestra la página inicial.
Las asignaciones se guardan en `asignaciones_db.pl`, ubicado junto a `asignaciones.pl`.

---

## Endpoints

### Las 6 opciones del sistema experto

| # | Endpoint | Parámetros | Descripción |
|---|----------|------------|-------------|
| 1 | `/asignar_academia` | `academia` (obligatorio), `empleado` (opcional) | Ranking de profesores recomendados para una academia, o dictamen individual (`apto: true/false` con motivos). |
| 2 | `/asignar_cuerpo` | `cuerpo` (obligatorio), `empleado` (opcional) | Ranking de candidatos para cuerpos activos. **Requiere maestría o doctorado**; valora afinidad con la línea de investigación y acreditación SNI. |
| 3 | `/asignar_proyecto` | `proyecto` (obligatorio), `empleado` (opcional) | Ranking de candidatos para integrar un proyecto según afinidad temática y capacitación relacionada; el grado suma puntos, pero no es requisito mínimo. |
| 4 | `/mejor_profesor_curso` | `curso` (obligatorio) | Mejor profesor elegible para impartir un curso (debe dominarlo), más el listado de alternativos. |
| 5 | `/asignar_capacitacion` | `capacitacion` (obligatorio), `empleado` (opcional) | Ranking de profesores recomendados para una capacitación (utilidad para su especialidad y cursos que refuerza). |
| 6 | `/profesor` | `empleado` (obligatorio) | Perfil completo: estudios (licenciatura/maestría/doctorado), acreditaciones vigentes, capacitaciones, cursos que domina y **todas sus asignaciones** (academias, cuerpos, proyectos con rol, cursos y capacitaciones asignadas). |

### Endpoints de apoyo (listados)

| # | Endpoint | Descripción |
|---|----------|-------------|
| 7 | `/profesores` | Lista de profesores con acreditaciones vigentes, horas de capacitación y si tienen la carga completa. |
| 8 | `/academias` | Lista de academias con materias, líder y miembros. |
| 9 | `/cuerpos` | Lista de cuerpos académicos con línea de investigación, líder, estatus y miembros. |
| 10 | `/proyectos` | Lista de proyectos con objetivo, entregables, líder, integrantes, fechas y estado (por iniciar/vigente/concluido). |
| 11 | `/cursos` | Lista de cursos con créditos, objetivo, academia y cuántos profesores lo dominan. |
| 12 | `/capacitaciones` | Lista de capacitaciones con objetivo, horas, fechas y participantes. |

### Registro y consulta de asignaciones

| Método | Endpoint | Parámetros | Descripción |
|---|---|---|---|
| GET | `/api/asignaciones?empleado=1001` | `empleado` (obligatorio) | Consulta las asignaciones registradas y persistidas de un profesor. |
| POST | `/api/asignar` | JSON: `empleado`, `tipo`, `id_destino` (`tipo`: `academia`, `cuerpo`, `proyecto`, `curso` o `capacitacion`) | Registra una asignación si el profesor, destino y compatibilidad son válidos. |

Las rutas `/asignar_academia`, `/asignar_cuerpo`, `/asignar_proyecto`,
`/mejor_profesor_curso` y `/asignar_capacitacion` generan recomendaciones o
dictámenes; por sí mismas no registran cambios. El registro persistente se
realiza únicamente con `POST /api/asignar`. El perfil combina las relaciones
iniciales de la base de conocimiento con las asignaciones guardadas; el endpoint
`/api/asignaciones` consulta específicamente estas últimas.

## Ejemplos de Consulta

```bash
# 1. Ranking completo para la Academia de Programación
curl "http://localhost:8080/asignar_academia?academia=ac_prog"

# 1. Dictamen individual: ¿puede entrar Diego (1003) a la academia de Bases de Datos?
curl "http://localhost:8080/asignar_academia?academia=ac_bd&empleado=1003"

# 2. Candidatos al cuerpo académico de Inteligencia Artificial
curl "http://localhost:8080/asignar_cuerpo?cuerpo=ca_ia"

# 3. Candidatos para el proyecto de Modelo Predictivo
curl "http://localhost:8080/asignar_proyecto?proyecto=p2"

# 4. Mejor profesor para impartir Programación II
curl "http://localhost:8080/mejor_profesor_curso?curso=prog2"

# 5. Recomendados para la capacitación de Python para Ciencia de Datos
curl "http://localhost:8080/asignar_capacitacion?capacitacion=cap1"

# 6. Perfil completo y asignaciones del profesor 1001
curl "http://localhost:8080/profesor?empleado=1001"

# Listados de apoyo
curl "http://localhost:8080/profesores"
curl "http://localhost:8080/proyectos"
curl "http://localhost:8080/api/asignaciones?empleado=1003"
```

Ejemplo para registrar a un profesor en un curso que domina:

```bash
curl -X POST "http://localhost:8080/api/asignar" \
  -H "Content-Type: application/json" \
  -d "{\"empleado\":\"1003\",\"tipo\":\"curso\",\"id_destino\":\"prog2\"}"
```

La respuesta es `201 Created` si se registra. Se devuelve `409 Conflict` si la asignación ya existe, `400 Bad Request` si no cumple los criterios de compatibilidad y `404 Not Found` si el profesor o el destino no existen.

## Reglas de Puntuación (sistema experto)

**Puntaje base de todo profesor:**

| Concepto | Puntos |
|----------|--------|
| Grado académico (doctorado / maestría / licenciatura) | 30 / 20 / 10 |
| Cada acreditación vigente | +5 |
| Cada 10 horas de capacitación acumuladas | +2 |

**Ponderaciones por tipo de asignación:**

| Asignación | Factores principales |
|------------|---------------------|
| Academia | +8 por cada materia de la academia que domina · +25 si su especialidad pertenece a la academia |
| Cuerpo académico | Requiere maestría/doctorado · +30 especialidad = línea de investigación · +15 afín · +10 acreditación SNI vigente |
| Proyecto | +30 especialidad = tema del proyecto · +15 relacionada · +10 doctorado / +5 maestría · +10 capacitación relacionada; no exige posgrado |
| Curso a impartir | +30/+20/+10/+5 por posición 1/2/3/+ del curso en su lista de dominio · +10 miembro de la academia · +15/+10/+5 doctorado/maestría/licenciatura · +10 capacitación relacionada · −10 si ya tiene la carga completa |
| Capacitación | +30 si es útil para su especialidad · +8 por cada curso que refuerza y aún no domina bien · +5 si tiene 40 horas o más |

**Límites de carga (quien los alcanza se excluye de los rankings):** máximo **2 academias**, **2 cuerpos académicos** y **3 proyectos** simultáneos.

**Criterios de no elegibilidad:**
- Academia: el profesor debe dominar al menos una materia de la academia.
- Cuerpo académico: exige grado de **maestría o doctorado**.
- Cuerpo académico: solo se consideran cuerpos con estatus **activo**.
- Proyecto: no se puede postular a un proyecto donde ya es líder o integrante.
- Proyecto: no exige posgrado; el grado se considera en la puntuación.
- Curso a impartir: el profesor debe tener el curso en su lista de dominio.
- Capacitación: no se recomienda al profesor que ya la cursó.

> Estos son los criterios operativos de esta versión, incluidos los confirmados
> durante la adaptación. `Actividad-3.md` contiene datos del equipo, pero no la
> rúbrica académica; contrasta estas reglas con las instrucciones oficiales del
> profesor antes de presentarlas como requisitos de la actividad.

**Desempates:** a igual puntaje gana quien tenga mayor grado académico; si persiste el empate, el número de empleado mayor queda antes (orden determinista).

## Códigos de respuesta HTTP

| Código | Condición |
|--------|-----------|
| `400` | Faltan parámetros o una asignación no cumple la compatibilidad requerida. |
| `404` | Id de academia/cuerpo/proyecto/curso/capacitación o número de empleado inexistente. |
| `409` | La asignación ya existe. |
| `201` | La asignación se registró correctamente. |

Todas las respuestas (incluidos los errores) son JSON. Los empleados se identifican como texto entre comillas simples: `empleado=1001`.

## Datos de Incluidos (prueba)

| Entidad | Cantidad | Ejemplos |
|---------|----------|----------|
| Profesores | 7 | `1002` Dr. Carlos (doctorado, IA), `1003` Lic. Diego (licenciatura, programación), `1005` Dr. Fernando (doctorado, gestión TI) |
| Academias | 5 | `ac_prog`, `ac_bd`, `ac_redes`, `ac_ia`, `ac_gestion` |
| Cuerpos académicos | 4 | `ca_bd`, `ca_ia`, `ca_redes` (en formación), `ca_gest` |
| Proyectos | 3 | `p1` Evaluación docente, `p2` Modelo predictivo, `p3` Migración a la nube |
| Cursos | 8 | `bd1`, `bd2`, `prog1`, `prog2`, `edd`, `redes1`, `ia1`, `gestion_ti` |
| Capacitaciones | 3 | `cap1` Python (40 h), `cap2` CCNA (60 h), `cap3` Docencia (30 h) |

La vigencia de las acreditaciones se evalúa contra el **año en curso** del sistema.

## Tecnologías Utilizadas

- **SWI-Prolog** — motor lógico y servidor HTTP (`library(http/*)`)
- JSON con *dicts* modernos (`_{...}`)
- **Markdown** — documentación técnica del proyecto
