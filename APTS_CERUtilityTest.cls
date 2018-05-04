/*******************************************************************************************
Name            : APTS_CERUtilityTest
Created By      : Venky Muppalaneni
Created Date    : 03/15/2018
Description     :This Apex Class is test class for CER which covers APTS_CERUtility.
Version history : 
Test Class      : 
*********************************************************************************************/
@isTest
private class APTS_CERUtilityTest {

    /**
     * This is a test method for getRecordTypeNameById
     */
    APTS_CERUtility aPTS_CERUtility = new APTS_CERUtility();
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
    private static testMethod void test_getRecordTypeNameById()
        {
            Test.startTest();
    		String objectName = 'Apttus__APTS_Agreement__c';
    		Id strRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Standard Deal').getRecordTypeId();
    		String resultGetRecordTypeNameById = APTS_CERUtility.getRecordTypeNameById(objectName,strRecordTypeId);
            Test.stopTest();
        }


    /**
     * This is a test method for getAccountHierarchy
     */
    private static testMethod void test_getAccountHierarchy() 
        {
            Test.startTest();
           
    		Set<Id> accounts = new Set<Id>();
            for(Account a:APTS_TestUtils.getAccounts())
                {
                    accounts.add(a.id);
                }
    		APTS_CERUtility.AccountHierarchy ah =new APTS_CERUtility.AccountHierarchy();
    		Map<Id,APTS_CERUtility.AccountHierarchy> resultGetAccountHierarchy = APTS_CERUtility.getAccountHierarchy(accounts);
            Test.stopTest();
        }


    /**
     * This is a test method for getAccountAgreementHierarchyBottomToTop
     */
    private static testMethod void test_getAccountAgreementHierarchyBottomToTop() 
        {
            Test.startTest();
    		Set<Id> accounts = new Set<Id>();
    		for(Account a:APTS_TestUtils.getAccounts())
                {
                    accounts.add(a.id);
                }
    		APTS_CERUtility.AccountAgreementHierarchyBottomToTop aah=new APTS_CERUtility.AccountAgreementHierarchyBottomToTop();
    		Map<Id,APTS_CERUtility.AccountAgreementHierarchyBottomToTop> resultGetAccountAgreementHierarchyBottomToTop = APTS_CERUtility.getAccountAgreementHierarchyBottomToTop(accounts);
            Test.stopTest();
        }

    /**
     * This is a test method for getAccountAgreementHierarchyTopToBottom
     */
    private static testMethod void test_getAccountAgreementHierarchyTopToBottom() 
        {
            Test.startTest();
    		List<Id> accountId = new List<Id>();
    		for(Account a:APTS_TestUtils.getAccounts())
                {
                    accountId.add(a.id);
                }
    		List<Apttus__APTS_Agreement__c> resultGetAccountAgreementHierarchyTopToBottom = APTS_CERUtility.getAccountAgreementHierarchyTopToBottom(accountId);
            Test.stopTest();
        }

    /**
     * This is a test method for getContractedProductsForAgreement
     */
    private static testMethod void test_getContractedProductsForAgreement() 
        {
            Test.startTest();
    		Set<Id> agreements = new Set<Id>();
    		Apttus__APTS_Agreement__c agreement = APTS_TestUtils.getAgreements();
    		agreements.add(agreement.Id);
    		Map<Id,Map<Id,Id>> resultGetContractedProductsForAgreement = APTS_CERUtility.getContractedProductsForAgreement(agreements);
            Test.stopTest();
         }


    /**
     * This is a test method for getPrice
     */
    private static testMethod void test_getPrice() 
        {
            Test.startTest();
    		Id soldToPartyId = null;
    		APTS_CERUtility.getPrice(soldToPartyId);
            Test.stopTest();
        }

    /**
     * This is a test method for getContractedProductsWithDiscounts
     */
    private static testMethod void test_getContractedProductsWithDiscounts() 
        {
            Test.startTest();
    		Id soldToAccountId = null;
    		List<APTS_Contract_Entitlement_Repository__c> resultGetContractedProductsWithDiscounts = APTS_CERUtility.getContractedProductsWithDiscounts(soldToAccountId);
            Test.stopTest();
        }


    /**
     * This is a test method for all
     */
    private static testMethod void test_all() 
        {
            Test.startTest();
    		String objectName = 'kpqh5ZC';
    		Id strRecordTypeId = null;
    		//  test getRecordTypeNameById
    		String resultGetRecordTypeNameById = APTS_CERUtility.getRecordTypeNameById(objectName,strRecordTypeId);
    		Set<Id> accounts =  null;
    		//  test getAccountHierarchy
    		Map<Id,APTS_CERUtility.AccountHierarchy> resultGetAccountHierarchy = APTS_CERUtility.getAccountHierarchy(accounts);
    		//  test getAccountAgreementHierarchyBottomToTop
    		Map<Id,APTS_CERUtility.AccountAgreementHierarchyBottomToTop> resultGetAccountAgreementHierarchyBottomToTop = APTS_CERUtility.getAccountAgreementHierarchyBottomToTop(accounts);
    		List<Id> accountId =null;
    		//  test getAccountAgreementHierarchyTopToBottom
    		List<Apttus__APTS_Agreement__c> resultGetAccountAgreementHierarchyTopToBottom = APTS_CERUtility.getAccountAgreementHierarchyTopToBottom(accountId);
    		Set<Id> agreements = null;
    		//  test getContractedProductsForAgreement
    		Map<Id,Map<Id,Id>> resultGetContractedProductsForAgreement = APTS_CERUtility.getContractedProductsForAgreement(agreements);
    		Id soldToPartyId = null;
    		//  test getPrice
    		APTS_CERUtility.getPrice(soldToPartyId);
    		Id soldToAccountId = null;
    		//  test getContractedProductsWithDiscounts
    		List<APTS_Contract_Entitlement_Repository__c> resultGetContractedProductsWithDiscounts = APTS_CERUtility.getContractedProductsWithDiscounts(soldToAccountId);
            Test.stopTest();

        }


}