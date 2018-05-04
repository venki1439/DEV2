/*******************************************************************************************
Name            : APTS_ManageCERTest
Created By      : Venky Muppalaneni
Created Date    : 03/15/2018
Description     :This Apex Class is test class for CER which covers APTS_ManageCER.
Version history : 
Test Class      : 
*********************************************************************************************/
@isTest
private class APTS_ManageCERTest {

    @testSetup
    private static void testDataSetup() 
        {
            User testuser = APTS_TestUtils.createUser();
            System.runAs(testuser) 
                {
                    Apttus_Config2__ConfigCustomClasses__c configCustomClasses = APTS_TestUtils.getCustomClassSettings();
                    insert configCustomClasses;

                    Contact con= APTS_TestUtils.createContact();
                    insert con;
                    
                    Account grandParentAccount = APTS_TestUtils.createGrandParentAccount();
                    insert grandParentAccount;

                    Account parentAccount = APTS_TestUtils.createParentAccount(grandParentAccount);
                    insert parentAccount;

                    Account childAccount = APTS_TestUtils.createChildAccount(parentAccount);
                    insert childAccount;
                    Opportunity opp = APTS_TestUtils.createOpportunity(childAccount.id);
                    insert opp;
                    
                    Product2 product =APTS_TestUtils.createProduct('Piazza DOro Estremo Bonen 1000 Gram','26940998','Espresso');
                    insert product;
                    
                    Apttus_Config2__ClassificationName__c category = APTS_TestUtils.createCategory();
                    insert category;

                    Apttus_Config2__ClassificationHierarchy__c categoryHierarchy = APTS_TestUtils.createCategoryHierarchy(category.Id);
                    insert categoryHierarchy;

                    Apttus_Config2__ClassificationHierarchy__c subCategoryHierarchy = APTS_TestUtils.createSubCategory(category.Id, categoryHierarchy.Id);
                    insert subCategoryHierarchy;

                    Apttus_Config2__ClassificationHierarchy__c subSubCategoryHierarchy = APTS_TestUtils.createSubSubCategory(category.Id,categoryHierarchy.Id ,subCategoryHierarchy.Id);
                    insert subSubCategoryHierarchy;

                    Apttus_Config2__ProductClassification__c productClassification = APTS_TestUtils.createProductClassification(subCategoryHierarchy.Id, product.id);
                    insert productClassification;

                    Apttus_Config2__ProductClassification__c productClassification1 = APTS_TestUtils.createProductClassification(subCategoryHierarchy.Id, product.id);
                    insert productClassification1;

                    Apttus_Config2__PriceList__c priceList = APTS_TestUtils.createPriceList();
                    insert priceList;
                    
                    Apttus_Config2__PriceListItem__c priceListItem = APTS_TestUtils.createPriceListItem(priceList.id,product.id);
                    insert priceListItem;
                    
                    Apttus_Config2__ProductAttributeGroup__c productAttributeGroup = APTS_TestUtils.createProductAttributeGroup('Apttus_Config2__ProductAttributeValue__c');
                    insert productAttributeGroup;
                    
                    Apttus_Config2__ProductAttribute__c productAttribute = APTS_TestUtils.createProductAttribute('Warranty__c', productAttributeGroup.Id);
                    insert productAttribute;
                    
                    List<Apttus_Config2__PriceDimension__c> listPriceDimensions = APTS_TestUtils.createPriceDimension('priceDimension1', 'Product Attribute', 'Apttus_Config2__ProductAttributeValue__c', 'Warranty__c', productAttribute.Id);
                    insert listPriceDimensions; 
                    
                    Apttus_Config2__PriceMatrix__c priceMatrix = APTS_TestUtils.createPriceMatrix(priceListItem.Id, listPriceDimensions[0].Id);
                    insert priceMatrix;
                    
                    List<Apttus_Config2__PriceMatrixEntry__c> pmeList = APTS_TestUtils.createPriceMatrixEntry(priceMatrix.Id);
                    insert pmeList;

                    Apttus_Proposal__Proposal__c quote = APTS_TestUtils.getQuoteProposal(childAccount.id,opp.Id,'Proposal','Test',priceList.id);
                    insert quote;
                    
                    Apttus_Config2__ProductConfiguration__c config = new Apttus_Config2__ProductConfiguration__c(Name='Sample',Apttus_QPConfig__Proposald__c=quote.id,Apttus_Config2__PriceListId__c=priceList.id);
                    insert config;
                    
                    Apttus_Config2__LineItem__c lineItem = APTS_TestUtils.getConfigLineItem(config.id, null, 1, true, 2, '', product.id, false, null,product.id, null, '', 2.3, false, '', 1, priceList.id, priceListItem.Id, '', '', 'Sales Price', '',false, false, 22.00, 24.00, '', 34.00, 23.00, 33.50, '');
                    insert lineItem;
                    
                    Apttus_Proposal__Proposal_Line_Item__c propLineItem = APTS_TestUtils.getProposalLineItem(quote.Id,lineItem.Id,priceListItem.Id,product.Id,product.Id);
                    insert propLineItem;
                    
                    Apttus__APTS_Agreement__c agreement = APTS_TestUtils.createAgreement(con.Id,quote.Id, priceList.Id, childAccount.Id);
                    agreement.Apttus__Status__c = 'Activated';
                    insert agreement;
                    
                    Apttus_Config2__ProductConfiguration__c agreementCart = new Apttus_Config2__ProductConfiguration__c(Name='Sample',Apttus_CMConfig__AgreementId__c=agreement.id,Apttus_Config2__PriceListId__c=priceList.id);
                    agreementCart.Apttus_Config2__BusinessObjectType__c = 'Agreement';
                    insert agreementCart;

                    List<Apttus__AgreementLineItem__c> agreementLineItems = APTS_TestUtils.createAgreementLineItem(product.Id, agreement.Id, childAccount.Id, lineItem, priceListItem.Id,subCategoryHierarchy.Id);
                    insert agreementLineItems;


                    List<APTS_Adjustments__c> adjustmentLineItems = APTS_TestUtils.getAdjustmentLineItems(agreement.Id, categoryHierarchy.Id, subCategoryHierarchy.Id,subSubCategoryHierarchy.Id , childAccount.id, priceListItem.Id);
                    insert adjustmentLineItems;
                }

        }
    /**
     * This is a test method for updateCERForAgreementExpiration
     */
    private static testMethod void test_updateCERForAgreementExpiration() 
        {
            Test.startTest();
            List<Id> agreementIdList = new List<Id>();
            Apttus__APTS_Agreement__c agreement = APTS_TestUtils.getAgreements();
            agreementIdList.add(agreement.Id);
            APTS_ManageCER.updateCERForAgreementExpiration(agreementIdList);
            Test.stopTest();
        }


