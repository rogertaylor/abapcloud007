CLASS zcl_generate_week2_rt007 DEFINITION
  PUBLIC
  INHERITING FROM cl_xco_cp_adt_simple_classrun
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

  PROTECTED SECTION.
    METHODS main REDEFINITION.
  PRIVATE SECTION.

    DATA package_name  TYPE sxco_package VALUE  'ZRT007_RAP_TRAVEL_007'.
    DATA unique_number TYPE string VALUE 'RT007'.
    DATA table_name_travel  TYPE sxco_dbt_object_name.
    DATA table_name_booking TYPE sxco_dbt_object_name.

    DATA dev_system_environment TYPE REF TO if_xco_cp_gen_env_dev_system.
    DATA transport TYPE    sxco_transport .

    TYPES: BEGIN OF t_table_fields,
             field         TYPE sxco_ad_field_name,
             data_element  TYPE sxco_ad_object_name,
             is_key        TYPE abap_bool,
             not_null      TYPE abap_bool,
             currencyCode  TYPE sxco_cds_field_name,
             unitOfMeasure TYPE sxco_cds_field_name,
           END OF t_table_fields.

    TYPES: tt_fields TYPE STANDARD TABLE OF t_table_fields WITH KEY field.

    METHODS put_table  IMPORTING io_put_operation        TYPE REF TO if_xco_cp_gen_d_o_put
                                 table_fields            TYPE tt_fields
                                 table_name              TYPE sxco_dbt_object_name
                                 table_short_description TYPE if_xco_cp_gen_tabl_dbt_s_form=>tv_short_description .

    METHODS get_table_travel_fields  RETURNING VALUE(table_travel_fields) TYPE tt_fields.
    METHODS get_table_booking_fields  RETURNING VALUE(table_booking_fields) TYPE tt_fields.
    METHODS get_json_string RETURNING VALUE(json_string) TYPE string.

ENDCLASS.



