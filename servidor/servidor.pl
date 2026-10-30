:- encoding(utf8).

% =====================================================================
%  SERVIDOR HTTP - SISTEMA EXPERTO DE ASIGNACION DE PROFESORES
%  Facultad de Ciencias de la Informacion - UNACAR
%
%  Ejecucion:
%     swipl servidor.pl
%     ?- iniciar_servidor(8080).
%
%  12 endpoints:
%     1.  /asignar_academia      (ranking y dictamen para academias)
%     2.  /asignar_cuerpo        (ranking y dictamen para cuerpos academicos)
%     3.  /asignar_proyecto      (ranking y dictamen para proyectos)
%     4.  /mejor_profesor_curso  (mejor profesor para impartir un curso)
%     5.  /asignar_capacitacion  (ranking y dictamen para capacitaciones)
%     6.  /profesor              (perfil completo y asignaciones)
%     7.  /profesores            (listado de profesores)
%     8.  /academias             (listado de academias)
%     9.  /cuerpos               (listado de cuerpos academicos)
%     10. /proyectos             (listado de proyectos)
%     11. /cursos                (listado de cursos)
%     12. /capacitaciones        (listado de cursos de capacitacion)
% =====================================================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).

% Carga de la base de conocimiento (relativa a la carpeta del servidor)
:- consult('../baseconocimiento/base_conocimiento.pl').

% ---------------------------------------------------------------------
%  DECLARACION DE LOS 12 ENDPOINTS
% ---------------------------------------------------------------------
:- http_handler(root(asignar_academia),     h_asignar_academia,     []).   % 1
:- http_handler(root(asignar_cuerpo),       h_asignar_cuerpo,       []).   % 2
:- http_handler(root(asignar_proyecto),     h_asignar_proyecto,     []).   % 3
:- http_handler(root(mejor_profesor_curso), h_mejor_profesor_curso, []).   % 4
:- http_handler(root(asignar_capacitacion), h_asignar_capacitacion, []).   % 5
:- http_handler(root(profesor),             h_profesor,             []).   % 6
:- http_handler(root(profesores),           h_profesores,           []).   % 7
:- http_handler(root(academias),            h_academias,            []).   % 8
:- http_handler(root(cuerpos),              h_cuerpos,              []).   % 9
:- http_handler(root(proyectos),            h_proyectos,            []).   % 10
:- http_handler(root(cursos),               h_cursos,               []).   % 11
:- http_handler(root(capacitaciones),       h_capacitaciones,       []).   % 12

% Iniciar servidor
iniciar_servidor(Puerto) :-
    http_server(http_dispatch, [port(Puerto)]),
    format('Servidor activo en el puerto ~d (12 endpoints)~n', [Puerto]).

% ---------------------------------------------------------------------
%  HELPERS GENERALES
% ---------------------------------------------------------------------

% Lectura de parametros: falla si faltan (para responder 400 en JSON)
parametros(Request, Especificacion) :-
    catch(http_parameters(Request, Especificacion), _, fail).

responder_error(Mensaje, Status) :-
    reply_json(_{error: Mensaje}, [status(Status)]).

% Construye el JSON de un candidato de academia
candidato_academia_json(Emp, Aca, Dict) :-
    profesor(Emp, Nombre, Grado, Esp),
    puntaje_academia(Emp, Aca, Puntos, Motivos),
    Dict = _{empleado: Emp, nombre: Nombre, grado: Grado,
             especialidad: Esp, puntaje: Puntos, motivos: Motivos}.

% Construye el JSON de un candidato de cuerpo academico
candidato_cuerpo_json(Emp, Cuerpo, Dict) :-
    profesor(Emp, Nombre, Grado, Esp),
    puntaje_cuerpo(Emp, Cuerpo, Puntos, Motivos),
    Dict = _{empleado: Emp, nombre: Nombre, grado: Grado,
             especialidad: Esp, puntaje: Puntos, motivos: Motivos}.

% Construye el JSON de un candidato de proyecto
candidato_proyecto_json(Emp, Proy, Dict) :-
    profesor(Emp, Nombre, Grado, Esp),
    puntaje_proyecto(Emp, Proy, Puntos, Motivos),
    Dict = _{empleado: Emp, nombre: Nombre, grado: Grado,
             especialidad: Esp, puntaje: Puntos, motivos: Motivos}.