    /**
     * This is a test method for updateCERForAdjustmentExpiration
     */
    private static testMethod void test_updateCERForAdjustmentExpiration() 
        {
            Test.startTest();
            List<Id> adjustmentLineIdList = null;
            APTS_ManageCER.updateCERForAdjustmentExpiration(adjustmentLineIdList);
            Test.stopTest();
        }


    /**
     * This is a test method for excludeAccountFromAgreement
     */
    private static testMethod void test_excludeAccountFromAgreement() 
        {
            Test.startTest();
            Id agreementId = null;
            List<Id> accountIdList = new List<Id>();
            Apttus__APTS_Agreement__c agreement = APTS_TestUtils.getAgreements();
            agreementId=agreement.Id;
            for(Account a:APTS_TestUtils.getAccounts())
                {
                    accountIdList.add(a.id);
                }
            APTS_ManageCER.excludeAccountFromAgreement(agreementId,accountIdList);
            Test.stopTest();
        }


    /**
     * This is a test method for excludeAccountFromAgreementLineItem
     */
    private static testMethod void test_excludeAccountFromAgreementLineItem() 
        {
            Test.startTest();
            Id agreementId = null;
            Id agreementLineItemId = null;
            List<Id> accountIdList = new List<Id>();
            Apttus__APTS_Agreement__c agreement = APTS_TestUtils.getAgreements();
            agreementId=agreement.Id;
            Apttus__AgreementLineItem__c agreementLineItem =APTS_TestUtils.getAgreementLineItems(agreementId);
            agreementLineItemId=agreementLineItem.Id;
            for(Account a:APTS_TestUtils.getAccounts())
                {
                    accountIdList.add(a.id);
                }
            APTS_ManageCER.excludeAccountFromAgreementLineItem(agreementId,agreementLineItemId,accountIdList);
            Test.stopTest();
        }


