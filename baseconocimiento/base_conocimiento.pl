:- encoding(utf8).

% =====================================================================
%  SISTEMA EXPERTO DE ASIGNACION DE PROFESORES
%  Facultad de Ciencias de la Informacion - UNACAR
%
%  Este archivo contiene:
%   1. HECHOS de las entidades (profesores, academias, cuerpos
%      academicos, proyectos, cursos y capacitaciones)
%   2. REGLAS del sistema experto (puntaje, elegibilidad y ranking
%      de candidatos para cada tipo de asignacion)
% =====================================================================

% ---------------------------------------------------------------------
%  1. PROFESORES
%  profesor(NumeroEmpleado, Nombre, GradoAcademico, Especialidad)
%  Grado: licenciatura | maestria | doctorado
% ---------------------------------------------------------------------
profesor('1001', 'Mtra. Ana Lopez Ruiz', maestria, bases_datos).
profesor('1002', 'Dr. Carlos Mendez Vera', doctorado, inteligencia_artificial).
profesor('1003', 'Lic. Diego Ramirez Soto', licenciatura, programacion).
profesor('1004', 'Mtra. Elena Flores Cruz', maestria, redes).
profesor('1005', 'Dr. Fernando Castro Uria', doctorado, gestion_ti).
profesor('1006', 'Lic. Gabriela Herrera Pan', licenciatura, programacion).
profesor('1007', 'Mtra. Hector Silva Mena', maestria, inteligencia_artificial).

% Lista de cursos que domina cada profesor, de MAYOR a MENOR dominio
% domina(NumeroEmpleado, IdCurso, Posicion)  (posicion 1 = mayor dominio)
domina('1001', bd1, 1).
domina('1001', bd2, 2).
domina('1001', edd, 3).
domina('1001', prog1, 4).
domina('1002', ia1, 1).
domina('1002', prog2, 2).
domina('1002', prog1, 3).
domina('1002', edd, 4).
domina('1003', prog1, 1).
domina('1003', prog2, 2).
domina('1003', edd, 3).
domina('1004', redes1, 1).
domina('1004', gestion_ti, 2).
domina('1005', gestion_ti, 1).
domina('1005', redes1, 2).
domina('1005', bd1, 3).
domina('1006', prog1, 1).
domina('1006', edd, 2).
domina('1007', ia1, 1).
domina('1007', edd, 2).
domina('1007', prog2, 3).
domina('1007', prog1, 4).

% Control de estudios (licenciatura, maestria y doctorado)
% estudio(NumeroEmpleado, Tipo, Institucion, Anio)
estudio('1001', licenciatura, 'UNACAR', 2010).
estudio('1001', maestria, 'UNAM', 2015).
estudio('1002', licenciatura, 'UNACAR', 2005).
estudio('1002', maestria, 'IPN', 2008).
estudio('1002', doctorado, 'UNAM', 2014).
estudio('1003', licenciatura, 'UNACAR', 2019).
estudio('1004', licenciatura, 'UNACAR', 2012).
estudio('1004', maestria, 'UDG', 2018).
estudio('1005', licenciatura, 'UNACAR', 2003).
estudio('1005', maestria, 'UNAM', 2007).
estudio('1005', doctorado, 'UNAM', 2013).
estudio('1006', licenciatura, 'UNACAR', 2021).
estudio('1007', licenciatura, 'UNACAR', 2014).
estudio('1007', maestria, 'UNAM', 2020).

% Acreditaciones del profesor
% acreditacion(NumeroEmpleado, Nombre, AnioDeVigencia)
acreditacion('1001', docencia, 2028).
acreditacion('1001', iso9001, 2025).
acreditacion('1002', sni, 2027).
acreditacion('1002', docencia, 2028).
acreditacion('1004', cisco_ccna, 2027).
acreditacion('1005', sni, 2028).
acreditacion('1005', iso9001, 2026).
acreditacion('1006', docencia, 2026).
acreditacion('1007', sni, 2027).