% Construye el JSON de un candidato para impartir un curso
candidato_curso_json(Emp, Curso, Dict) :-
    profesor(Emp, Nombre, Grado, Esp),
    puntaje_curso(Emp, Curso, Puntos, Motivos),
    Dict = _{empleado: Emp, nombre: Nombre, grado: Grado,
             especialidad: Esp, puntaje: Puntos, motivos: Motivos}.

% Construye el JSON de un candidato a una capacitacion
candidato_capacitacion_json(Emp, Cap, Dict) :-
    profesor(Emp, Nombre, Grado, Esp),
    puntaje_capacitacion(Emp, Cap, Puntos, Motivos),
    Dict = _{empleado: Emp, nombre: Nombre, grado: Grado,
             especialidad: Esp, puntaje: Puntos, motivos: Motivos}.

% =====================================================================
%  ENDPOINT 1: ASIGNAR PROFESORES A ACADEMIAS
%  /asignar_academia?academia=ac_prog
%  /asignar_academia?academia=ac_prog&empleado=1003
% =====================================================================
h_asignar_academia(Request) :-
    (   parametros(Request, [academia(Aca, [atom]),
                             empleado(OptEmp, [atom, optional(true)])])
    ->  (   academia(Aca, NombreAca, _, _)
        ->  responder_asignar_academia(Aca, NombreAca, OptEmp)
        ;   responder_error('Academia no existente', 404)
        )
    ;   responder_error('Faltan parametros: academia (obligatorio) y empleado (opcional)', 400)
    ).

responder_asignar_academia(Aca, NombreAca, OptEmp) :-
    (   var(OptEmp)
    ->  ranking_academia(Aca, Orden),
        findall(D, (member(cand(_, _, E), Orden),
                    candidato_academia_json(E, Aca, D)), Candidatos),
        length(Candidatos, Total),
        reply_json(_{academia: Aca, nombre: NombreAca, total_candidatos: Total,
                     criterio: 'Puntaje de mayor a menor (grado, acreditaciones, capacitaciones, materias dominadas y especialidad)',
                     candidatos: Candidatos})
    ;   \+ profesor(OptEmp, _, _, _)
    ->  responder_error('Profesor no existente', 404)
    ;   apto_academia(OptEmp, Aca)
    ->  puntaje_academia(OptEmp, Aca, Puntos, Motivos),
        reply_json(_{empleado: OptEmp, academia: Aca, apto: true,
                     puntaje: Puntos, motivos: Motivos})
    ;   responder_error('No apto: supera el limite de carga academica actual', 404)
    ).

% =====================================================================
%  ENDPOINT 2: ASIGNAR PROFESORES A CUERPOS ACADEMICOS
%  /asignar_cuerpo?cuerpo=ca_ia
%  /asignar_cuerpo?cuerpo=ca_ia&empleado=1007
% =====================================================================
h_asignar_cuerpo(Request) :-
    (   parametros(Request, [cuerpo(Cuerpo, [atom]),
                             empleado(OptEmp, [atom, optional(true)])])
    ->  (   cuerpo_academico(Cuerpo, NombreCuerpo, Linea, _, Estatus)
        ->  responder_asignar_cuerpo(Cuerpo, NombreCuerpo, Linea, Estatus, OptEmp)
        ;   responder_error('Cuerpo academico no existente', 404)
        )
    ;   responder_error('Faltan parametros: cuerpo (obligatorio) y empleado (opcional)', 400)
    ).

responder_asignar_cuerpo(Cuerpo, NombreCuerpo, Linea, Estatus, OptEmp) :-
    (   var(OptEmp)
    ->  ranking_cuerpo(Cuerpo, Orden),
        findall(D, (member(cand(_, _, E), Orden),
                    candidato_cuerpo_json(E, Cuerpo, D)), Candidatos),
        length(Candidatos, Total),
        reply_json(_{cuerpo: Cuerpo, nombre: NombreCuerpo, linea_investigacion: Linea,
                     estatus: Estatus, total_candidatos: Total,
                     requisito: 'Se requiere grado de maestria o doctorado',
                     criterio: 'Puntaje de mayor a menor (grado, acreditaciones, capacitaciones, afinitad con la linea y SNI)',
                     candidatos: Candidatos})
    ;   \+ profesor(OptEmp, _, _, _)
    ->  responder_error('Profesor no existente', 404)
    ;   apto_cuerpo(OptEmp, Cuerpo)
    ->  puntaje_cuerpo(OptEmp, Cuerpo, Puntos, Motivos),
        reply_json(_{empleado: OptEmp, cuerpo: Cuerpo, apto: true,
                     puntaje: Puntos, motivos: Motivos})
    ;   motivo_no_apto_cuerpo(OptEmp, Motivos),
        reply_json(_{empleado: OptEmp, cuerpo: Cuerpo, apto: false,
                     puntaje: 0, motivos: Motivos})
    ).