CLASS ZCL_GENERATE_WEEK2_RT007 IMPLEMENTATION.


  METHOD main.

    package_name = to_upper( package_name ).

    DATA(lo_package) = xco_cp_abap_repository=>object->devc->for( package_name ).
    DATA(lv_package_software_component) = lo_package->read( )-property-software_component->name.
    DATA(lo_transport_layer) = lo_package->read(  )-property-transport_layer.
    DATA(lo_transport_target) = lo_transport_layer->get_transport_target( ).
    DATA(lv_transport_target) = lo_transport_target->value.
    DATA(lo_transport_request) = xco_cp_cts=>transports->workbench( lo_transport_target->value  )->create_request( | create tables |  ).
    DATA(lv_transport) = lo_transport_request->value.
    transport = lv_transport.
    dev_system_environment = xco_cp_generation=>environment->dev_system( lv_transport ).

    IF NOT lo_package->exists( ).

      RAISE EXCEPTION TYPE zcx_rap_generator
        EXPORTING
          textid   = zcx_rap_generator=>package_does_not_exist
          mv_value = CONV #( package_name ).

    ENDIF.

    " Execute the PUT operation for the objects in the .
    DATA(lo_objects_put_operation) = dev_system_environment->create_put_operation( ).

    table_name_travel = |ZRAP_ATRAV_{ unique_number }|.
    table_name_booking = |ZRAP_ABOOK_{ unique_number }|.

    DATA(table_booking_fields) = get_table_booking_fields(  ).

    DATA(table_travel_fields) = get_table_travel_fields(  ).

    DATA(json_string) = get_json_string(  ).



    put_table(
      EXPORTING
        io_put_operation        = lo_objects_put_operation
        table_fields            = table_travel_fields
        table_name              = table_name_travel
        table_short_description = 'Travel data'
    ).



    put_table(
      EXPORTING
        io_put_operation        = lo_objects_put_operation
        table_fields            = table_BOOKING_fields
        table_name              = table_name_booking
        table_short_description = 'Booking data'
    ).

    DATA(lo_result) = lo_objects_put_operation->execute( ).

    out->write( 'tables created' ).

    "out->write( json_string ).

    DATA(lo_findings) = lo_result->findings.
    DATA(lt_findings) = lo_findings->get( ).

    IF lt_findings IS NOT INITIAL.
      out->write( lt_findings ).
    ENDIF.

    "create RAP BO

    DATA(xco_api) = NEW zcl_rap_xco_cloud_lib( ).
    "DATA(xco_api) = NEW zcl_rap_xco_on_prem_lib(  ).

    DATA(root_node) = NEW zcl_rap_node(  ).
    root_node->set_is_root_node( ).
    root_node->set_xco_lib( xco_api ).

    DATA(rap_bo_visitor) = NEW zcl_rap_xco_json_visitor( root_node ).
    DATA(json_data) = xco_cp_json=>data->from_string( json_string ).
    json_data->traverse( rap_bo_visitor ).

    DATA(rap_bo_generator) = NEW zcl_rap_bo_generator( root_node ).
    DATA(lt_todos) = rap_bo_generator->generate_bo(  ).


    out->write( | RAP BO { root_node->rap_root_node_objects-behavior_definition_i  } generated successfully | ).



  ENDMETHOD.


  METHOD put_table.

    DATA(lo_specification) = io_put_operation->for-tabl-for-database_table->add_object( table_name
              )->set_package( package_name
               )->create_form_specification( ).

    lo_specification->set_short_description( table_short_description ).

    DATA database_table_field  TYPE REF TO if_xco_gen_tabl_dbt_s_fo_field  .

    LOOP AT table_fields INTO DATA(table_field_line).
      database_table_field = lo_specification->add_field( table_field_line-field  ).
      database_table_field->set_type( xco_cp_abap_dictionary=>data_element( table_field_line-data_element ) ).
      IF table_field_line-is_key = abap_true.
        database_table_field->set_key_indicator( ).
      ENDIF.
      IF table_field_line-not_null = abap_true.
        database_table_field->set_not_null( ).
      ENDIF.
      IF table_field_line-currencycode IS NOT INITIAL.
        database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( table_name ) ) )->set_reference_field( to_upper( table_field_line-currencycode ) ).
      ENDIF.
      IF table_field_line-unitofmeasure IS NOT INITIAL.
        database_table_field->currency_quantity->set_reference_table( CONV #( to_upper( table_name ) ) )->set_reference_field( to_upper( table_field_line-unitofmeasure ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_json_string.


    json_string ='{' && |\r\n|  &&
                 '  "implementationType": "managed_uuid",' && |\r\n|  &&
                 '  "transactionalbehavior" : false,' && |\r\n|  &&
                 '  "namespace": "Z",' && |\r\n|  &&
                 |  "suffix": "_{ unique_number }",| && |\r\n|  &&
                 '  "prefix": "RAP_",' && |\r\n|  &&
                 |  "package": "{ package_name }",| && |\r\n|  &&
                 '  "datasourcetype": "table",' && |\r\n|  &&
                 '  "hierarchy": {' && |\r\n|  &&
                 '    "entityName": "Travel",' && |\r\n|  &&
                 |    "dataSource": "{ table_name_travel }",| && |\r\n|  &&
                 '    "objectId": "travel_id",' && |\r\n|  &&
                 '    "uuid": "travel_uuid",' && |\r\n|  &&
                 '    "valueHelps": [' && |\r\n|  &&
                 '      {' && |\r\n|  &&
                 '        "alias": "Agency",' && |\r\n|  &&
                 '        "name": "/DMO/I_Agency",' && |\r\n|  &&
                 '        "localElement": "AgencyID",' && |\r\n|  &&
                 '        "element": "AgencyID"' && |\r\n|  &&
                 '      },' && |\r\n|  &&
                 '      {' && |\r\n|  &&
                 '        "alias": "Customer",' && |\r\n|  &&
                 '        "name": "/DMO/I_Customer",' && |\r\n|  &&
                 '        "localElement": "CustomerID",' && |\r\n|  &&
                 '        "element": "CustomerID"' && |\r\n|  &&
                 '      },' && |\r\n|  &&
                 '      {' && |\r\n|  &&
                 '        "alias": "Currency",' && |\r\n|  &&
                 '        "name": "I_Currency",' && |\r\n|  &&
                 '        "localElement": "CurrencyCode",' && |\r\n|  &&
                 '        "element": "Currency"' && |\r\n|  &&
                 '      }' && |\r\n|  &&
                 '    ],' && |\r\n|  &&
                 '    "associations": [' && |\r\n|  &&
                 '      {' && |\r\n|  &&
                 '        "name": "_Agency",' && |\r\n|  &&
                 '        "target": "/DMO/I_Agency",' && |\r\n|  &&
                 '        "cardinality": "zero_to_one",' && |\r\n|  &&
                 '        "conditions": [' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "projectionField": "AgencyID",' && |\r\n|  &&
                 '            "associationField": "AgencyID"' && |\r\n|  &&
                 '          }' && |\r\n|  &&
                 '        ]' && |\r\n|  &&
                 '      },' && |\r\n|  &&
                 '      {' && |\r\n|  &&
                 '        "name": "_Currency",' && |\r\n|  &&
                 '        "target": "I_Currency",' && |\r\n|  &&
                 '        "cardinality": "zero_to_one",' && |\r\n|  &&
                 '        "conditions": [' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "projectionField": "CurrencyCode",' && |\r\n|  &&
                 '            "associationField": "Currency"' && |\r\n|  &&
                 '          }' && |\r\n|  &&
                 '        ]' && |\r\n|  &&
                 '      },' && |\r\n|  &&
                 '      {' && |\r\n|  &&
                 '        "name": "_Customer",' && |\r\n|  &&
                 '        "target": "/DMO/I_Customer",' && |\r\n|  &&
                 '        "cardinality": "zero_to_one",' && |\r\n|  &&
                 '        "conditions": [' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "projectionField": "CustomerID",' && |\r\n|  &&
                 '            "associationField": "CustomerID"' && |\r\n|  &&
                 '          }' && |\r\n|  &&
                 '        ]' && |\r\n|  &&
                 '      }' && |\r\n|  &&
                 '    ],' && |\r\n|  &&
                 '    "children": [' && |\r\n|  &&
                 '      {' && |\r\n|  &&
                 '        "entityName": "Booking",' && |\r\n|  &&
                 |        "dataSource": "{ table_name_booking }",| && |\r\n|  &&
                 '        "objectId": "booking_id",' && |\r\n|  &&
                 '        "uuid": "booking_uuid",' && |\r\n|  &&
                 '        "parentUuid": "travel_uuid",' && |\r\n|  &&
                 '        "valueHelps": [' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "alias": "Flight",' && |\r\n|  &&
                 '            "name": "/DMO/I_Flight",' && |\r\n|  &&
                 '            "localElement": "ConnectionID",' && |\r\n|  &&
                 '            "element": "ConnectionID",' && |\r\n|  &&
                 '            "additionalBinding": [' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "localElement": "FlightDate",' && |\r\n|  &&
                 '                "element": "FlightDate"' && |\r\n|  &&
                 '              },' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "localElement": "CarrierID",' && |\r\n|  &&
                 '                "element": "AirlineID"' && |\r\n|  &&
                 '              },' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "localElement": "FlightPrice",' && |\r\n|  &&
                 '                "element": "Price"' && |\r\n|  &&
                 '              },' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "localElement": "CurrencyCode",' && |\r\n|  &&
                 '                "element": "CurrencyCode"' && |\r\n|  &&
                 '              }' && |\r\n|  &&
                 '            ]' && |\r\n|  &&
                 '          },' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "alias": "Currency",' && |\r\n|  &&
                 '            "name": "I_Currency",' && |\r\n|  &&
                 '            "localElement": "CurrencyCode",' && |\r\n|  &&
                 '            "element": "Currency"' && |\r\n|  &&
                 '          },' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "alias": "Airline",' && |\r\n|  &&
                 '            "name": "/DMO/I_Carrier",' && |\r\n|  &&
                 '            "localElement": "CarrierID",' && |\r\n|  &&
                 '            "element": "AirlineID"' && |\r\n|  &&
                 '          },' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "alias": "Customer",' && |\r\n|  &&
                 '            "name": "/DMO/I_Customer",' && |\r\n|  &&
                 '            "localElement": "CustomerID",' && |\r\n|  &&
                 '            "element": "CustomerID"' && |\r\n|  &&
                 '          }' && |\r\n|  &&
                 '        ],' && |\r\n|  &&
                 '        "associations": [' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "name": "_Connection",' && |\r\n|  &&
                 '            "target": "/DMO/I_Connection",' && |\r\n|  &&
                 '            "cardinality": "one_to_one",' && |\r\n|  &&
                 '            "conditions": [' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "projectionField": "CarrierID",' && |\r\n|  &&
                 '                "associationField": "AirlineID"' && |\r\n|  &&
                 '              },' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "projectionField": "ConnectionID",' && |\r\n|  &&
                 '                "associationField": "ConnectionID"' && |\r\n|  &&
                 '              }' && |\r\n|  &&
                 '            ]' && |\r\n|  &&
                 '          },' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "name": "_Flight",' && |\r\n|  &&
                 '            "target": "/DMO/I_Flight",' && |\r\n|  &&
                 '            "cardinality": "one_to_one",' && |\r\n|  &&
                 '            "conditions": [' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "projectionField": "CarrierID",' && |\r\n|  &&
                 '                "associationField": "AirlineID"' && |\r\n|  &&
                 '              },' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "projectionField": "ConnectionID",' && |\r\n|  &&
                 '                "associationField": "ConnectionID"' && |\r\n|  &&
                 '              },' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "projectionField": "FlightDate",' && |\r\n|  &&
                 '                "associationField": "FlightDate"' && |\r\n|  &&
                 '              }' && |\r\n|  &&
                 '            ]' && |\r\n|  &&
                 '          },' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "name": "_Carrier",' && |\r\n|  &&
                 '            "target": "/DMO/I_Carrier",' && |\r\n|  &&
                 '            "cardinality": "one_to_one",' && |\r\n|  &&
                 '            "conditions": [' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "projectionField": "CarrierID",' && |\r\n|  &&
                 '                "associationField": "AirlineID"' && |\r\n|  &&
                 '              }' && |\r\n|  &&
                 '            ]' && |\r\n|  &&
                 '          },' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "name": "_Currency",' && |\r\n|  &&
                 '            "target": "I_Currency",' && |\r\n|  &&
                 '            "cardinality": "zero_to_one",' && |\r\n|  &&
                 '            "conditions": [' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "projectionField": "CurrencyCode",' && |\r\n|  &&
                 '                "associationField": "Currency"' && |\r\n|  &&
                 '              }' && |\r\n|  &&
                 '            ]' && |\r\n|  &&
                 '          },' && |\r\n|  &&
                 '          {' && |\r\n|  &&
                 '            "name": "_Customer",' && |\r\n|  &&
                 '            "target": "/DMO/I_Customer",' && |\r\n|  &&
                 '            "cardinality": "one_to_one",' && |\r\n|  &&
                 '            "conditions": [' && |\r\n|  &&
                 '              {' && |\r\n|  &&
                 '                "projectionField": "CustomerID",' && |\r\n|  &&
                 '                "associationField": "CustomerID"' && |\r\n|  &&
                 '              }' && |\r\n|  &&
                 '            ]' && |\r\n|  &&
                 '          }' && |\r\n|  &&
                 '        ]' && |\r\n|  &&
                 '      }' && |\r\n|  &&
                 '    ]' && |\r\n|  &&
                 '  }' && |\r\n|  &&
                 '}'.

  ENDMETHOD.


  METHOD get_table_booking_fields.
    table_booking_fields = VALUE tt_fields(
                   ( field = 'client'
                     data_element      = 'mandt'
                     is_key    = 'X'
                     not_null  = 'X' )
                   ( field = 'booking_uuid '
                     data_element      = 'sysuuid_x16'
                     is_key    = 'X'
                     not_null  = 'X' )
                   ( field = 'travel_uuid'
                     data_element      = 'sysuuid_x16'
                     not_null  = 'X' )
                   ( field = 'booking_id'
                     data_element      = '/dmo/booking_id' )
                   ( field = 'booking_date'
                     data_element      = '/dmo/booking_date' )
                   ( field = 'customer_id'
                     data_element      = '/dmo/customer_id' )
                   ( field = 'carrier_id'
                     data_element      = '/dmo/carrier_id' )
                   ( field = 'connection_id'
                     data_element      = '/dmo/connection_id' )
                   ( field = 'flight_date'
                     data_element      = '/dmo/flight_date' )
                   ( field = 'flight_price'
                     data_element      = '/dmo/flight_price'
                     currencycode  = 'currency_code'  )
                   ( field = 'currency_code'
                     data_element      = '/dmo/currency_code' )
                   ( field = 'created_by'
                     data_element      = 'syuname' )
                   ( field = 'last_changed_by'
                     data_element      = 'syuname' )
                   ( field = 'local_last_changed_at '
                     data_element      = 'timestampl' )
                     ).

  ENDMETHOD.


  METHOD get_table_travel_fields.
    table_travel_fields = VALUE tt_fields(
                  ( field = 'client'
                    data_element      = 'mandt'
                    is_key    = 'X'
                    not_null  = 'X' )
                  ( field = 'travel_uuid'
                    data_element      = 'sysuuid_x16'
                    is_key    = 'X'
                    not_null  = 'X' )
                  ( field = 'travel_id'
                    data_element      = '/dmo/travel_id' )
                  ( field = 'agency_id'
                    data_element      = '/dmo/agency_id' )
                  ( field = 'customer_id'
                    data_element      = '/dmo/customer_id' )
                  ( field = 'begin_date'
                    data_element      = '/dmo/begin_date' )
                  ( field = 'end_date'
                    data_element      = '/dmo/end_date' )
                  ( field = 'booking_fee'
                    data_element      = '/dmo/booking_fee'
                    currencycode  = 'currency_code' )
                  ( field = 'total_price'
                    data_element      = '/dmo/total_price'
                    currencycode  = 'currency_code' )
                  ( field = 'currency_code'
                    data_element      = '/dmo/currency_code' )
                  ( field = 'description'
                    data_element      = '/dmo/description' )
                  ( field = 'overall_status'
                    data_element      = '/dmo/overall_status' )
                  ( field = 'created_by'
                    data_element      = 'syuname' )
                  ( field = 'created_at'
                    data_element      = 'timestampl' )
                  ( field = 'last_changed_by'
                    data_element      = 'syuname' )
                  ( field = 'last_changed_at'
                    data_element      = 'timestampl' )
                  ( field = 'local_last_changed_at '
                    data_element      = 'timestampl' )
                    ).
  ENDMETHOD.
ENDCLASS.