    /**
     * This is a test method for excludeExceptionForAccountFromAgreementLineItem
     */
    private static testMethod void test_excludeExceptionForAccountFromAgreementLineItem() 
        {
            Test.startTest();
            Id agreementId = null;
            Id agreementLineItemId = null;
            List<Id> accountIdList = new List<Id>();
            Apttus__APTS_Agreement__c agreement = APTS_TestUtils.getAgreements();
            agreementId=agreement.Id;
            Apttus__AgreementLineItem__c agreementLineItem =APTS_TestUtils.getAgreementLineItems(agreementId);
            agreementLineItemId=agreementLineItem.Id;
            for(Account a:APTS_TestUtils.getAccounts())
                {
                    accountIdList.add(a.id);
                }
            APTS_ManageCER.excludeExceptionForAccountFromAgreementLineItem(agreementId,agreementLineItemId,accountIdList);
            Test.stopTest();
        }


    /**
     * This is a test method for excludeAccountFromAdjustments
     */
    private static testMethod void test_excludeAccountFromAdjustments() {

        // PageReference pageRef = Page.APTS_ManageCER;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        Id agreementId = null;
        Id agreementLineItemId = null;
        List<Id> agreementAdjustmentLineItemId = null;
        List<Id> accountIdList = null;
        APTS_ManageCER.excludeAccountFromAdjustments(agreementId,agreementLineItemId,agreementAdjustmentLineItemId,accountIdList);


        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for getCERDataForAccount
     */
    private static testMethod void test_getCERDataForAccount() 
        {
            Test.startTest();
            Id accountId = null;
            for(Account a:APTS_TestUtils.getAccounts())
                {
                    accountId=a.id;
                    break;
                }
            List<APTS_Contract_Entitlement_Repository__c> resultGetCERDataForAccount = APTS_ManageCER.getCERDataForAccount(accountId);
            Test.stopTest();
        }


    /**
     * This is a test method for getCERDataForAgreement
     */
    private static testMethod void test_getCERDataForAgreement() 
        {
            Test.startTest();
            Id agreementId = null;
            Apttus__APTS_Agreement__c agreement = APTS_TestUtils.getAgreements();
            agreementId=agreement.Id;
            List<APTS_Contract_Entitlement_Repository__c> resultGetCERDataForAgreement = APTS_ManageCER.getCERDataForAgreement(agreementId);
            Test.stopTest();
        }


    /**
     * This is a test method for deleteAccountFromBuyingGroup
     */
    private static testMethod void test_deleteAccountFromBuyingGroup() {

        // PageReference pageRef = Page.APTS_ManageCER;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        Id accountId = null;
        Id buyingGroupAccountId = null;
        APTS_ManageCER.deleteAccountFromBuyingGroup(accountId,buyingGroupAccountId);


        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for addAccountToBuyingGroup
     */
    private static testMethod void test_addAccountToBuyingGroup() {

        // PageReference pageRef = Page.APTS_ManageCER;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        Id accountId = null;
        Id buyingGroupAccountId = null;
        APTS_ManageCER.addAccountToBuyingGroup(accountId,buyingGroupAccountId);


        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for deleteCERDataForAccount
     */
    private static testMethod void test_deleteCERDataForAccount() 
        {
            Test.startTest();
            Id accountId = null;
            for(Account a:APTS_TestUtils.getAccounts())
                {
                    accountId=a.id;
                    break;
                }
            APTS_ManageCER.deleteCERDataForAccount(accountId);
            Test.stopTest();
        }


    /**
     * This is a test method for getHierarchyAccountIdList
     */
    private static testMethod void test_getHierarchyAccountIdList() 
        {
            Test.startTest();
            Id accountId = null;
            for(Account a:APTS_TestUtils.getAccounts())
                {
                    accountId=a.id;
                    break;
                }
            List<Id> resultGetHierarchyAccountIdList = APTS_ManageCER.getHierarchyAccountIdList(accountId,'');
            Test.stopTest();
        }


    /**
     * This is a test method for isBuyingGroup
     */
    private static testMethod void test_isBuyingGroup() {

        // PageReference pageRef = Page.APTS_ManageCER;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        Id accountId = null;
        boolean resultIsBuyingGroup = APTS_ManageCER.isBuyingGroup(accountId);


        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for getRelatedBuyingGroupAccounts
     */
    private static testMethod void test_getRelatedBuyingGroupAccounts() {

        // PageReference pageRef = Page.APTS_ManageCER;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        Id buyingGroupAccountId = null;
        List<Account> resultGetRelatedBuyingGroupAccounts = APTS_ManageCER.getRelatedBuyingGroupAccounts(buyingGroupAccountId);


        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for manageCERRecords
     */
    private static testMethod void test_manageCERRecords() 
        {
            Test.startTest();
            List<Apttus__APTS_Agreement__c> agreements = new List<Apttus__APTS_Agreement__c>();
            Apttus__APTS_Agreement__c agreement = APTS_TestUtils.getAgreements();
            agreements.add(agreement);
            string triggerPoint = 'Agreement';
            string dmlOperation = 'Update';
            APTS_ManageCER.manageCERRecords(agreements,triggerPoint,dmlOperation);
            triggerPoint = 'Agreement';
            dmlOperation = 'Insert';
            APTS_ManageCER.manageCERRecords(agreements,triggerPoint,dmlOperation);
            Test.stopTest();
        }


    /**
     * This is a test method for excludedItemsFromTwoAgreements
     */
    private static testMethod void test_excludedItemsFromTwoAgreements() {

        // PageReference pageRef = Page.APTS_ManageCER;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        List<APTS_CERUtility.Agreement> childAgreements = null;
        List<APTS_CERUtility.Agreement> parentAgreements = null;
        Map<Id,Map<Id,Id>>  contractedProducts = null;
        Map<Id,List<Id>> resultExcludedItemsFromTwoAgreements = APTS_ManageCER.excludedItemsFromTwoAgreements(childAgreements,parentAgreements,contractedProducts);


        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for excludedItemsFromThreeAgreements
     */
    private static testMethod void test_excludedItemsFromThreeAgreements() {

        // PageReference pageRef = Page.APTS_ManageCER;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        List<APTS_CERUtility.Agreement> childAgreements = null;
        List<APTS_CERUtility.Agreement> parentAgreements = null;
        List<APTS_CERUtility.Agreement> grandParentAgreements = null;
        Map<Id,Map<Id,Id> >  contractedProducts = null;
        Map<Id,List<Id>> resultExcludedItemsFromThreeAgreements = APTS_ManageCER.excludedItemsFromThreeAgreements(childAgreements,parentAgreements,grandParentAgreements,contractedProducts);


        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for excludedItemsFromFourAgreements
     */
    private static testMethod void test_excludedItemsFromFourAgreements() {

        // PageReference pageRef = Page.APTS_ManageCER;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        List<APTS_CERUtility.Agreement> childAgreements = null;
        List<APTS_CERUtility.Agreement> parentAgreements = null;
        List<APTS_CERUtility.Agreement> grandParentAgreements = null;
        List<APTS_CERUtility.Agreement> buyingGroupAgreements = null;
        Map<Id,Map<Id,Id> >  contractedProducts = null;
        Map<Id,List<Id>> resultExcludedItemsFromFourAgreements = APTS_ManageCER.excludedItemsFromFourAgreements(childAgreements,parentAgreements,grandParentAgreements,buyingGroupAgreements,contractedProducts);


        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


    /**
     * This is a test method for excludedItemsFromAgreements
     */
    private static testMethod void test_excludedItemsFromAgreements() 
        {
            Test.startTest();
            Map<Id,Map<Id,List<Id>>> toBeExcluded = new Map<Id,Map<Id,List<Id>>>();
            Map<Id,Set<Id>> resultExcludedItemsFromAgreements = APTS_ManageCER.excludedItemsFromAgreements(toBeExcluded);
            Test.stopTest();
        }


    /**
     * This is a test method for all
     */
    private static testMethod void test_all() {

        // PageReference pageRef = Page.APTS_ManageCER;
        // Test.setCurrentPage(pageRef);
        // pageRef.getParameters().put('param1', 'param1');

        Test.startTest();

        List<Id> agreementIdList = null;
        //  test updateCERForAgreementExpiration
        APTS_ManageCER.updateCERForAgreementExpiration(agreementIdList);

        List<Id> adjustmentLineIdList = null;
        //  test updateCERForAdjustmentExpiration
        APTS_ManageCER.updateCERForAdjustmentExpiration(adjustmentLineIdList);

        Id agreementId = null;
        List<Id> accountIdList = null;
        //  test excludeAccountFromAgreement
        APTS_ManageCER.excludeAccountFromAgreement(agreementId,accountIdList);

        Id agreementLineItemId = null;
        //  test excludeAccountFromAgreementLineItem
        APTS_ManageCER.excludeAccountFromAgreementLineItem(agreementId,agreementLineItemId,accountIdList);

        //  test excludeExceptionForAccountFromAgreementLineItem
        APTS_ManageCER.excludeExceptionForAccountFromAgreementLineItem(agreementId,agreementLineItemId,accountIdList);

        List<Id> agreementAdjustmentLineItemId = null;
        //  test excludeAccountFromAdjustments
        APTS_ManageCER.excludeAccountFromAdjustments(agreementId,agreementLineItemId,agreementAdjustmentLineItemId,accountIdList);

        Id accountId = null;
        //  test getCERDataForAccount
        List<APTS_Contract_Entitlement_Repository__c> resultGetCERDataForAccount = APTS_ManageCER.getCERDataForAccount(accountId);

        //  test getCERDataForAgreement
        List<APTS_Contract_Entitlement_Repository__c> resultGetCERDataForAgreement = APTS_ManageCER.getCERDataForAgreement(agreementId);

        Id buyingGroupAccountId = null;
        //  test deleteAccountFromBuyingGroup
        APTS_ManageCER.deleteAccountFromBuyingGroup(accountId,buyingGroupAccountId);

        //  test addAccountToBuyingGroup
        APTS_ManageCER.addAccountToBuyingGroup(accountId,buyingGroupAccountId);

        //  test deleteCERDataForAccount
        APTS_ManageCER.deleteCERDataForAccount(accountId);

        //  test getHierarchyAccountIdList
        List<Id> resultGetHierarchyAccountIdList = APTS_ManageCER.getHierarchyAccountIdList(accountId,'');
        //  test isBuyingGroup
        boolean resultIsBuyingGroup = APTS_ManageCER.isBuyingGroup(accountId);

        //  test getRelatedBuyingGroupAccounts
        List<Account> resultGetRelatedBuyingGroupAccounts = APTS_ManageCER.getRelatedBuyingGroupAccounts(buyingGroupAccountId);

        List<Apttus__APTS_Agreement__c> agreements = null;
        string triggerPoint = 'mFUCo9c';
        string dmlOperation = 'Oq42yAl';
        //  test manageCERRecords
        APTS_ManageCER.manageCERRecords(agreements,triggerPoint,dmlOperation);

        List<APTS_CERUtility.Agreement> childAgreements = null;
        List<APTS_CERUtility.Agreement> parentAgreements = null;
        List<APTS_CERUtility.Agreement> grandParentAgreements = null;
        List<APTS_CERUtility.Agreement> buyingGroupAgreements = null;
        Map<Id,Map<Id,Id> >  contractedProducts = null;
        //  test excludedItemsFromTwoAgreements
        Map<Id,List<Id>> resultExcludedItemsFromTwoAgreements = APTS_ManageCER.excludedItemsFromTwoAgreements(childAgreements,parentAgreements,contractedProducts);

    
        //  test excludedItemsFromThreeAgreements
        Map<Id,List<Id>> resultExcludedItemsFromThreeAgreements = APTS_ManageCER.excludedItemsFromThreeAgreements(childAgreements,parentAgreements,grandParentAgreements,contractedProducts);

    
        
      
        //  test excludedItemsFromFourAgreements
        Map<Id,List<Id>> resultExcludedItemsFromFourAgreements = APTS_ManageCER.excludedItemsFromFourAgreements(childAgreements,parentAgreements,grandParentAgreements,buyingGroupAgreements,contractedProducts);

        Map<Id,Map<Id,List<Id> > > toBeExcluded = null;
        //  test excludedItemsFromAgreements
        Map<Id,Set<Id>> resultExcludedItemsFromAgreements = APTS_ManageCER.excludedItemsFromAgreements(toBeExcluded);


        Test.stopTest();

        // Check
        // System.assert(ApexPages.hasMessages());
        // for(ApexPages.Message msg : ApexPages.getMessages()) {
        //     System.assertEquals('Upload file is NULL', msg.getSummary());
        //     System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
        // }
    }


}