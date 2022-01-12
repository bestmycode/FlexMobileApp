class DefaultLayoutQuery {
  static const DEFAULT_LAYOUT_QUERY = r'''
  query defaultLayout(
    $orgId: Int!
    $isAdmin: Boolean!) {
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
        fxrEnableSpendControl
        organizationAlias
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
        orgOperatingAddress {
          organizationCompanyId
          addressLine1
          addressLine2
          addressLine3
          addressLine4
          postalCode
          city
          country
        }
      }
    }
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
    listUserFinanceAccounts(orgId: $orgId) {
      financeAccounts {
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
        accountSubtype
        financeAccountLimits {
          id
          financeAccountId
          limitType
          limitValue
          controlValue
          utilization
          availableLimit
          status
        }
      }
      listFinanceAccountsStatus {
        statusCode
        success
        message
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
    listCurrencies {
      id
      name
    }
  }
  ''';
}