% Cursos de capacitacion tomados por el profesor
% capacitacion_tomada(NumeroEmpleado, IdCapacitacion, Anio)
capacitacion_tomada('1001', cap3, 2026).
capacitacion_tomada('1002', cap1, 2026).
capacitacion_tomada('1003', cap3, 2026).
capacitacion_tomada('1004', cap2, 2025).
capacitacion_tomada('1005', cap1, 2026).
capacitacion_tomada('1005', cap3, 2025).
capacitacion_tomada('1007', cap1, 2026).

% ---------------------------------------------------------------------
%  2. ACADEMIAS
%  academia(Id, Nombre, Materias, Lider)
% ---------------------------------------------------------------------
academia('ac_prog', 'Academia de Programacion', [prog1, prog2, edd], '1002').
academia('ac_bd', 'Academia de Bases de Datos', [bd1, bd2], '1001').
academia('ac_redes', 'Academia de Redes', [redes1], '1004').
academia('ac_ia', 'Academia de Inteligencia Artificial', [ia1], '1007').
academia('ac_gestion', 'Academia de Gestion de TI', [gestion_ti], '1005').

% Pertenencia actual a academias
% miembro_academia(NumeroEmpleado, IdAcademia)
miembro_academia('1001', ac_bd).
miembro_academia('1002', ac_prog).
miembro_academia('1003', ac_prog).
miembro_academia('1004', ac_redes).
miembro_academia('1005', ac_gestion).
miembro_academia('1007', ac_ia).

% ---------------------------------------------------------------------
%  3. CUERPOS ACADEMICOS
%  cuerpo_academico(Id, Nombre, LineaInvestigacion, Lider, Estatus)
% ---------------------------------------------------------------------
cuerpo_academico('ca_bd', 'CA en Bases de Datos y Analitica', analitica_datos, '1001', activo).
cuerpo_academico('ca_ia', 'CA en Inteligencia Artificial', inteligencia_artificial, '1002', activo).
cuerpo_academico('ca_redes', 'CA en Redes y Telecomunicaciones', redes_avanzadas, '1004', en_formacion).
cuerpo_academico('ca_gest', 'CA en Gestion de la Tecnologia', gestion_ti, '1005', activo).

% Pertenencia actual a cuerpos academicos
% miembro_cuerpo(NumeroEmpleado, IdCuerpo)
miembro_cuerpo('1001', ca_bd).
miembro_cuerpo('1002', ca_ia).
miembro_cuerpo('1004', ca_redes).
miembro_cuerpo('1005', ca_gest).
miembro_cuerpo('1007', ca_ia).

% ---------------------------------------------------------------------
%  4. PROYECTOS
%  proyecto(Id, Nombre, Objetivo, Entregables, Lider, Integrantes,
%           FechaInicio, FechaEntrega)
% ---------------------------------------------------------------------
proyecto('p1', 'Plataforma de Evaluacion Docente',
         'Sistema web para la evaluacion de docentes en linea',
         ['aplicacion web', 'manual de usuario', 'informe final'],
         '1005', ['1003', '1006'], '2026-08-01', '2026-12-20').
proyecto('p2', 'Modelo Predictivo de Reprobacion',
         'Modelos de aprendizaje automatico para detectar reprobacion',
         ['notebook de analisis', 'modelo entrenado', 'informe final'],
         '1002', ['1007'], '2026-09-15', '2027-02-28').
proyecto('p3', 'Migracion de Bases de Datos a la Nube',
         'Migracion de sistemas institucionales a infraestructura en la nube',
         ['esquema migrado', 'plan de pruebas', 'documentacion tecnica'],
         '1001', ['1004'], '2026-10-01', '2027-06-30').

% Tema principal de cada proyecto (se compara contra la especialidad)
tema_proyecto('p1', gestion_ti).
tema_proyecto('p2', inteligencia_artificial).
tema_proyecto('p3', bases_datos).