% =====================================================================
%  ENDPOINT 3: ASIGNAR PROFESORES A PROYECTOS
%  /asignar_proyecto?proyecto=p2
%  /asignar_proyecto?proyecto=p2&empleado=1003
% =====================================================================
h_asignar_proyecto(Request) :-
    (   parametros(Request, [proyecto(Proy, [atom]),
                             empleado(OptEmp, [atom, optional(true)])])
    ->  (   proyecto(Proy, NombreProy, Objetivo, Entregables, Lider, Integrantes, Inicio, Entrega)
        ->  responder_asignar_proyecto(Proy, NombreProy, Objetivo, Entregables,
                                       Lider, Integrantes, Inicio, Entrega, OptEmp)
        ;   responder_error('Proyecto no existente', 404)
        )
    ;   responder_error('Faltan parametros: proyecto (obligatorio) y empleado (opcional)', 400)
    ).

responder_asignar_proyecto(Proy, NombreProy, Objetivo, Entregables,
                           Lider, Integrantes, Inicio, Entrega, OptEmp) :-
    (   var(OptEmp)
    ->  ranking_proyecto(Proy, Orden),
        findall(D, (member(cand(_, _, E), Orden),
                    candidato_proyecto_json(E, Proy, D)), Candidatos),
        length(Candidatos, Total),
        reply_json(_{proyecto: Proy, nombre: NombreProy, objetivo: Objetivo,
                     entregables: Entregables, lider: Lider,
                     integrantes: Integrantes, fecha_inicio: Inicio,
                     fecha_entrega: Entrega, total_candidatos: Total,
                     criterio: 'Puntaje de mayor a menor (grado, acreditaciones, capacitaciones, especialidad afina al tema y grado de posgrado)',
                     candidatos: Candidatos})
    ;   \+ profesor(OptEmp, _, _, _)
    ->  responder_error('Profesor no existente', 404)
    ;   apto_proyecto(OptEmp, Proy)
    ->  puntaje_proyecto(OptEmp, Proy, Puntos, Motivos),
        reply_json(_{empleado: OptEmp, proyecto: Proy, apto: true,
                     puntaje: Puntos, motivos: Motivos})
    ;   motivo_no_apto_proyecto(OptEmp, Proy, Motivos),
        reply_json(_{empleado: OptEmp, proyecto: Proy, apto: false,
                     puntaje: 0, motivos: Motivos})
    ).

% =====================================================================
%  ENDPOINT 4: MEJOR PROFESOR PARA IMPARTIR UN CURSO
%  /mejor_profesor_curso?curso=prog2
% =====================================================================
h_mejor_profesor_curso(Request) :-
    (   parametros(Request, [curso(Curso, [atom])])
    ->  (   curso(Curso, Creditos, NombreCurso, Objetivo, Academia)
        ->  responder_mejor_profesor(Curso, Creditos, NombreCurso, Objetivo, Academia)
        ;   responder_error('Curso no existente', 404)
        )
    ;   responder_error('Falta el parametro curso', 400)
    ).

responder_mejor_profesor(Curso, Creditos, NombreCurso, Objetivo, Academia) :-
    ranking_curso(Curso, Orden),
    (   Orden = [cand(_, _, Mejor) | Resto]
    ->  candidato_curso_json(Mejor, Curso, DMejor),
        findall(D, (member(cand(_, _, E), Resto),
                    candidato_curso_json(E, Curso, D)), Alternativos),
        academia(Academia, NombreAcademia, _, _),
        length(Alternativos, TotalAlt),
        Total is TotalAlt + 1,
        reply_json(_{curso: Curso, nombre: NombreCurso, creditos: Creditos,
                     objetivo: Objetivo, academia: Academia,
                     nombre_academia: NombreAcademia,
                     total_candidatos: Total,
                     mejor_profesor: DMejor, alternativos: Alternativos})
    ;   responder_error('No hay candidatos disponibles para este curso', 404)
    ).

