@EndUserText.label: 'Travel projection view'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true

define root view entity zc_rap_travel_rt007 as projection on ZI_RAP_Travel_RT007 as Travel {
    //ZI_RAP_TRAVEL_RT007
    key TravelUUID,
    @Search.defaultSearchElement: true
    TravelID,
    @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Agency', element: 'AgencyID' } }]
    @ObjectModel.text.element: ['AgencyName']
    @Search.defaultSearchElement: true
    AgencyID,
    _Agency.Name as AgencyName,
    @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer', element: 'CustomerID' } }]
    @Search.defaultSearchElement: true
    @ObjectModel.text.element: ['CustomerName']
    CustomerID,
    _Customer.LastName as CustomerName,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
    CurrencyCode,
    Description,
    TravelStatus,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    //ZI_RAP_TRAVEL_RT007
    _Agency,
    _Booking: redirected to composition child zc_rap_booking_rt007,
    _Currency,
    _Customer
}