% Estado del proyecto segun su fecha (por_iniciar | vigente | concluido)
estado_proyecto(Inicio, Entrega, Estado) :-
    get_time(T),
    format_time(atom(Hoy), '%FT%T', T),
    (   compare(>, Inicio, Hoy) -> Estado = por_iniciar
    ;   compare(<, Entrega, Hoy) -> Estado = concluido
    ;   Estado = vigente
    ).

% ---------------------------------------------------------------------
%  5. CURSOS (materias a impartir)
%  curso(Id, Creditos, Nombre, Objetivo, Academia)
% ---------------------------------------------------------------------
curso('bd1', 8, 'Base de Datos I', 'Fundamentos de diseno de bases de datos relacionales', 'ac_bd').
curso('bd2', 8, 'Base de Datos II', 'Procedimientos almacenados y bases de datos NoSQL', 'ac_bd').
curso('prog1', 10, 'Programacion I', 'Logica y fundamentos de programacion', 'ac_prog').
curso('prog2', 10, 'Programacion II', 'Programacion orientada a objetos', 'ac_prog').
curso('edd', 6, 'Estructuras de Datos', 'Listas, arboles y tablas hash', 'ac_prog').
curso('redes1', 6, 'Redes de Computadoras', 'Modelo OSI y direccionamiento IP', 'ac_redes').
curso('ia1', 8, 'Inteligencia Artificial', 'Busqueda y sistemas expertos', 'ac_ia').
curso('gestion_ti', 6, 'Gestion de TI', 'Alineacion estrategica y gobierno de TI', 'ac_gestion').

% ---------------------------------------------------------------------
%  6. CURSOS DE CAPACITACION (catalogo)
%  capacitacion(Id, Nombre, Objetivo, Horas, Inicio, Conclusion)
% ---------------------------------------------------------------------
capacitacion('cap1', 'Python para Ciencia de Datos',
             'Manipulacion de datos y analitica con Python', 40, '2026-02-03', '2026-03-13').
capacitacion('cap2', 'Redes Cisco CCNA',
             'Routing y switching de nivel inicial', 60, '2025-09-01', '2025-12-15').
capacitacion('cap3', 'Docencia Universitaria',
             'Planificacion y evaluacion del aprendizaje', 30, '2026-05-04', '2026-05-30').

% =====================================================================
%  TABLAS DE AFINIDAD (usadas por las reglas de puntuacion)
% =====================================================================

% Capacitacion util para cada especialidad
capacitacion_relacionada(bases_datos, cap1).
capacitacion_relacionada(inteligencia_artificial, cap1).
capacitacion_relacionada(programacion, cap1).
capacitacion_relacionada(redes, cap2).
capacitacion_relacionada(gestion_ti, cap3).

% Cursos que cada capacitacion ayuda a reforzar
refuerza(cap1, [prog2, bd1, ia1]).
refuerza(cap2, [redes1]).
refuerza(cap3, []).

% Academia correspondiente a cada especialidad
especialidad_en_academia(bases_datos, ac_bd).
especialidad_en_academia(programacion, ac_prog).
especialidad_en_academia(redes, ac_redes).
especialidad_en_academia(inteligencia_artificial, ac_ia).
especialidad_en_academia(gestion_ti, ac_gestion).

% Especialidad afina a cada linea de investigacion
afin(bases_datos, analitica_datos).
afin(inteligencia_artificial, analitica_datos).
afin(programacion, inteligencia_artificial).
afin(redes, redes_avanzadas).
afin(gestion_ti, gestion_ti).

% Especialidades relacionadas entre si (simetrica via relacionada_sim/2)
relacionada(bases_datos, inteligencia_artificial).
relacionada(bases_datos, programacion).
relacionada(inteligencia_artificial, programacion).
relacionada(redes, gestion_ti).
relacionada(gestion_ti, bases_datos).

relacionada_sim(A, B) :- relacionada(A, B).
relacionada_sim(A, B) :- relacionada(B, A).