% =====================================================================
%  ENDPOINT 5: ASIGNAR PROFESORES A CURSOS DE CAPACITACION
%  /asignar_capacitacion?capacitacion=cap1
%  /asignar_capacitacion?capacitacion=cap1&empleado=1003
% =====================================================================
h_asignar_capacitacion(Request) :-
    (   parametros(Request, [capacitacion(Cap, [atom]),
                             empleado(OptEmp, [atom, optional(true)])])
    ->  (   capacitacion(Cap, NombreCap, ObjetivoCap, Horas, Inicio, Conclusion)
        ->  responder_asignar_capacitacion(Cap, NombreCap, ObjetivoCap, Horas,
                                           Inicio, Conclusion, OptEmp)
        ;   responder_error('Capacitacion no existente', 404)
        )
    ;   responder_error('Faltan parametros: capacitacion (obligatorio) y empleado (opcional)', 400)
    ).

responder_asignar_capacitacion(Cap, NombreCap, ObjetivoCap, Horas,
                               Inicio, Conclusion, OptEmp) :-
    (   var(OptEmp)
    ->  ranking_capacitacion(Cap, Orden),
        findall(D, (member(cand(_, _, E), Orden),
                    candidato_capacitacion_json(E, Cap, D)), Candidatos),
        length(Candidatos, Total),
        reply_json(_{capacitacion: Cap, nombre: NombreCap,
                     objetivo: ObjetivoCap, horas: Horas,
                     fecha_inicio: Inicio, fecha_conclusion: Conclusion,
                     total_candidatos: Total,
                     criterio: 'Puntaje de mayor a menor (grado, acreditaciones, capacitaciones previas, utilidad para su especialidad y cursos que refuerza)',
                     candidatos: Candidatos})
    ;   \+ profesor(OptEmp, _, _, _)
    ->  responder_error('Profesor no existente', 404)
    ;   apto_capacitacion(OptEmp, Cap)
    ->  puntaje_capacitacion(OptEmp, Cap, Puntos, Motivos),
        reply_json(_{empleado: OptEmp, capacitacion: Cap, apto: true,
                     puntaje: Puntos, motivos: Motivos})
    ;   responder_error('No apto: el profesor ya curso esta capacitacion', 404)
    ).

% =====================================================================
%  ENDPOINT 6: PERFIL DEL PROFESOR Y SUS ASIGNACIONES
%  /profesor?empleado=1001
% =====================================================================
h_profesor(Request) :-
    (   parametros(Request, [empleado(Emp, [atom])])
    ->  (   perfil_profesor(Emp, perfil(Nombre, Grado, Esp, Estudios, Acreditaciones,
                                        Capacitaciones, Dominios, Academias, Cuerpos,
                                        Proyectos, CursosImpartir))
        ->  responder_perfil(Emp, Nombre, Grado, Esp, Estudios, Acreditaciones,
                             Capacitaciones, Dominios, Academias, Cuerpos,
                             Proyectos, CursosImpartir)
        ;   responder_error('Profesor no existente', 404)
        )
    ;   responder_error('Falta el parametro empleado', 400)
    ).

