class Queries {
  static const QUERY_INTERACTION_FORMS = r'''
  query interactionFormQuery(
    $formId: Int!
    $orgId: Int!
    $type: String
    $isChaining: Boolean
    $sessionId: String
  ) {
    iForm(
      formId: $formId
      orgId: $orgId
      type: $type
      isChaining: $isChaining
      sessionId: $sessionId
    ) {
      id
      templateId
      nextFormId
      parentFormId
      name
      url
      parameters
      formType
      status
      expiry
      multiple
      chain
      orgId
      userId
      roleId
      restrictionType
      statusCode
      submissionArn
      sessionId
    }
  }
''';

static const QUERY_CREATE_ORGANIZATION_PROFILE = r'''
  query createOrganizationProfileQuery(
    $industryTerm: String!
    $countryId: String!
  ) {
    industriesFiltered: industries(term: $industryTerm) {
      id
      name
      industryCode
      level5CodesAndNames
    }
    country(id: $countryId) {
      id
      name
      countryCallingCode
      currencyCode
      currencyName
      cities {
        id
        name
        countryCode
        longitude
        latitude
        timezone
        state
        stateCode
        population
      }
    }
  }
''';

static const QUERY_ORGANIZATIONS = '''
  query organizationsQuery {
    organizations {
      organizations {
        id
        name
        crn
        city
        country
        zipCode
        phone
        baseCurrency
        financingCurrency
        orgType
        companyType
        isClient
        industries {
          id
          name
          industryCode
          level5CodesAndNames
        }
        orgIntegrations {
          orgIntegrationId
          orgId
          organizationName
          integrationType
          integrationId
          integrationSubtype
          integrationName
          integrationShortname
          lastUpdate
          lastUpdateAttempt
          expiry
          executionarn
          status
          formId
          sync
        }
      }
      responseStatus {
        statusCode
        success
        message
      }
      totalCount
    }
  }
''';

static const QUERY_INTERACTION_FORMS_DATA = '''
  query interactionFormsDataQuery {
    user: profile {
      id
      userId
      firstName
      lastName
      email
      mobile
      currentOrgId
      language
      emailVerified
      mobileVerified
      kycStatus
      roles {
        orgId
        roleId
        orgName
        roleName
      }
      lastOrgSession {
        id
      }
      userHash
    }
    organizations {
      organizations {
        id
        name
        crn
        city
        country
        zipCode
        phone
        baseCurrency
        financingCurrency
        orgType
        companyType
        isClient
        industries {
          id
          name
          industryCode
          level5CodesAndNames
        }
        orgIntegrations {
          orgIntegrationId
          orgId
          organizationName
          integrationType
          integrationId
          integrationSubtype
          integrationName
          integrationShortname
          lastUpdate
          lastUpdateAttempt
          expiry
          executionarn
          status
          formId
          sync
        }
      }
      responseStatus {
        statusCode
        success
        message
      }
      totalCount
    }
  }
''';

static const QUERY_LIST_CALLBACK_REASONS = r'''
  query listCallbackReasonsQuery($language: String) {
    listCallbackReasons: LIST_CALLBACK_REASONS(language: $language) {
      id
      name
    }
  }
''';

// NOTE: This is a REST endpoint
static const QUERY_CHECK_SIGNUP_TOKEN = r'''
  query checkSignupToken($token: String) {
    checkSignupToken(token: $token)
      @rest(type: "checkSignupToken", path: "/token/verify/{args.token}") {
      email
      message
      accepted
      status
    }
  }
''';

/////////////////////////////////

static const QUERY_DASHBOARD_LAYOUT = r'''
  query getUserInfoQuery {
    user: profile {
      id
      userId
      firstName
      lastName
      email
      mobile
      currentOrgId
      language
      emailVerified
      mobileVerified
      kycStatus
      roles {
        orgId
        roleId
        orgName
        roleName
      }
      lastOrgSession {
        id
      }
      userHash
    }
  }
''';

static const QUERY_BUSINESS_ACCOUNT_SUMMARY = r'''
  query getBusinessAccountSummary(
    $orgId: Int!
    $isAdmin: Boolean!
    ){
    readBusinessAcccountSummary(orgId: $orgId) @include(if: $isAdmin) {
      data {
        orgId
        totalBalance
        totalFcaBalance
        totalFplBalance
        totalPhysicalCards
        totalVirtualCards
        currencyCode
        businessAccount {
          id
          accountType
          orgId
          parentAccountId
          userId
          cvv
          publicToken
          permanentAccountNumber
          accountName
          startDate
          expiryDate
          balance
          status
          cardStatus
          currencyCode
          accountSubtype
          availableLimit
          totalCreditLimit
          totalUnbilledAmount
          outstandingAuthorisedAmount
          lastBilledAmount
          billingDate
          dueDate
          creditUsage
          availableBalance
          virtualAccountNumber
          bankName
          bankAccountName
          bankBranchCode
          odBalance
          totalLimit
          holdBalance
          cardType
          cardName
          remarks
          merchantId
          name
        }
        creditLine {
          id
          name
          currencyCode
          creditUsage
          totalCreditLimit
          availableLimit
          dueDate
          totalUnbilledAmount
          lastBilledAmount
          accountType
          status
        }
      }
      response {
        statusCode
        success
        message
      }
    }
  }
''';

static const QUERY_USER_ACCOUNT_SUMMARY = r'''
query getUserFinanceAccountSummary($orgId: Int!) {
readUserFinanceAccountSummary(orgId: $orgId) {
    data {
      orgId
      userId
      totalSpend
      totalPhysicalCards
      totalVirtualCards
      currencyCode
      physicalCard {
        id
        accountType
        accountName
        accountSubtype
        orgId
        parentAccountId
        userId
        cvv
        permanentAccountNumber
        cardStatus
        startDate
        expiryDate
        balance
        status
        currencyCode
        spendControlLimits {
          transactionLimit
          variancePercentage
          allowedCategories {
            categoryName
            displayName
            isAllowed
          }
        }
        financeAccountLimits {
          id
          limitType
          limitValue
          controlValue
          utilization
          availableLimit
          status
        }
      }
      virtualCards {
        id
        accountType
      }
    }
    response {
      statusCode
      success
      message
    }
  }
}
''';

static const QUERY_RECENT_TRANSACTIONS = r'''
query recentTransactionsQuery($orgId: Int!, $userId: Int, $flaId: String, $status: String, $startDate: Long, $endDate: Long, $filterArgs: String, $limit: Int, $offset: Int) {
    listTransactions(
    orgId: $orgId
    userId: $userId
    flaId: $flaId
    status: $status
    startDate: $startDate
    endDate: $endDate
    filterArgs: $filterArgs
    limit: $limit
    offset: $offset
  ) {
    statusCode
    success
    message
    totalCount
    financeAccountTransactions {
      id
      transactionCurrency
      transactionAmount
      transactionType
      status
      merchantName
      transactionDate
      billCurrency
      billAmount
      owner
      pan
      paymentMethod
      txnFinanceAccId
      description
      transactionAccountPublicToken
      sourceTransactionId
      sourceTransactionMatchingId
      sourceTransactionTraceId
      sourceTransactionStatus
      receiptId
      receiptStatus
      cardName
      fxrBillAmount
      qualifiers
    }
  }
}

''';

static const QUERY_GET_USER_SETTING = r'''
query getUserSettingInfo {
  user: profile {
    id
    userId
    firstName
    lastName
    email
    mobile
    currentOrgId
    language
    emailVerified
    mobileVerified
    kycStatus
    roles {
      orgId
      roleId
      orgName
      roleName
    }
    lastOrgSession {
      id
    }
    userHash
  }
  currentUserInvitations {
    id
    orgId
    orgName
    email
    role
    senderId
    senderName
    invitationToken
    invitationSentAt
    invitationAcceptedAt
    createdAt
    status
  }
}
''';

static const QUERY_GET_COMPANY_SETTING = r'''
query organization($orgId: Int!) {
  organization(orgId: $orgId) {
    id
    name
    crn
    city
    country
    zipCode
    phone
    organizationAlias
    fxrEnableSpendControl
    baseCurrency
    financingCurrency
    contactName
    orgType
    companyType
    isClient
    industries {
      id
      name
      industryCode
      level5CodesAndNames
    }
    orgAddress {
      id
      orgId
      addressLine1
      addressLine2
      addressLine3
      addressLine4
      postalCode
      city
      country
    }
    orgOperatingAddress {
      id
      orgId
      addressLine1
      addressLine2
      addressLine3
      addressLine4
      postalCode
      city
      country
    }
  }
  organizationApps(orgId: $orgId) {
      orgId
    installedApps {
        orgIntegrationId
      orgId
      organizationName
      integrationType
      integrationId
      integrationSubtype
      integrationName
      integrationShortname
      lastUpdate
      lastUpdateAttempt
      expiry
      executionarn
      status
      formId
      sync
    }
    connectToApps {
        id
      name
      integrationType
      integrationSubtype
      formId
      reference
      organizationName
      lastUpdate
    }
  }
}
''';

static const QUERY_MY_VIRTUAL_CARD_TRANSACTION = r'''
query myVirtualCardTransactionsQuery($flaId: String, $orgId: Int!, $status: String, $limit: Int, $offset: Int, $filterArgs: String, $startDate: Long, $endDate: Long, $userId: Int) {
  listTransactions(
    flaId: $flaId
    orgId: $orgId
    status: $status
    limit: $limit
    offset: $offset
    filterArgs: $filterArgs
    startDate: $startDate
    endDate: $endDate
    userId: $userId
  ) {
    statusCode
    success
    message
    totalCount
    financeAccountTransactions {
      id
      transactionCurrency
      transactionAmount
      transactionType
      status
      merchantName
      transactionDate
      billCurrency
      billAmount
      owner
      pan
      paymentMethod
      txnFinanceAccId
      description
      transactionAccountPublicToken
      sourceTransactionId
      sourceTransactionMatchingId
      sourceTransactionTraceId
      sourceTransactionStatus
      receiptId
      receiptStatus
      cardName
      fxrBillAmount
      cardType
      qualifiers
    }
  }
}
''';
static const QUERY_MY_VIRTUAL_CARD_LIST = r'''
query myVirtualCardsListQuery($orgId: Int!, $accountSubtype: String, $status: String, $search: String, $limit: Int, $offset: Int, $sort: String) {
  listUserFinanceAccounts(
    orgId: $orgId
    accountSubtype: $accountSubtype
    status: $status
    search: $search
    limit: $limit
    offset: $offset
    sort: $sort
  ) {
    totalCount
    financeAccounts {
      id
      accountType
      orgId
      parentAccountId
      userId
      cvv
      publicToken
      permanentAccountNumber
      accountName
      startDate
      expiryDate
      balance
      status
      cardStatus
      currencyCode
      accountSubtype
      availableLimit
      totalCreditLimit
      totalUnbilledAmount
      outstandingAuthorisedAmount
      lastBilledAmount
      billingDate
      dueDate
      creditUsage
      availableBalance
      financeAccountLimits {
        id
        limitType
        limitValue
        controlValue
        availableLimit
        status
      }
      virtualAccountNumber
      bankName
      bankAccountName
      bankBranchCode
      odBalance
      totalLimit
      holdBalance
      cardType
      cardName
      remarks
      merchantId
      name
    }
  }
}
''';


static const QUERY_LIST_CARDNAME = r'''
query listCardNamesQuery($orgId: Int!, $financeAccountType: String) {
  listFinanceAccounts(orgId: $orgId, financeAccountType: $financeAccountType) {
    financeAccounts {
      id
      accountType
      orgId
      parentAccountId
      userId
      cvv
      publicToken
      permanentAccountNumber
      accountName
      startDate
      expiryDate
      balance
      status
      cardStatus
      currencyCode
      accountSubtype
      availableLimit
      totalCreditLimit
      totalUnbilledAmount
      outstandingAuthorisedAmount
      lastBilledAmount
      billingDate
      dueDate
      creditUsage
      availableBalance
      financeAccountLimits {
        id
        limitValue
        availableLimit
      }
      virtualAccountNumber
      bankName
      bankAccountName
      bankBranchCode
      odBalance
      totalLimit
      holdBalance
      cardType
      cardName
      remarks
      merchantId
      name
      cardExpiryDate
    }
  }
}
''';



static const QUERY_TEAM_CARD_LIST = r'''
query teamCardsList($orgId: Int!, $teamId: String, $accountSubtype: String, $status: String, $search: String, $limit: Int, $offset: Int, $sort: String) {
  listTeamFinanceAccounts(
    orgId: $orgId
    teamId: $teamId
    accountSubtype: $accountSubtype
    status: $status
    search: $search
    limit: $limit
    offset: $offset
    sort: $sort
  ) {
    totalCount
    financeAccounts {
      id
      accountType
      orgId
      parentAccountId
      userId
      cvv
      publicToken
      permanentAccountNumber
      accountName
      startDate
      expiryDate
      balance
      status
      cardStatus
      currencyCode
      accountSubtype
      availableLimit
      totalCreditLimit
      totalUnbilledAmount
      outstandingAuthorisedAmount
      lastBilledAmount
      billingDate
      dueDate
      creditUsage
      availableBalance
      financeAccountLimits {
        id
        limitType
        limitValue
        controlValue
        utilization
        availableLimit
        status
      }
      virtualAccountNumber
      bankName
      bankAccountName
      bankBranchCode
      odBalance
      totalLimit
      holdBalance
      cardType
      cardName
      remarks
      merchantId
      name
    }
  }
}
''';

static const QUERY_TOTAL_COMPANY_BALANCE = r'''
query totalCompanyBalance($orgId: Int!) {
  readBusinessAcccountSummary(orgId: $orgId) {
    data {
      totalBalance
      totalFcaBalance
      totalFplBalance
      currencyCode
      businessAccount {
        bankName
        balance
        bankAccountName
        availableBalance
        accountName
        virtualAccountNumber
        currencyCode
      }
      creditLine {
        availableBalance
        currencyCode
      }
    }
  }
}
''';

static const QUERY_ALL_TRANSACTIONS_TAB_PANE_CONTENTS = r'''
query allTransactionsTabPaneContents($flaId: String, $orgId: Int!, $status: String, $limit: Int, $offset: Int, $filterArgs: String, $startDate: Long, $endDate: Long, $userId: Int) {
  listTransactions(
    flaId: $flaId
    orgId: $orgId
    status: $status
    limit: $limit
    offset: $offset
    filterArgs: $filterArgs
    startDate: $startDate
    endDate: $endDate
    userId: $userId
  ) {
    statusCode
    success
    message
    totalCount
    financeAccountTransactions {
      id
      transactionCurrency
      transactionAmount
      transactionType
      status
      merchantName
      transactionDate
      billCurrency
      billAmount
      owner
      pan
      paymentMethod
      txnFinanceAccId
      description
      transactionAccountPublicToken
      sourceTransactionId
      sourceTransactionMatchingId
      sourceTransactionTraceId
      sourceTransactionStatus
      receiptId
      receiptStatus
      cardName
      fxrBillAmount
      cardType
      qualifiers
    }
  }
  orgMembers(orgId: $orgId) {
    orgMembers {
      id
      userId
      firstName
      lastName
      email
      mobile
      language
      roles
      kycStatus
    }
  }
}
''';

static const QUERY_ORGINTEGRATIONS = r'''
  query getOrgIntegrations($orgId: Int!) {
    orgIntegrations(orgId: $orgId) {
      orgIntegrationId
      orgId
      organizationName
      integrationType
      integrationId
      integrationSubtype
      integrationName
      integrationShortname
      lastUpdate
      lastUpdateAttempt
      expiry
      executionarn
      status
      formId
      sync
    }
  }
''';

static const QUERY_ALL_TRANSACTIONS = r'''
query allTransactionsQuery($flaId: String!, $orgId: Int!, $status: String, $limit: Int, $offset: Int, $filterArgs: String, $startDate: Long, $endDate: Long) {
  listTransactions(
    flaId: $flaId
    orgId: $orgId
    status: $status
    limit: $limit
    offset: $offset
    filterArgs: $filterArgs
    startDate: $startDate
    endDate: $endDate
  ) {
    statusCode
    success
    message
    totalCount
    financeAccountTransactions {
      id
      transactionCurrency
      transactionAmount
      transactionType
      status
      merchantName
      transactionDate
      billCurrency
      billAmount
      owner
      pan
      paymentMethod
      txnFinanceAccId
      description
      transactionAccountPublicToken
      sourceTransactionId
      sourceTransactionMatchingId
      sourceTransactionTraceId
      sourceTransactionStatus
      receiptId
      receiptStatus
      cardName
      fxrBillAmount
      qualifiers
    }
  }
}
''';

static const QUERY_PHYSICAL_TEAMCARD_LIST = r'''
query teamCardsList($orgId: Int!, $teamId: String, $accountSubtype: String, $status: String, $search: String, $limit: Int, $offset: Int, $sort: String) {
  listTeamFinanceAccounts(
    orgId: $orgId
    teamId: $teamId
    accountSubtype: $accountSubtype
    status: $status
    search: $search
    limit: $limit
    offset: $offset
    sort: $sort
  ) {
    totalCount
    financeAccounts {
      id
      accountType
      orgId
      parentAccountId
      userId
      cvv
      publicToken
      permanentAccountNumber
      accountName
      startDate
      expiryDate
      balance
      status
      cardStatus
      currencyCode
      accountSubtype
      availableLimit
      totalCreditLimit
      totalUnbilledAmount
      outstandingAuthorisedAmount
      lastBilledAmount
      billingDate
      dueDate
      creditUsage
      availableBalance
      financeAccountLimits {
        id
        limitType
        limitValue
        controlValue
        utilization
        availableLimit
        status
      }
      virtualAccountNumber
      bankName
      bankAccountName
      bankBranchCode
      odBalance
      totalLimit
      holdBalance
      cardType
      cardName
      remarks
      merchantId
      name
    }
  }
}

''';

static const QUERY_BILLED_UNBILLED_TRANSACTIONS = r'''
query billedUnbilledTransactions($orgId: Int!, $limit: Int, $offset: Int, $status: String, $flaId: String) {
  listTransactions(
    orgId: $orgId
    limit: $limit
    offset: $offset
    status: $status
    flaId: $flaId
  ) {
    financeAccountTransactions {
      id
      transactionCurrency
      transactionAmount
      transactionType
      status
      merchantName
      transactionDate
      description
      fxrBillAmount
      qualifiers
    }
    totalCount
  }
}
''';

static const QUERY_BILLING_STATEMENTTABLE = r'''
query billingStatementsTable($fplId: String!, $limit: Int) {
  listBills(fplId: $fplId, limit: $limit) {
    statusCode
    success
    message
    listOfBills {
      statementDate
      dueDate
      statementId
      totalAmountDue
      documentLink
      status
      currency
    }
  }
}
''';

static const QUERY_INDUSTRY_FILTERD = r'''
query industriesFiltered($industryTerm: String!) {
  industriesFiltered: industries(term: $industryTerm) {
    id
    name
    industryCode
    level5CodesAndNames
  }
}
''';

static const QUERY_LIST_COMPANY_TYPE = r'''
query listCompanyTypes($country: String) {
  LIST_COMPANY_TYPES(country: $country) {
    id
    name
  }
}
''';

static const QUERY_GET_COUNTRY = r'''
query getCountry($countryId: String!) {
  country(id: $countryId) {
    id
    name
    countryCallingCode
    currencyCode
    currencyName
    cities {
      id
      name
      countryCode
      longitude
      latitude
      timezone
      state
      stateCode
      population
    }
  }
}
''';

static const QUERY_GET_TRANSACTION_DETAIL = r'''
query getTransactionDetails($sourceTransactionId: String!, $financeAccountId: String!) {
  getTransactionDetails(
    sourceTransactionId: $sourceTransactionId
    financeAccountId: $financeAccountId
  ) {
    getTransactionData {
      sourceTransactionId
      description
      fxrBillAmount
      transactionDate
      billCurrency
      merchantName
      status
      userName
      paymentMethod
      pan
      remarkData {
        remarkUserName
        remarkCreatedAt
        remark
      }
      receiptData {
        receiptId
        receiptStatus
        uploadedByUserId
        uploadedAt
        fileId
        fileType
        uploadedByName
        matchingStatus
      }
    }
  }
}
''';

static const QUERY_DOC_DOWNLOAD = r'''
query downloadDocument($fileId: String!) {
  downloadDocument(fileId: $fileId)
}''';

static const QUERY_TEAMMEMBER_INVITATIONS = r'''
query teamMembersInvitations($orgId: Int!, $search: String, $limit: Int, $offset: Int, $sort: String) {
  invitations(
    orgId: $orgId
    search: $search
    limit: $limit
    offset: $offset
    sort: $sort
  ) {
    userInvitationList {
      id
      orgId
      orgName
      email
      role
      senderId
      senderName
      invitationToken
      invitationSentAt
      invitationAcceptedAt
      createdAt
      status
      userId
    }
    totalCount
    responseStatus {
      statusCode
      success
      message
    }
  }
}
''';

static const QUERY_LIST_ELIGIBLE_USER_CARD = r'''
query listEligibleUsersCard($orgId: Int!, $accountSubtype: String!) {
  listEligibleUsersForCard(orgId: $orgId, accountSubtype: $accountSubtype) {
    eligibleUsers {
      id
      firstName
      lastName
    }
  }
}
''';

static const QUERY_LIST_MERCHANT_GROUP = r'''
query listMerchantGroups($countryCode: String!) {
  listMerchantGroups(countryCode: $countryCode) {
    merchantGroup {
      id
      name
      displayName
    }
  }
}''';

static const QUERY_READ_FINANCE_ACCOUNT = r'''
query readFinanceAccount($orgId: Int!, $financeAccountId: String!) {
  readFinanceAccount(orgId: $orgId, financeAccountId: $financeAccountId) {
    id
    accountType
    orgId
    parentAccountId
    userId
    cvv
    publicToken
    permanentAccountNumber
    accountName
    startDate
    expiryDate
    balance
    status
    cardStatus
    currencyCode
    accountSubtype
    availableLimit
    totalCreditLimit
    totalUnbilledAmount
    outstandingAuthorisedAmount
    lastBilledAmount
    billingDate
    dueDate
    creditUsage
    availableBalance
    cardType
    cardExpiryDate
    financeAccountLimits {
      id
      limitType
      limitValue
      controlValue
      utilization
      availableLimit
      status
    }
    virtualAccountNumber
    bankName
    bankAccountName
    bankBranchCode
    odBalance
    totalLimit
    holdBalance
    spendControlLimits {
      transactionLimit
      variancePercentage
      allowedCategories {
        categoryName
        displayName
        isAllowed
      }
    }
  }
}
''';
}

