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




*//CONV

    DATA: l_string TYPE string,
          l_char   TYPE c LENGTH 12 VALUE 'abcdefghijkl'.

    l_string = CONV string( l_char ).
    out->write( l_string ).


    DATA: l_num TYPE n.

    l_num  = CONV string( l_char ).
    out->write( l_num ).
*    l_num  = conv int4( l_char ).
*    out->write( l_num ).


*//EXACT

    l_num  = EXACT string( l_char ).
    out->write( l_num ).


    DATA: gv_text  TYPE string,
          gv_class TYPE string VALUE 'Z'.

    gv_text = SWITCH #( gv_class
          WHEN 'Y' THEN 'tis Y'
          WHEN 'Z' THEN 'tis Z'
      ).
    out->write( gv_text ).


*//COND
   data: a,b,l_yes type abap_boolean.

*   if a > b.
*      l_yes = abap_true.
*   else.
*      l_yes = abap_false.
*   endif.

   l_yes = cond #(
        when a > b then abap_true
                   else abap_false
        ).



*//open sql new syntax
*//@ used to specify host parameters
*//sequence of select statement important (from, fields, where, into).  Helps auto complete in ADT

   data r_customers type range of /dmo/customer_id.

   select from /dmo/customer
   fields first_name, last_name
   where customer_id in @r_customers
      into table @data(lt_customers).




*/standard table
   data lt_flights_std type STANDARD TABLE OF /dmo/flight with NON-UNIQUE key carrier_id connection_id.
   data ls_flight_std like line of lt_flights_std.
   select from /dmo/flight
   fields *
   into table @lt_flights_std  .


   read table lt_flights_std into ls_flight_std with TABLE KEY
      carrier_id    =  'AA'
      connection_id = '0017'
      TRANSPORTING plane_type_id.











  ENDMETHOD.
ENDCLASS.
