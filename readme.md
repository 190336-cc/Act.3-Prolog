# Sistema Experto de Asignación de Profesores — Facultad de Ciencias de la Información (UNACAR)

Sistema experto desarrollado en **SWI-Prolog** que resuelve el problema de asignar profesores a **academias**, **cuerpos académicos**, **proyectos**, **cursos a impartir** y **cursos de capacitación**, de acuerdo con su perfil de estudios, especialidad, acreditaciones y capacitación. También permite buscar un profesor y consultar todas sus asignaciones.

El sistema evalúa el perfil de cada profesor con un motor de puntuación (grado académico, acreditaciones vigentes, horas de capacitación, dominio de cursos, afinitad con la academia/línea/tema) y expone los resultados mediante una **API HTTP con 12 endpoints** en formato JSON.

## Estructura del Proyecto

```
asignacion_profesores_unacar/
├── baseconocimiento/
│   └── base_conocimiento.pl   # Hechos de las 6 entidades + reglas del sistema experto
├── servidor/
│   └── servidor.pl            # Servidor web HTTP y los 12 manejadores de rutas
└── readme.md                  # Este archivo
```

## Instrucciones de Ejecución

1. Abre tu terminal (Git Bash o terminal de VS Code) y colócate en la carpeta del servidor:

   ```bash
   cd asignacion_profesores_unacar/servidor
   ```

2. Inicia SWI-Prolog cargando el archivo del servidor:

   ```bash
   swipl -s servidor.pl
   ```

   El servidor inicia automaticamente en el puerto `8080`; no es necesario
   ejecutar otro predicado para levantarlo.

3. Abre `http://localhost:8080/home` en el navegador para ver la pagina inicial,
   o consulta los endpoints desde el navegador o con `curl`.

Para detener el servidor desde la consola interactiva de Prolog:

```prolog
?- http_stop_server(8080, []).
?- halt.
```

La raiz `http://localhost:8080/` tambien muestra la pagina inicial.

---

## Endpoints

### Las 6 opciones del sistema experto

| # | Endpoint | Parámetros | Descripción |
|---|----------|------------|-------------|
| 1 | `/asignar_academia` | `academia` (obligatorio), `empleado` (opcional) | Ranking de profesores recomendados para una academia, o dictamen individual (`apto: true/false` con motivos). |
| 2 | `/asignar_cuerpo` | `cuerpo` (obligatorio), `empleado` (opcional) | Ranking de candidatos a un cuerpo académico. **Requiere maestría o doctorado**; valora afinitad con la línea de investigación y acreditación SNI. |
| 3 | `/asignar_proyecto` | `proyecto` (obligatorio), `empleado` (opcional) | Ranking de candidatos para integrar un proyecto, según especialidad afín al tema, grado de posgrado y capacitación relacionada. |
| 4 | `/mejor_profesor_curso` | `curso` (obligatorio) | Mejor profesor para impartir un curso (dominio del curso, academia, grado y capacitación), más el listado de alternativos. |
| 5 | `/asignar_capacitacion` | `capacitacion` (obligatorio), `empleado` (opcional) | Ranking de profesores recomendados para una capacitación (utilidad para su especialidad y cursos que refuerza). |
| 6 | `/profesor` | `empleado` (obligatorio) | Perfil completo: estudios (licenciatura/maestría/doctorado), acreditaciones vigentes, capacitaciones, cursos que domina y **todas sus asignaciones** (academias, cuerpos, proyectos con rol, cursos a impartir). |

### Endpoints de apoyo (listados)

| # | Endpoint | Descripción |
|---|----------|-------------|
| 7 | `/profesores` | Lista de profesores con acreditaciones vigentes, horas de capacitación y si tienen la carga completa. |
| 8 | `/academias` | Lista de academias con materias, líder y miembros. |
| 9 | `/cuerpos` | Lista de cuerpos académicos con línea de investigación, líder, estatus y miembros. |
| 10 | `/proyectos` | Lista de proyectos con objetivo, entregables, líder, integrantes, fechas y estado (por iniciar/vigente/concluido). |
| 11 | `/cursos` | Lista de cursos con créditos, objetivo, academia y cuántos profesores lo dominan. |
| 12 | `/capacitaciones` | Lista de capacitaciones con objetivo, horas, fechas y participantes. |

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
```

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
| Proyecto | +30 especialidad = tema del proyecto · +15 relacionada · +10 doctorado / +5 maestría · +10 capacitación relacionada |
| Curso a impartir | +30/+20/+10/+5 por posición 1/2/3/+ del curso en su lista de dominio · +10 miembro de la academia · +15/+10/+5 doctorado/maestría/licenciatura · +10 capacitación relacionada · −10 si ya tiene la carga completa |
| Capacitación | +30 si es útil para su especialidad · +8 por cada curso que refuerza y aún no domina bien · +5 si tiene 40 horas o más |

**Límites de carga (quien los alcanza se excluye de los rankings):** máximo **2 academias**, **2 cuerpos académicos** y **3 proyectos** simultáneos.

**Criterios de no elegibilidad:**
- Cuerpo académico: exige grado de **maestría o doctorado**.
- Proyecto: no se puede postular a un proyecto donde ya es líder o integrante.
- Capacitación: no se recomienda al profesor que ya la cursó.

**Desempates:** a igual puntaje gana quien tenga mayor grado académico; si persiste el empate, el número de empleado mayor queda antes (orden determinista).

## Manejo de Errores

| Código | Condición |
|--------|-----------|
| `400` | Faltan parámetros obligatorios (respuesta JSON con `error`). |
| `404` | Id de academia/cuerpo/proyecto/curso/capacitación o número de empleado inexistente; profesor ya capacitado; profesor con carga completa. |

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