% =====================================================================
%  REGLAS GENERALES DEL SISTEMA EXPERTO
% =====================================================================

% Anio en curso (para evaluar vigencia de acreditaciones)
anio_actual(Anio) :-
    get_time(T),
    stamp_date_time(T, Datos, local),
    date_time_value(year, Datos, Anio).

% Una acreditacion esta vigente si su anio de vigencia no ha pasado
acreditacion_vigente(Empleado, Nombre) :-
    acreditacion(Empleado, Nombre, Vigencia),
    anio_actual(Anio),
    Vigencia >= Anio.

% Puntos que aporta cada grado academico (base de todos los puntajes)
puntaje_grado(licenciatura, 10).
puntaje_grado(maestria, 20).
puntaje_grado(doctorado, 30).

% Rango del grado (para desempates: doctorado > maestria > licenciatura)
grado_rango(licenciatura, 1).
grado_rango(maestria, 2).
grado_rango(doctorado, 3).

% Grado de posgrado minimo exigido a cuerpos academicos y proyectos
grado_posgrado(maestria).
grado_posgrado(doctorado).

% Total de horas de capacitacion acumuladas por el profesor
horas_capacitacion(Empleado, Horas) :-
    findall(H, (capacitacion_tomada(Empleado, Id, _), capacitacion(Id, _, _, H, _, _)), Lista),
    (   Lista == []
    ->  Horas = 0
    ;   sum_list(Lista, Horas)
    ).

