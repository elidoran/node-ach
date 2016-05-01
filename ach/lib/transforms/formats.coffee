
validator = require '../api/validate'
{aba, abaFull, abaFullPlus, date, time, alphanumeric} = validator

module.exports = formats =

  fileHeader:
    type: '1'
    fields: [
      { name: 'recordType', length:1, pattern:/1/ }
      { name: 'priority', length:2, numeric:true }
      { name: 'destination', length:10, pattern:abaFullPlus, trim:false }
      { name: 'origin', length:10, pattern:abaFullPlus, trim:false }
      { name: 'creationDate', length:6, pattern:date }
      { name: 'creationTime', length:4, pattern:time, optional:true }
      { name: 'idModifier', length:1, pattern:/[A-Z0-9]/ }
      { name: 'recordSize', length:3, pattern:/094/ }
      { name: 'blockingFactor', length:2, pattern:/10/ }
      { name: 'formatCode', length:1, pattern:/1/ }
      { name: 'destinationName', length:23, pattern:alphanumeric, optional:true }
      { name: 'originName', length: 23, pattern:alphanumeric, optional:true }
      { name: 'referenceCode', length:8, pattern:alphanumeric, optional:true }
    ]

  fileFooter:
    type: '9'
    fields: [
      { name: 'recordType', length:1, pattern:/9/ }
      { name: 'batchCount', length:6, numeric:true }
      { name: 'blockCount', length:6, numeric:true }
      { name: 'entryAndAddendaCount', length: 8, numeric:true }
      { name: 'entryHash', length:10, numeric:true }
      { name: 'totalDebit', length:12, numeric:true }
      { name: 'totalCredit', length:12, numeric:true }
      { name: 'reserved', length:39, pattern:/.+/, optional:true }
    ]

  batchHeader:
    type: '5'
    fields: [
      { name: 'recordType', length:1, pattern:/5/ }
      { name: 'serviceClassCode', length:3, numeric:true }
      { name: 'companyName', length:16, pattern:alphanumeric }
      { name: 'discretionaryData', length:20, pattern:alphanumeric, optional:true }
      { name: 'companyId', length:10, pattern:alphanumeric,trim:false }
      { name: 'entryClassCode', length:3, pattern:alphanumeric }
      { name: 'description', length:10, pattern:alphanumeric }
      { name: 'date', length:6, pattern:alphanumeric, optional:true }
      { name: 'effectiveDate', length:6, validate:date }
      { name: 'settlementDate', length:3, pattern:/.{3}/, optional:true } # is numeric, but, is blank until bank sets it
      { name: 'originatorStatusCode', length:1, pattern:alphanumeric }
      { name: 'originatingDFIIdentification', length:8, validate:aba }
      { name: 'num', length:7, numeric:true }
    ]

  batchFooter:
    type: '8'
    fields: [
      { name: 'recordType', length:1, pattern:/8/ }
      { name: 'serviceClassCode', length:3, numeric:true }
      { name: 'entryAndAddendaCount', length:6, numeric:true }
      { name: 'entryHash', length:10, numeric:true }
      { name: 'totalDebit', length:12, numeric:true }
      { name: 'totalCredit', length:12, numeric:true }
      { name: 'companyId', length:10, pattern:alphanumeric,trim:false }
      { name: 'messageAuthenticationCode', length:19, pattern:alphanumeric, optional:true }
      { name: 'reserved', length:6, pattern:/      / }
      { name: 'originatingDFIIdentification', length:8, validate:aba }
      { name: 'num', length:7, numeric:true }
    ]

  CCD:
    entry:
      type: '6'
      fields: [
        { name: 'recordType', length:1, pattern:/6/ }
        { name: 'transactionCode', length:2, pattern:/([23])([2378])/ }
        { name: 'receivingDFIIdentification', length:8, numeric:true, validate:aba }
        { name: 'checkDigit', length:1, numeric:true }
        { name: 'dfiAccount', length:17, pattern:alphanumeric }
        { name: 'amount', length:10, numeric:true }
        { name: 'identificationNumber', length:15, pattern:alphanumeric, optional:true }
        { name: 'receivingCompanyName', length:22, pattern:alphanumeric }
        { name: 'discretionaryData', length:2, pattern:alphanumeric, optional:true }
        { name: 'addendaIndicator', length:1, pattern:/0|1/ }
        { name: 'traceNumber', length:15, numeric:true, pattern:/(\d{8})(\d{7})/ }
      ]
    addenda:
      type: '7'
      fields: [
        { name: 'recordType', length:1, pattern:/7/ }
        { name: 'type', length:2, pattern:/05/ }
        { name: 'info', length:80, pattern:alphanumeric, optional:true }
        { name: 'num', length:4, numeric:true, pattern:/\d{4}/}
        { name: 'entryNum', length:7, numeric:true, pattern:/\d{7}/}
      ]

  CTX:
    entry:
      type: '6'
      fields: [
        { name: 'recordType', length:1, pattern:/6/ }
        { name: 'transactionCode', length:2, pattern:/([23])([2378])/ }
        { name: 'receivingDFIIdentification', length:8, validate:aba }
        { name: 'checkDigit', length:1, numeric:true }
        { name: 'dfiAccount', length:17, pattern:alphanumeric }
        { name: 'amount', length:10, numeric:true }
        { name: 'identificationNumber', length:15, pattern:alphanumeric }
        { name: 'addendaCount', length:4, numeric:true, pattern:/\d{4}/ }
        { name: 'receivingCompanyName', length:16, pattern:alphanumeric }
        { name: 'reserved', length:2, pattern:/../ }
        { name: 'discretionaryData', length:2, pattern:alphanumeric }
        { name: 'addendaIndicator', length:1, pattern:/0|1/ }
        { name: 'traceNumber', length:15, numeric:true, pattern:/(\d{8})(\d{7})/ }
      ]
    addenda:
      type: '7'
      fields: [
        { name: 'recordType', length:1, pattern:/7/ }
        { name: 'type', length:2, pattern:/05/ }

        { name: 'info', length:80, pattern:alphanumeric }

        { name: 'segmentName', length:3, pattern:/ISA/ }
        { name: 'separator', length:1, pattern:/\*/ }
        { name: 'authorizationInformationQualifier', length:2 }
        { name: 'separator', length:1, pattern:/\*/ }
        { name: 'authorizationInformation', length:10 }
        { name: 'separator', length:1, pattern:/\*/ }
        { name: 'securityInformationQualifier', length:2, pattern:/\*/ }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'securityInformation', length:10 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'interchangeIDQualifier', length:2 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'interchangeSenderID', length:15 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'interchangeIDQualifier', length:2 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'interchangeReceiverID', length:15 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'interchangeDate', length:6, pattern:date }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'interchangeTime', length:4, pattern:time }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'interfaceControlStandardsIdentifier', length:1 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'interchangeControlNumber', length:9 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'acknowledgeRequested', length:1 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'testIndicator', length:1 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'subElementSeparator', length:1 }
        { name: 'segmentSeparator', length:1, pattern:/\*/ }
        { name: 'segmentName', length:2, pattern:/ST/ }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'functionalIdentifierCode', length:2 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'applicationSendersCode', length:15 }   # 2/15 means what?
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'applicationReceiversCode', length:15 } # 2/15 means what?
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'date', length:6, pattern:date }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'time', length:6, pattern:/\d{4}(\d|[ ]){2}/ }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'groupControlNumber', length:9 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        { name: 'responsibleAgencyCode', length:2 }
        { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        # { name: 'version', length:3, pattern:// }
        # { name: 'release', length:3, pattern:// }
        # { name: 'industryIdenfierCode', length:5, pattern:// }
        # { name: 'segmentSeparator', length:1, pattern:/\*/ }
        # { name: 'segmentName', length:2, pattern:/BPR/ }
        # { name: 'transactionCode', length:, pattern:// }
        # { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        # { name: '', length:, pattern:// }
        # { name: 'dataElementSeparator', length:1, pattern:/\*/ }
        # { name: '', length:, pattern:// }
        # { name: '', length:, pattern:// }
        # { name: '', length:, pattern:// }
        # { name: '', length:, pattern:// }


        { name: 'sequenceNumber', length:4, numeric:true, pattern:/\d{4}/}
        { name: 'entrySequenceNumber', length:7, numeric:true, pattern:/\d{7}/}
      ]

# these are the same
formats.PPD = formats.CCD
