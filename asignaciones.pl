% =====================================================
% REGISTRO PERSISTENTE DE ASIGNACIONES
% =====================================================

:- use_module(library(persistency)).

:- persistent
    asignacion_guardada(
        empleado:atom,
        tipo:atom,
        id_destino:atom
    ).

archivo_asignaciones(Ruta) :-
    source_file(iniciar_asignaciones, Archivo),
    file_directory_name(Archivo, Directorio),
    absolute_file_name(
        'asignaciones_db.pl',
        Ruta,
        [relative_to(Directorio), access(none)]
    ).

iniciar_asignaciones :-
    archivo_asignaciones(Ruta),
    db_attach(Ruta, []).

profesor_existe(Empleado) :-
    profesor(Empleado, _, _, _).

destino_existe(academia, Id) :-
    academia(Id, _, _, _).
destino_existe(cuerpo, Id) :-
    cuerpo_academico(Id, _, _, _, _).
destino_existe(proyecto, Id) :-
    proyecto(Id, _, _, _, _, _, _, _).
destino_existe(curso, Id) :-
    curso(Id, _, _, _, _).
destino_existe(capacitacion, Id) :-
    capacitacion(Id, _, _, _, _, _).

compatible(Empleado, academia, Id) :-
    apto_academia(Empleado, Id).
compatible(Empleado, cuerpo, Id) :-
    apto_cuerpo(Empleado, Id).
compatible(Empleado, proyecto, Id) :-
    apto_proyecto(Empleado, Id).
compatible(Empleado, curso, Id) :-
    apto_curso(Empleado, Id).
compatible(Empleado, capacitacion, Id) :-
    apto_capacitacion(Empleado, Id).

asignacion_existente(Empleado, academia, Id) :-
    miembro_academia(Empleado, Id).
asignacion_existente(Empleado, academia, Id) :-
    asignacion_guardada(Empleado, academia, Id).
asignacion_existente(Empleado, cuerpo, Id) :-
    miembro_cuerpo(Empleado, Id).
asignacion_existente(Empleado, cuerpo, Id) :-
    asignacion_guardada(Empleado, cuerpo, Id).
asignacion_existente(Empleado, proyecto, Id) :-
    miembro_proyecto(Empleado, Id).
asignacion_existente(Empleado, Tipo, Id) :-
    member(Tipo, [curso, capacitacion]),
    asignacion_guardada(Empleado, Tipo, Id).

registrar_asignacion(Empleado, Tipo, Id) :-
    with_mutex(
        registro_asignaciones,
        registrar_asignacion_validada(Empleado, Tipo, Id)
    ).

registrar_asignacion_validada(Empleado, Tipo, Id) :-
    profesor_existe(Empleado),
    destino_existe(Tipo, Id),
    compatible(Empleado, Tipo, Id),
    \+ asignacion_existente(Empleado, Tipo, Id),
    assert_asignacion_guardada(Empleado, Tipo, Id).

asignaciones_profesor(Empleado, Tipo, Id) :-
    asignacion_guardada(Empleado, Tipo, Id).