responder_perfil(Emp, Nombre, Grado, Esp, Estudios, Acreditaciones,
                 Capacitaciones, Dominios, Academias, Cuerpos,
                 Proyectos, CursosImpartir) :-
    findall(_{tipo: Tipo, institucion: Institucion, anio: Anio},
            member(est(Tipo, Institucion, Anio), Estudios), JEstudios),
    findall(_{nombre: NomA, vigencia: VigA},
            member(acred(NomA, VigA), Acreditaciones), JAcreditaciones),
    findall(_{id: IdCap, nombre: NomCap},
            member(cap(IdCap, NomCap), Capacitaciones), JCapacitaciones),
    findall(_{curso: IdC, posicion: PosC},
            member(dom(IdC, PosC), Dominios), JCursosDomina),
    findall(_{id: IdAc, nombre: NomAc},
            (member(IdAc, Academias), academia(IdAc, NomAc, _, _)), JAcademias),
    findall(_{id: IdCu, nombre: NomCu, estatus: EstCu},
            (member(IdCu, Cuerpos), cuerpo_academico(IdCu, NomCu, _, _, EstCu)), JCuerpos),
    findall(_{id: IdP, nombre: NomP, rol: RolP, fecha_inicio: IniP, fecha_entrega: FinP},
            (member(IdP - rol(RolP), Proyectos),
             proyecto(IdP, NomP, _, _, _, _, IniP, FinP)), JProyectos),
    findall(_{id: IdM, nombre: NomM},
            (member(IdM, CursosImpartir), curso(IdM, _, NomM, _, _)), JCursosImpartir),
    reply_json(_{empleado: Emp, nombre: Nombre, grado: Grado, especialidad: Esp,
                 estudios: JEstudios,
                 acreditaciones_vigentes: JAcreditaciones,
                 capacitaciones_tomadas: JCapacitaciones,
                 cursos_que_domina: JCursosDomina,
                 asignaciones: _{academias: JAcademias,
                                 cuerpos_academicos: JCuerpos,
                                 proyectos: JProyectos,
                                 cursos_a_impartir: JCursosImpartir}}).

% =====================================================================
%  ENDPOINTS 7-12: LISTADOS DE APOYO
% =====================================================================

% 7. /profesores
h_profesores(_) :-
    findall(_{empleado: E, nombre: N, grado: G, especialidad: Esp,
              acreditaciones_vigentes: NA, horas_capacitacion: H,
              carga_completa: Carga},
            ( profesor(E, N, G, Esp),
              findall(_, acreditacion_vigente(E, _), Accs), length(Accs, NA),
              horas_capacitacion(E, H),
              (carga_completa(E) -> Carga = true ; Carga = false) ),
            Lista),
    length(Lista, Total),
    reply_json(_{total: Total, profesores: Lista}).

% 8. /academias
h_academias(_) :-
    findall(_{id: Id, nombre: Nom, materias: Materias, lider: Lider,
              total_miembros: N, miembros: Miembros},
            ( academia(Id, Nom, Materias, Lider),
              num_miembros_academia(Id, N),
              findall(E, miembro_academia(E, Id), Miembros) ),
            Lista),
    length(Lista, Total),
    reply_json(_{total: Total, academias: Lista}).

% 9. /cuerpos
h_cuerpos(_) :-
    findall(_{id: Id, nombre: Nom, linea_investigacion: Linea,
              lider: Lider, estatus: Estatus, total_miembros: N, miembros: Miembros},
            ( cuerpo_academico(Id, Nom, Linea, Lider, Estatus),
              num_miembros_cuerpo(Id, N),
              findall(E, miembro_cuerpo(E, Id), Miembros) ),
            Lista),
    length(Lista, Total),
    reply_json(_{total: Total, cuerpos_academicos: Lista}).

% 10. /proyectos
h_proyectos(_) :-
    findall(_{id: Id, nombre: Nom, objetivo: Objetivo, entregables: Entregables,
              lider: Lider, integrantes: Integrantes,
              fecha_inicio: Inicio, fecha_entrega: Entrega, estado: Estado},
            ( proyecto(Id, Nom, Objetivo, Entregables, Lider, Integrantes, Inicio, Entrega),
              estado_proyecto(Inicio, Entrega, Estado) ),
            Lista),
    length(Lista, Total),
    reply_json(_{total: Total, proyectos: Lista}).

% 11. /cursos
h_cursos(_) :-
    findall(_{id: Id, creditos: Creditos, nombre: Nom, objetivo: Objetivo,
              academia: Academia, total_profesores_que_lo_dominan: ND},
            ( curso(Id, Creditos, Nom, Objetivo, Academia),
              num_dominan_curso(Id, ND) ),
            Lista),
    length(Lista, Total),
    reply_json(_{total: Total, cursos: Lista}).

% 12. /capacitaciones
h_capacitaciones(_) :-
    findall(_{id: Id, nombre: Nom, objetivo: Objetivo, horas: Horas,
              fecha_inicio: Inicio, fecha_conclusion: Conclusion,
              total_participantes: NP},
            ( capacitacion(Id, Nom, Objetivo, Horas, Inicio, Conclusion),
              findall(E, capacitacion_tomada(E, Id, _), Ps), length(Ps, NP) ),
            Lista),
    length(Lista, Total),
    reply_json(_{total: Total, capacitaciones: Lista}).
