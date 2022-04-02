class FXRMutations {
  static const MUTATION_PARTNER_CONNECT = r'''
  mutation partnerConnectMutation(
    $partner: String!
    $orgId: Int!
    $callback: String!
  ) {
    partnerConnect(partner: $partner, orgId: $orgId, callback: $callback) {
      status
      redirect
      message
      statusCode
    }
  }
''';

  static const MUTATION_SEND_USER_VERIFICATION_EMAIL = r'''
  mutation sendUserVerificationEmailMutation {
    sendUserVerificationEmail {
      success
    }
  }
''';

  static const MUTATION_VERIFY_CODE = r'''
  mutation verifyCodeMutation($verificationCode: Int!) {
    verifyUserEmail(verificationCode: $verificationCode) {
      success
    }
  }
''';

  static const MUTATION_UPDATE_LAST_ORG_SESSION = r'''
  mutation updateLastOrgSession($orgId: Int!) {
    updateLastOrgSession(orgId: $orgId)
  }
''';

  static const MUTATION_SUBMIT_CALLBACK_REASON = r'''
  mutation submitCallbackReasonMutation(
    $companyName: String!
    $reason: String!
    $language: String
  ) {
    submitCallbackReason: SUBMIT_CALLBACK_REASON(
      companyName: $companyName
      reason: $reason
      language: $language
    ) {
      success
    }
  }
''';
  static const MUTATION_FREEZE_FINANCE_ACCOUNT = r'''
mutation freezeFinanceAccount($financeAccountId: String!, $orgId: Int!) {
  freezeFinanceAccount(financeAccountId: $financeAccountId, orgId: $orgId) {
    statusCode
    success
    message
  }
}
''';
  static const MUTATION_UNFREEZE_FINANCE_ACCOUNT = r'''
mutation unfreezeFinanceAccountMutation($financeAccountId: String!, $orgId: Int!) {
  unfreezeFinanceAccount(financeAccountId: $financeAccountId, orgId: $orgId) {
    statusCode
    success
    message
  }
}
''';

  static const MUTATION_CREATE_ORGANIZATION = r'''
mutation createOrganization($name: String!, $crn: String!, $city: String!, $country: String!, $phone: String!, $proprietorPartner: Boolean!, $baseCurrency: String!, $industries: [Int!], $signupToken: String, $companyType: String!, $businessDescription: String!, $revenueGenerationDetail: String!, $primaryAddress: OrgAddress, $operatingAddress: OrgAddress, $contactName: String, $contactNumber: String) {
  createdOrganization: createOrganizationProfile(
    name: $name
    crn: $crn
    city: $city
    country: $country
    phone: $phone
    proprietorPartner: $proprietorPartner
    baseCurrency: $baseCurrency
    industries: $industries
    signupToken: $signupToken
    companyType: $companyType
    businessDescription: $businessDescription
    revenueGenerationDetail: $revenueGenerationDetail
    primaryAddress: $primaryAddress
    operatingAddress: $operatingAddress
    contactName: $contactName
    contactNumber: $contactNumber
  ) {
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
    integration {
      orgId
      organizationName
      integrationType
      integrationId
      integrationSubtype
      lastUpdate
      lastUpdateAttempt
      expiry
      executionarn
      status
    }
    organizationApplications {
      id
      orgId
      products
      status
      ipaStatus
      date
      applicationChecklist {
        idx
        applicationId
        requirement
        status
        docstatus
      }
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
}
''';

  static const MUTATION_CREATE_KYC_DETAIL = r'''
mutation createKycDetails($orgId: Int!, $firstName: String!, $lastName: String!, $email: String!, $designation: String!, $dateOfBirth: String!, $mobile: String!, $addressLine1: String!, $addressLine2: String, $addressLine3: String, $city: String!, $zipCode: String!, $country: String!) {
  createKycDetails(
    orgId: $orgId
    firstName: $firstName
    lastName: $lastName
    email: $email
    designation: $designation
    dateOfBirth: $dateOfBirth
    mobile: $mobile
    addressLine1: $addressLine1
    addressLine2: $addressLine2
    addressLine3: $addressLine3
    city: $city
    zipCode: $zipCode
    country: $country
  ) {
    id
    firstName
    lastName
    email
    dob
    address {
      line1
      line2
      line3
      town
      state
      postCode
      country
    }
    createdAt
    updatedAt
  }
}
''';

  static const MUTATION_USER_INVITE = r'''
mutation inviteUser($senderId: Int!, $orgId: Int!, $email: String!, $role: String!) {
  inviteUser: inviteUser(
    senderId: $senderId
    orgId: $orgId
    email: $email
    role: $role
  ) {
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

  static const MUTATION_REQUEST_CARD_SPEND = r'''
mutation requestCardSpendControl($orgId: Int!, $cardHolders: [CardHolder!]!, $accountSubtype: String!, $cardType: String, $cardLimit: BigDecimal!, $expiryDate: String, $renewalFrequency: String, $remarks: String, $merchantName: String, $merchantId: Int, $controls: Controls) {
  createFinanceAccountFLASpendControl(
    orgId: $orgId
    cardHolders: $cardHolders
    accountSubtype: $accountSubtype
    cardType: $cardType
    cardLimit: $cardLimit
    expiryDate: $expiryDate
    renewalFrequency: $renewalFrequency
    remarks: $remarks
    merchantName: $merchantName
    merchantId: $merchantId
    controls: $controls
  )
}
''';

  static const MUTATION_UPDATE_ORGANIZATION = r'''
mutation updateOrganization($orgId: Int!, $name: String!, $crn: String!, $city: String!, $country: String!, $zipCode: String!, $phone: String!, $proprietorPartner: Boolean!, $primaryAddress: OrgAddress, $operatingAddress: OrgAddress) {
  updateOrganization: updateOrganizationProfile(
    orgId: $orgId
    name: $name
    crn: $crn
    city: $city
    country: $country
    zipCode: $zipCode
    phone: $phone
    proprietorPartner: $proprietorPartner
    primaryAddress: $primaryAddress
    operatingAddress: $operatingAddress
  ) {
    id
  }
}
''';

  static const MUTATION_UPDATE_USER_PROFILE = r'''
mutation updateUserProfileMutation($userId: Int!, $firstName: String!, $lastName: String!, $mobile: String, $language: String) {
  user: updateUserProfile(
    userId: $userId
    firstName: $firstName
    lastName: $lastName
    mobile: $mobile
    language: $language
  ) {
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
    zendeskToken
    serverTimestamp
    lastOrgSession {
      id
    }
    userHash
  }
}
''';

  static const MUTATION_PHONE_VERIFICATION = r'''
mutation sendVerificationMessageMutation($mobile: String!, $verificationType: String!, $country: String!, $language: String) {
  sendVerificationMessage(
    mobile: $mobile
    verificationType: $verificationType
    country: $country
    language: $language
  ) {
    userId
    mobileNumber
    verificationType
    country
    language
  }
}
''';

  static const MUTATION_PARTNER_BANK_PUSH = r'''
mutation partnerBAnkPushMutation($partner: String!, $orgId: Int!) {
    partnerBankPush(partner: $partner, orgId: $orgId) {
    status
    redirect
    message
    statusCode
  }
}''';

  static const MUTATION_PARTNER_BANK_REMOVE = r'''
mutation removePartnerBankIntegrationMutation($orgId: Int!) {
  removePartnerBankIntegration(orgId: $orgId) {
    status
    redirect
    message
    statusCode
  }
}

''';

  static const MUTATION_DOC_UPLOAD = r'''
mutation uploadReceiptMutation($financeAccountId: String!, $id: Int, $orgId: Int!, $orgIntegrationId: Int!, $sourceDocumentId: String, $secondaryDocumentId: String, $remarks: String, $date: Long, $dueDate: Long, $totalDiscount: BigDecimal, $totalTax: BigDecimal, $buyerOrgCoId: Int, $supplierOrgCoId: Int, $buyerName: String, $SupplierName: String, $totalAmount: BigDecimal, $status: String!, $currencyCode: String!, $isDelivered: Int, $isInvoice: Boolean!, $filesList: [FileUpload!]!, $sourceTransactionId: String) {
  uploadReceipt(
    financeAccountId: $financeAccountId
    id: $id
    orgId: $orgId
    orgIntegrationId: $orgIntegrationId
    sourceDocumentId: $sourceDocumentId
    secondaryDocumentId: $secondaryDocumentId
    remarks: $remarks
    date: $date
    filesList: $filesList
    dueDate: $dueDate
    totalDiscount: $totalDiscount
    totalTax: $totalTax
    buyerOrgCoId: $buyerOrgCoId
    supplierOrgCoId: $supplierOrgCoId
    buyerName: $buyerName
    SupplierName: $SupplierName
    totalAmount: $totalAmount
    status: $status
    currencyCode: $currencyCode
    isDelivered: $isDelivered
    isInvoice: $isInvoice
    sourceTransactionId: $sourceTransactionId
    isExpense: true
  ) {
    isDuplicate
    id
  }
}''';

  static const MUTATION_REMOVE_RECEIPT = r'''
mutation removereceiptMutation($ReceiptId: Int!, $orgId: Int!, $sourceTxnId: String!, $fileId: String!) {
  removeReceipt(
    ReceiptId: $ReceiptId
    orgId: $orgId
    sourceTxnId: $sourceTxnId
    fileId: $fileId
  ) {
    id
  }
}
''';

  static const MUTATION_REVOKE_INVITE = r'''
mutation revokeInviteMutation($id: Int!) {
  revokeInvitation(id: $id) {
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

  static const MUTATION_CHANGE_ROLE = r'''
mutation changeRole($userId: Int!, $orgId: Int!, $role: String!) {
    changeRoleInOrganization(userId: $userId, orgId: $orgId, role: $role)
}''';

  static const MUTATION_DEACTIVE_USER = r'''
mutation deactivateUser($userId: Int!, $orgId: Int!) {
  removeUserFromOrganization(userId: $userId, orgId: $orgId) {
    id
    userId
    email
    firstName
    lastName
    mobile
  }
}

''';

  static const MUTATION_BLOCK_FINANCE_ACCOUNT = r'''
mutation blockFinanceAccount($financeAccountId: String!, $reason: String!, $orgId: Int!) {
  blockFinanceAccount(
    financeAccountId: $financeAccountId
    reason: $reason
    orgId: $orgId
  ) {
    statusCode
    success
    message
  }
}

''';

  static const MUTATION_FINANCE_ACCOUNT_LIMIT = r'''
mutation financeAccountLimitMutation($orgId: Int!, $financeAccountId: String!, $limitValue: BigDecimal!, $controls: Controls) {
  updateFinanceAccountLimit(
    orgId: $orgId
    financeAccountId: $financeAccountId
    limitValue: $limitValue
    controls: $controls
  )
}
''';

  static const MUTATION_CREATE_USER_DEVICE = r'''
mutation createUserDevicesMutation($deviceToken: String!, $enabledNotification: Boolean, $platform: String!, $description: String!, $deviceId: String!){
  createUserDevices(
    deviceToken: $deviceToken,
    enabledNotification: $enabledNotification,
    platform: $platform,
    deviceId: $deviceId,
    description: $description,
  ) {
    success
    statusCode
    message
  }
}''';

  static const MUTATION_ENABLE_DISABLE_NOTIFICATION = r'''
mutation enableDisableNotificationMuation($deviceToken: String!, $enabledNotification: Boolean) {
  enableDisableNotification(
    deviceToken: $deviceToken,
    enabledNotification: $enabledNotification,
  ) {
    success
    statusCode
    message
  }
}''';

  static const MUTATION_ACCEPT_INVITATION = r'''
mutation acceptInvitationMutation($id: Int!) {
  acceptedInvitation: acceptInvitation(id: $id) {
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

  static const MUTATION_UPDATE_COMPANY_NAME = r'''
mutation updateCompanyNameMutation($orgId: Int!, $organizationAlias: String!) {
  updateOrganizationAlias(orgId: $orgId, organizationAlias: $organizationAlias) {
    id
  }
}''';

  static const MUTATION_ADD_REMARK = r'''
mutation addRemarksMutation($sourceTxnId: String!, $ReceiptRemark: String!, $orgId: Int!) {
  addReceiptRemarks(
    orgId: $orgId
    sourceTxnId: $sourceTxnId
    ReceiptRemark: $ReceiptRemark
  ) {
    statusCode
    success
    message
  }
}
''';
}
