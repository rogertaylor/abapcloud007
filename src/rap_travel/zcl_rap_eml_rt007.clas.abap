CLASS zcl_rap_eml_rt007 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_RAP_EML_RT007 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    "step 1 - read
*    read ENTITIES of ZI_RAP_Travel_RT007
*    ENTITY Travel
*       from value #( ( TravelUUID = '45930900999EA35017000A021B0B44A2' ) )
*    result data(travels).
*    out->write( travels ).


    "step 2 - read with fields
*    read ENTITIES of ZI_RAP_Travel_RT007
*    ENTITY Travel
*       fields ( AgencyID CustomerID )
*       with value #( ( TravelUUID = '45930900999EA35017000A021B0B44A2' ) )
*    result data(travels).
*    out->write( travels ).


    "step 3 - read with ALL fields
*    read ENTITIES of ZI_RAP_Travel_RT007
*    ENTITY Travel
*       all fields
*       with value #( ( TravelUUID = '45930900999EA35017000A021B0B44A2' ) )
*    result data(travels).
*    out->write( travels ).


    "step 4 - read by association
*    read ENTITIES of ZI_RAP_Travel_RT007
*    ENTITY Travel by \_Booking
*       all fields
*       with value #( ( TravelUUID = '45930900999EA35017000A021B0B44A2' ) )
*    result data(bookings).
*    out->write( bookings ).

    "step 5 - unsuccessful read
*    READ ENTITIES OF ZI_RAP_Travel_RT007
*    ENTITY Travel
*       ALL FIELDS
*       WITH VALUE #( ( TravelUUID = '11111111' ) )
*    RESULT DATA(travels)
*    FAILED DATA(failed)
*    REPORTED DATA(reported).
*
*    out->write( travels ).
*    out->write( failed ).
*    out->write( reported ).


    "step 6 - modify update
*    MODIFY ENTITIES OF ZI_RAP_Travel_RT007
*     ENTITY Travel
*        UPDATE
*            SET FIELDS WITH VALUE
*                #( ( TravelUUID = '45930900999EA35017000A021B0B44A2'
*                     Description = 'I like RAP'
*                 ) )
*    FAILED DATA(failed)
*    REPORTED DATA(reported).
*
*    out->write( 'update done' ).
*
*    COMMIT ENTITIES
*        RESPONSE OF ZI_RAP_Travel_RT007
*        FAILED DATA(failed_commit)
*        REPORTED DATA(reported_commit).


    "step 7 - modify create
*    modify ENTITIES of zi_rap_travel_rt007
*        ENTITY Travel
*        CREATE
*            set fields with value
*                #( (
*                    %cid = 'MyContextID_1'
*                    AgencyID = '70012'
*                    CustomerID = '14'
*                    BeginDate = cl_abap_context_info=>get_system_date( )
*                    enddate = cl_abap_context_info=>get_system_date( ) + 10
*                    Description = 'I like RAP again'
*                 ) )
*     mapped data(mapped)
*     failed data(failed)
*     reported data(reported).
*
*    out->write( mapped-travel ).
*
*    COMMIT ENTITIES
*        RESPONSE OF ZI_RAP_Travel_RT007
*        FAILED DATA(failed_commit)
*        REPORTED DATA(reported_commit).
*
*    out->write( 'create done' ).



    "step 8 - modify delete
    modify ENTITIES of zi_rap_travel_rt007
        ENTITY Travel
        delete from
          value
            #( (
                TravelUUID = '12117447F0751EEB88855D1B33F88407'
             ) )
     failed data(failed)
     reported data(reported).


    COMMIT ENTITIES
        RESPONSE OF ZI_RAP_Travel_RT007
        FAILED DATA(failed_commit)
        REPORTED DATA(reported_commit).

    out->write( 'delete done' ).



  ENDMETHOD.
ENDCLASS.