% Puntaje base de un profesor: grado + acreditaciones vigentes + capacitacion
puntaje_base(Empleado, Puntos) :-
    profesor(Empleado, _, Grado, _),
    puntaje_grado(Grado, PG),
    findall(_, acreditacion_vigente(Empleado, _), Accs),
    length(Accs, NA),
    horas_capacitacion(Empleado, Horas),
    Puntos is PG + NA * 5 + (Horas // 10) * 2.

% Justificacion en texto del puntaje base (lista de motivos)
motivos_base(Empleado, Motivos) :-
    profesor(Empleado, _, Grado, _),
    puntaje_grado(Grado, PG),
    format(atom(MG), 'Grado academico: ~w (+~w)', [Grado, PG]),
    findall(N, acreditacion_vigente(Empleado, N), Accs),
    length(Accs, NA),
    PuntajeAcc is NA * 5,
    (   NA > 0
    ->  format(atom(MA), '~w acreditacion(es) vigente(s) (+~w)', [NA, PuntajeAcc])
    ;   MA = 'Sin acreditaciones vigentes (+0)'
    ),
    horas_capacitacion(Empleado, Horas),
    PuntajeCap is (Horas // 10) * 2,
    (   Horas > 0
    ->  format(atom(MC), '~w horas de capacitacion acumuladas (+~w)', [Horas, PuntajeCap])
    ;   MC = 'Sin capacitaciones previas (+0)'
    ),
    Motivos = [MG, MA, MC].

% ---------------------------------------------------------------------
%  CARGA ACADEMICA ACTUAL (limites por tipo de asignacion)
% ---------------------------------------------------------------------
limite_academias(2).
limite_cuerpos(2).
limite_proyectos(3).

num_academias(E, N)      :- findall(A, miembro_academia(E, A), L), length(L, N).
num_cuerpos(E, N)        :- findall(C, miembro_cuerpo(E, C), L), length(L, N).
num_proyectos(E, N)      :- findall(P, miembro_proyecto(E, P), L), length(L, N).

miembro_proyecto(E, P)   :- proyecto(P, _, _, _, E, _, _, _).
miembro_proyecto(E, P)   :- proyecto(P, _, _, _, _, Integrantes, _, _), member(E, Integrantes).

num_miembros_academia(A, N)    :- findall(E, miembro_academia(E, A), L), length(L, N).
num_miembros_cuerpo(C, N)      :- findall(E, miembro_cuerpo(E, C), L), length(L, N).
num_integrantes_proyecto(P, N) :- proyecto(P, _, _, _, _, Integrantes, _, _), length(Integrantes, N).
num_dominan_curso(C, N)        :- findall(E, domina(E, C, _), L), length(L, N).

% Un profesor tiene la carga completa si ya alcanzo algun limite
carga_completa(E) :-
    num_academias(E, NA), limite_academias(LA), NA >= LA.
carga_completa(E) :-
    num_cuerpos(E, NC), limite_cuerpos(LC), NC >= LC.
carga_completa(E) :-
    num_proyectos(E, NP), limite_proyectos(LP), NP >= LP.

% Clave de ordenamiento de candidatos (puntaje + desempate por grado)
clave_orden(Puntos, Empleado, Clave) :-
    profesor(Empleado, _, Grado, _),
    grado_rango(Grado, GR),
    Clave is Puntos * 10 + GR.

% Ordena pares cand(Clave, Puntos, Empleado) de mayor a menor puntaje
ordenar_candidatos(Pares, Orden) :-
    msort(Pares, Asc),
    reverse(Asc, Orden).

% =====================================================================
%  OPCION 1: ASIGNAR PROFESORES A ACADEMIAS
% =====================================================================

% Elegibilidad basica: existe el profesor y no tiene la carga completa
apto_academia(Empleado, Academia) :-
    academia(Academia, _, _, _),
    profesor(Empleado, _, _, _),
    \+ carga_completa(Empleado).

puntaje_academia(Empleado, Academia, Puntos, Motivos) :-
    academia(Academia, _, Materias, Lider),
    profesor(Empleado, _, _, Esp),
    puntaje_base(Empleado, PB),
    motivos_base(Empleado, MB),
    findall(M, (member(M, Materias), domina(Empleado, M, _)), Dominadas),
    length(Dominadas, ND),
    length(Materias, NM),
    PuntajeDom is ND * 8,
    (   ND > 0
    ->  format(atom(MD), 'Domina ~w de ~w materias de la academia (+~w)', [ND, NM, PuntajeDom])
    ;   MD = 'No domina ninguna materia de la academia (+0)'
    ),
    (   especialidad_en_academia(Esp, Academia)
    ->  PuntajeEsp = 25, ME = 'Su especialidad pertenece a la academia (+25)'
    ;   PuntajeEsp = 0, ME = 'Su especialidad no corresponde a la academia (+0)'
    ),
    Puntos is PB + PuntajeDom + PuntajeEsp,
    (   Lider == Empleado
    ->  append(MB, [MD, ME, 'Actualmente es el lider de esta academia'], Motivos)
    ;   append(MB, [MD, ME], Motivos)
    ).

ranking_academia(Academia, Ranking) :-
    findall(cand(Clave, P, E),
            ( profesor(E, _, _, _),
              apto_academia(E, Academia),
              puntaje_academia(E, Academia, P, _),
              clave_orden(P, E, Clave) ),
            Pares),
    ordenar_candidatos(Pares, Ranking).

% =====================================================================
%  OPCION 2: ASIGNAR PROFESORES A CUERPOS ACADEMICOS
% =====================================================================

% Elegibilidad: grado de posgrado (maestria o doctorado) y sin carga completa
apto_cuerpo(Empleado, Cuerpo) :-
    cuerpo_academico(Cuerpo, _, _, _, _),
    profesor(Empleado, _, Grado, _),
    grado_posgrado(Grado),
    \+ carga_completa(Empleado).

puntaje_cuerpo(Empleado, Cuerpo, Puntos, Motivos) :-
    cuerpo_academico(Cuerpo, _, Linea, Lider, _),
    profesor(Empleado, _, _, Esp),
    puntaje_base(Empleado, PB),
    motivos_base(Empleado, MB),
    (   Esp == Linea
    ->  PE = 30, ME = 'Su especialidad coincide con la linea de investigacion (+30)'
    ;   afin(Esp, Linea)
    ->  PE = 15, ME = 'Su especialidad es afina a la linea de investigacion (+15)'
    ;   PE = 0, ME = 'Sin relacion con la linea de investigacion (+0)'
    ),
    (   acreditacion_vigente(Empleado, sni)
    ->  PS = 10, MS = 'Acreditacion SNI vigente (+10)'
    ;   PS = 0, MS = 'Sin acreditacion de investigacion vigente (+0)'
    ),
    Puntos is PB + PE + PS,
    (   Lider == Empleado
    ->  append(MB, [ME, MS, 'Actualmente es el lider de este cuerpo academico'], Motivos)
    ;   append(MB, [ME, MS], Motivos)
    ).

ranking_cuerpo(Cuerpo, Ranking) :-
    findall(cand(Clave, P, E),
            ( profesor(E, _, _, _),
              apto_cuerpo(E, Cuerpo),
              puntaje_cuerpo(E, Cuerpo, P, _),
              clave_orden(P, E, Clave) ),
            Pares),
    ordenar_candidatos(Pares, Ranking).

% Motivo de no elegibilidad para un cuerpo academico
motivo_no_apto_cuerpo(Empleado, Motivos) :-
    profesor(Empleado, _, Grado, _),
    \+ grado_posgrado(Grado),
    !,
    format(atom(M), 'No apto: los cuerpos academicos exigen maestria o doctorado (grado actual: ~w)', [Grado]),
    Motivos = [M].
motivo_no_apto_cuerpo(_, ['No apto: supera el limite de carga academica actual']).

% =====================================================================
%  OPCION 3: ASIGNAR PROFESORES A PROYECTOS
% =====================================================================

% Elegibilidad: no forma ya parte del proyecto y sin carga completa
apto_proyecto(Empleado, Proyecto) :-
    proyecto(Proyecto, _, _, _, Lider, Integrantes, _, _),
    profesor(Empleado, _, _, _),
    Empleado \== Lider,
    \+ member(Empleado, Integrantes),
    \+ carga_completa(Empleado).

puntaje_proyecto(Empleado, Proyecto, Puntos, Motivos) :-
    tema_proyecto(Proyecto, Tema),
    profesor(Empleado, _, Grado, Esp),
    puntaje_base(Empleado, PB),
    motivos_base(Empleado, MB),
    (   Esp == Tema
    ->  PT = 30, MT = 'Su especialidad coincide con el tema del proyecto (+30)'
    ;   relacionada_sim(Esp, Tema)
    ->  PT = 15, MT = 'Su especialidad es relacionada con el tema del proyecto (+15)'
    ;   PT = 0, MT = 'Sin relacion con el tema del proyecto (+0)'
    ),
    (   grado_rango(Grado, GR), GR >= 3
    ->  PG = 10, MG = 'Grado de doctorado, aporta experiencia de investigacion (+10)'
    ;   grado_rango(Grado, GR2), GR2 =:= 2
    ->  PG = 5, MG = 'Grado de maestria (+5)'
    ;   PG = 0, MG = 'Grado de licenciatura (+0)'
    ),
    (   capacitacion_relacionada(Esp, Cap), capacitacion_tomada(Empleado, Cap, _)
    ->  PC = 10, format(atom(MC), 'Cuenta con capacitacion relacionada (~w) (+10)', [Cap])
    ;   PC = 0, MC = 'Sin capacitacion relacionada (+0)'
    ),
    Puntos is PB + PT + PG + PC,
    append(MB, [MT, MG, MC], Motivos).

ranking_proyecto(Proyecto, Ranking) :-
    findall(cand(Clave, P, E),
            ( profesor(E, _, _, _),
              apto_proyecto(E, Proyecto),
              puntaje_proyecto(E, Proyecto, P, _),
              clave_orden(P, E, Clave) ),
            Pares),
    ordenar_candidatos(Pares, Ranking).

% Motivo de no elegibilidad para un proyecto
motivo_no_apto_proyecto(Empleado, Proyecto, Motivos) :-
    (   \+ profesor(Empleado, _, _, _)
    ->  Motivos = ['No apto: profesor inexistente']
    ;   (   proyecto(Proyecto, _, _, _, Empleado, _, _, _)
        ->  Motivos = ['No apto: actualmente es el lider de este proyecto']
        ;   (   proyecto(Proyecto, _, _, _, _, Integrantes, _, _), member(Empleado, Integrantes)
            ->  Motivos = ['No apto: actualmente ya forma parte de este proyecto']
            ;   Motivos = ['No apto: supera el limite de carga academica actual']
            )
        )
    ).

% =====================================================================
%  OPCION 4: MEJOR PROFESOR PARA IMPARTIR UN CURSO
% =====================================================================

% Puntos por posicion en la lista de dominio del curso
puntos_posicion(Pos, Puntos) :-
    (   Pos =:= 1 -> Puntos = 30
    ;   Pos =:= 2 -> Puntos = 20
    ;   Pos =:= 3 -> Puntos = 10
    ;   Puntos = 5
    ).

% Puntos por grado academico al momento de impartir un curso
puntos_grado_impartir(licenciatura, 5).
puntos_grado_impartir(maestria, 10).
puntos_grado_impartir(doctorado, 15).

apto_curso(Empleado, Curso) :-
    curso(Curso, _, _, _, _),
    profesor(Empleado, _, _, _).

puntaje_curso(Empleado, Curso, Puntos, Motivos) :-
    curso(Curso, _, _, _, Academia),
    profesor(Empleado, _, Grado, Esp),
    puntaje_base(Empleado, PB),
    motivos_base(Empleado, MB),
    (   domina(Empleado, Curso, Pos)
    ->  puntos_posicion(Pos, PD),
        format(atom(MD), 'Tiene el curso en su lista de dominio (posicion ~w) (+~w)', [Pos, PD])
    ;   PD = 0, MD = 'No tiene el curso en su lista de dominio (+0)'
    ),
    (   miembro_academia(Empleado, Academia)
    ->  PA = 10, MA = 'Pertenece a la academia del curso (+10)'
    ;   PA = 0, MA = 'No pertenece a la academia del curso (+0)'
    ),
    puntos_grado_impartir(Grado, PG),
    format(atom(MG), 'Grado academico: ~w (+~w)', [Grado, PG]),
    (   capacitacion_relacionada(Esp, Cap), capacitacion_tomada(Empleado, Cap, _)
    ->  PC = 10, format(atom(MC), 'Capacitacion relacionada tomada (~w) (+10)', [Cap])
    ;   PC = 0, MC = 'Sin capacitacion relacionada (+0)'
    ),
    (   carga_completa(Empleado)
    ->  PDc = -10, MCarga = 'Carga academica completa, reducir su disponibilidad (-10)'
    ;   PDc = 0, MCarga = 'Disponibilidad suficiente (+0)'
    ),
    Puntos is PB + PD + PA + PG + PC + PDc,
    append(MB, [MD, MA, MG, MC, MCarga], Motivos).

ranking_curso(Curso, Ranking) :-
    findall(cand(Clave, P, E),
            ( profesor(E, _, _, _),
              apto_curso(E, Curso),
              puntaje_curso(E, Curso, P, _),
              clave_orden(P, E, Clave) ),
            Pares),
    ordenar_candidatos(Pares, Ranking).

% Mejor profesor para un curso (cabeza del ranking)
mejor_profesor_curso(Curso, Empleado, Puntos, Motivos) :-
    curso(Curso, _, _, _, _),
    ranking_curso(Curso, [cand(_, Puntos, Empleado) | _]),
    puntaje_curso(Empleado, Curso, Puntos, Motivos).

% =====================================================================
%  OPCION 5: ASIGNAR PROFESORES A CURSOS DE CAPACITACION
% =====================================================================

% Elegibilidad: el profesor aun no ha tomado la capacitacion
apto_capacitacion(Empleado, Capacitacion) :-
    capacitacion(Capacitacion, _, _, _, _, _),
    profesor(Empleado, _, _, _),
    \+ capacitacion_tomada(Empleado, Capacitacion, _).

% Domina "bien" un curso si este esta en las 2 primeras posiciones
domina_bien(E, C) :- domina(E, C, Pos), Pos =< 2.

puntaje_capacitacion(Empleado, Cap, Puntos, Motivos) :-
    capacitacion(Cap, _, _, Horas, _, _),
    profesor(Empleado, _, _, Esp),
    puntaje_base(Empleado, PB),
    motivos_base(Empleado, MB),
    (   capacitacion_relacionada(Esp, Cap)
    ->  PC = 30, MC = 'La capacitacion es directamente util para su especialidad (+30)'
    ;   PC = 0, MC = 'La capacitacion no esta vinculada con su especialidad (+0)'
    ),
    refuerza(Cap, CursosRef),
    findall(C, (member(C, CursosRef), \+ domina_bien(Empleado, C)), Necesita),
    length(Necesita, NN),
    PR is NN * 8,
    (   NN > 0
    ->  format(atom(MR), 'Refuerza ~w curso(s) que aun no domina bien (+~w)', [NN, PR])
    ;   MR = 'No refuerza cursos pendientes de su lista (+0)'
    ),
    (   Horas >= 40
    ->  PH = 5, format(atom(MH), 'Capacitacion extensa (~w horas) (+5)', [Horas])
    ;   PH = 0, format(atom(MH), 'Capacitacion breve (~w horas) (+0)', [Horas])
    ),
    Puntos is PB + PC + PR + PH,
    append(MB, [MC, MR, MH], Motivos).

ranking_capacitacion(Capacitacion, Ranking) :-
    findall(cand(Clave, P, E),
            ( profesor(E, _, _, _),
              apto_capacitacion(E, Capacitacion),
              puntaje_capacitacion(E, Capacitacion, P, _),
              clave_orden(P, E, Clave) ),
            Pares),
    ordenar_candidatos(Pares, Ranking).

% =====================================================================
%  OPCION 6: PERFIL DEL PROFESOR Y SUS ASIGNACIONES
% =====================================================================

% Rol del profesor dentro de un proyecto
rol_proyecto(E, P, lider)     :- proyecto(P, _, _, _, E, _, _, _).
rol_proyecto(E, P, integrante) :- proyecto(P, _, _, _, _, Integrantes, _, _), member(E, Integrantes).

% Reporte integral del profesor
perfil_profesor(Empleado, Perfil) :-
    profesor(Empleado, Nombre, Grado, Esp),
    findall(est(Tipo, Institucion, Anio),
            estudio(Empleado, Tipo, Institucion, Anio), Estudios),
    findall(acred(NomA, Vig),
            (acreditacion(Empleado, NomA, Vig), acreditacion_vigente(Empleado, NomA)),
            Acreditaciones),
    findall(cap(IdCap, NomCap),
            (capacitacion_tomada(Empleado, IdCap, _),
             capacitacion(IdCap, NomCap, _, _, _, _)),
            Capacitaciones),
    findall(dom(IdC, Pos), domina(Empleado, IdC, Pos), Dominios0),
    msort(Dominios0, Dominios),
    findall(A, miembro_academia(Empleado, A), Academias),
    findall(C, miembro_cuerpo(Empleado, C), Cuerpos),
    findall(P - rol(Rol), rol_proyecto(Empleado, P, Rol), Proyectos),
    findall(C, (miembro_academia(Empleado, A),
                academia(A, _, Materias, _),
                member(C, Materias)),
            Cursos0),
    sort(Cursos0, CursosImpartir),
    Perfil = perfil(Nombre, Grado, Esp, Estudios, Acreditaciones,
                    Capacitaciones, Dominios, Academias, Cuerpos,
                    Proyectos, CursosImpartir).
