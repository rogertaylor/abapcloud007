CLASS zcl_hello_world_rt007 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_hello_world_rt007 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    out->write( |hello world! ({ cl_abap_context_info=>get_user_alias( ) })| ).
  ENDMETHOD.

ENDCLASS.
