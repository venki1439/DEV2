/*******************************************************************************************
Name            : APTS_CERUtility
Created By      : Venky Muppalaneni
Created Date    : 02/14/2018
Description     : This will provide utility methods for processing CER.
Version history : 
Test Class      : APTS_CERUtilityTest
*********************************************************************************************/
public class APTS_CERUtility {
    public static final String PRODUCT_SERVICE = 'Product/Service';
    public static final String AGREE_STATUS_ACTIVATED = 'Activated'; 
    public static final String STANDARD_DEAL = 'Standard Deal';
    public static final String CONSUMPTION_MODEL='Consumptions Model';
    public static final String REGISTRATION_FROM='Registration Form';
    public static final String AGREEMENTOBJECT='Apttus__APTS_Agreement__c';
    
    public class AccountHierarchy
        {
            public Id parentId;
            public Id grandParentId;
            public Id buyingGroupId;
            public Decimal currentLevel;
        }
    public class AccountAgreementHierarchyBottomToTop
        {
            public AccountHierarchy accountHierarchy=new AccountHierarchy();
            public List<Agreement> agreementList=new List<Agreement>();
            public List<Agreement> buyingGroupAgreements = new List<Agreement>();
            public List<Agreement> parentAgreements = new List<Agreement>();
            public List<Agreement> grandParentAgreements = new List<Agreement>();
            public List<Agreement> currentLevelAgreements = new List<Agreement>();
        }
/*  public class AccountAgreementHierarchyTopToBottom
        {
            public Decimal currentLevel;
            public Set<Id> agreementList=new Set<Id>();
            public Map<Id,List<Agreement>> childAgreements = new Map<Id,List<Agreement>>();
            public Map<Id,List<Agreement>> grandChildAgreements = new Map<Id,List<Agreement>>();
            public Map<Id,List<Agreement>> currentLevelAgreements = new Map<Id,List<Agreement>>();
        }
        */
    public class CategoryHierarchy
        {
            Integer level;
            String subSubCategoryId;
            String subCategoryId;
            String categoryId;
        } 
           
    public class Agreement
        {
            public Id agreementId;
            public String agreementType;
        }
    public class AgreementLineItemChargeType
        {
            public Id aliId;
            public String aliChargeType;
        } 
    public class AgreementAdjustmentLineItem
        {
            public String aaliType;
            public String aaliSubType;
        }       
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId)
        {
            if(objectName!=null &&strRecordTypeId!=null )
                {
                    return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
                }
            else 
                {
                    return '';
                }   
            
        } 

    public static Map<Id,AccountHierarchy> getAccountHierarchy(Set<Id> accounts)
        {
            Map<Id,AccountHierarchy> returnObject =new Map<Id,AccountHierarchy>();
            AccountHierarchy ah =new AccountHierarchy();
            for( Account a : [select Id,ParentId,Parent.Name,Ultimate_Parent_Account__c, Parent.Parent.Id,Purchasing_Organization__c from Account where Id in :accounts])
                {
                    ah =new AccountHierarchy();
                    if(a.ParentId==null && a.Parent.Parent.Id==null &&a.Purchasing_Organization__c!=null)
                        {
                             ah.currentLevel=1;
                        }
                    else if(a.Parent.Name==a.Ultimate_Parent_Account__c)
                        {
                            ah.currentLevel=2;
                            ah.parentId=a.ParentId;
                        }
                    else 
                        {
                            ah.currentLevel=3;
                            ah.parentId=a.ParentId;
                            ah.grandParentId=a.Parent.Parent.Id;
                        }
                    if(a.ParentId==null && a.Parent.Parent.Id==null &&a.Purchasing_Organization__c==null)
                        {
                            ah.currentLevel=0;
                        }
                    if(a.Purchasing_Organization__c!=null)
                        {
                            ah.buyingGroupId=a.Purchasing_Organization__c;
                        }
                    returnObject.put(a.Id,ah);  
                }
            return returnObject;
        }
    public static Id getCerRecordAccountForRelatedAccount(Id account)
        {
            Id returnId;
            Set<Id> accountSet =new Set<Id>();
            accountSet.add(account);
            AccountHierarchy ah =getAccountHierarchy(accountSet).get(account);
            List<APTS_Contract_Entitlement_Repository__c> cerList = [select Id,APTS_Sold_to_Party__c from APTS_Contract_Entitlement_Repository__c where APTS_Sold_to_Party__c=:account or APTS_Sold_to_Party__c=:ah.parentId or  APTS_Sold_to_Party__c=:ah.grandParentId or  APTS_Sold_to_Party__c=:ah.buyingGroupId];
            for(APTS_Contract_Entitlement_Repository__c cerRecord:cerList)
                {
                    if(cerRecord.APTS_Sold_to_Party__c==account)
                        {
                          returnId=account;
                          break;
                        }
                    else if(cerRecord.APTS_Sold_to_Party__c==ah.parentId)
                        {
                            returnId=ah.parentId;
                        }
                    else if(cerRecord.APTS_Sold_to_Party__c==ah.grandParentId && returnId!=ah.parentId)
                        {
                            returnId=ah.grandParentId;
                        }
                      else if(cerRecord.APTS_Sold_to_Party__c==ah.buyingGroupId && returnId!=ah.parentId  && returnId!=ah.grandParentId)
                        {
                            returnId=ah.grandParentId;
                        }       
                }
            return returnId;
        }     
    
    public static Map<Id,AccountAgreementHierarchyBottomToTop> getAccountAgreementHierarchyBottomToTop(Set<Id> accounts)
        {
            Map<Id,AccountAgreementHierarchyBottomToTop> returnObject=new Map<Id,AccountAgreementHierarchyBottomToTop>();
            if(accounts==null)
                {
                    return returnObject;
                }
            Agreement agr =new Agreement();
            Set<Id> tempAccountIds =new Set<Id>();
            Map<Id,Set<Id>> accountMap =new Map<Id,Set<Id>>();
            Set<Id> fullAccountIds =new Set<Id>();
            AccountAgreementHierarchyBottomToTop aah =new AccountAgreementHierarchyBottomToTop();
            AccountHierarchy ah = new AccountHierarchy ();
            Map<Id,AccountHierarchy> ahy=getAccountHierarchy(accounts);
            for(Id accountID: accounts)
                {
                    tempAccountIds.clear();
                    aah =new AccountAgreementHierarchyBottomToTop();
                    ah=ahy.get(accountID);
                    if(ah==null)
                        {
                            continue;
                        }
                    aah.accountHierarchy.currentLevel=ah.currentLevel;
                    tempAccountIds.add(accountID);
                    if(!fullAccountIds.contains(accountID))
                        {
                            fullAccountIds.add(accountID);
                        }
                    if(ah.parentId!= null)
                        {
                            tempAccountIds.add(ah.parentId);
                            if(!fullAccountIds.contains(ah.parentId))
                                {
                                    fullAccountIds.add(ah.parentId);
                                }

                        }
                    if(ah.grandParentId!= null)
                        {
                            tempAccountIds.add(ah.grandParentId);
                            if(!fullAccountIds.contains(ah.grandParentId))
                                {
                                    fullAccountIds.add(ah.grandParentId);
                                }
                            
                        }
                    if(ah.buyingGroupId!= null)
                        {
                            tempAccountIds.add(ah.buyingGroupId);
                            if(!fullAccountIds.contains(ah.buyingGroupId))
                                {
                                    fullAccountIds.add(ah.buyingGroupId);
                                }
                            
                        }
                    accountMap.put(accountID,tempAccountIds);   
                }       
            list<Apttus__APTS_Agreement__c> agrActiveList= [SELECT Id,RecordTypeId,Apttus__Account__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Status__c =: AGREE_STATUS_ACTIVATED and Apttus__Account__c in:fullAccountIds];
            //for(Apttus__APTS_Agreement__c agrList:)
            for(Id i:fullAccountIds)
                {
                    aah=new AccountAgreementHierarchyBottomToTop();
                    for(Apttus__APTS_Agreement__c agrList:agrActiveList)
                        {
                            agr =new Agreement();
                            agr.agreementId=agrList.Id;
                            agr.agreementType=getRecordTypeNameById(AGREEMENTOBJECT,agrList.RecordTypeId);
                            if(REGISTRATION_FROM.equalsIgnoreCase(agr.agreementType))
                                {
                                    continue;
                                }
                            ah=ahy.get(i);
                            if(ah==null)
                            continue;
                            aah.accountHierarchy.currentLevel=ah.currentLevel;

                            if(ah.buyingGroupId==agrList.Apttus__Account__c)
                                {
                                    aah.accountHierarchy.buyingGroupId=ah.buyingGroupId;
                                    aah.buyingGroupAgreements.add(agr);
                                    aah.agreementList.add(agr);
                                }
                            
                            if(ah.parentId==agrList.Apttus__Account__c)
                                {
                                    aah.accountHierarchy.parentId=ah.parentId;
                                    aah.parentAgreements.add(agr);
                                    aah.agreementList.add(agr);
                                }
                            if(ah.grandParentId==agrList.Apttus__Account__c)
                                {
                                    aah.accountHierarchy.grandParentId=ah.grandParentId;
                                    aah.grandParentAgreements.add(agr);
                                    aah.agreementList.add(agr);
                                }
                            if(i==agrList.Apttus__Account__c)
                                {
                                    aah.currentLevelAgreements.add(agr);
                                    aah.agreementList.add(agr);
                                }   
                                
                            
                            
                        }  
                    returnObject.put(i,aah);      
                }
                system.debug('$$$$$ returnObject'+returnObject);
            return returnObject;
        }

    /*public static AccountAgreementHierarchyTopToBottom getAccountAgreementHierarchyTopToBottom(Id accountID)
        {
            Agreement agr =new Agreement();
            AccountAgreementHierarchyTopToBottom aah =new AccountAgreementHierarchyTopToBottom();
            AccountHierarchy ah = getAccountHierarchy(accountID);
            list<Agreement> al =new list<Agreement>();
            aah.currentLevel=ah.currentLevel;
            for(Apttus__APTS_Agreement__c agrList:[SELECT Id,RecordTypeId FROM Apttus__APTS_Agreement__c WHERE Apttus__Status__c =: AGREE_STATUS_ACTIVATED and Apttus__Account__c =:accountID])
                {
                    agr =new Agreement();
                    agr.agreementId=agrList.Id;
                    agr.agreementType=getRecordTypeNameById('Apttus__APTS_Agreement__c',agrList.RecordTypeId);
                    al.add(agr);
                    aah.agreementList.add(agrList.Id);
                }
            aah.currentLevelAgreements.put(accountID,al);
            if(aah.currentLevel==1)
                {
                    for(Apttus__APTS_Agreement__c agrList:[SELECT Id,RecordTypeId,Apttus__Account__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Status__c =: AGREE_STATUS_ACTIVATED and Apttus__Account__c in (select Id from account where Parent.Parent.Id = :accountId and ParentId != :accountId)])
                        {
                            al=aah.grandChildAgreements.get(agrList.Apttus__Account__c)==null?new list<Agreement>():aah.grandChildAgreements.get(agrList.Apttus__Account__c);
                            agr =new Agreement();
                            agr.agreementId=agrList.Id;
                            agr.agreementType=getRecordTypeNameById('Apttus__APTS_Agreement__c',agrList.RecordTypeId);
                            al.add(agr);
                            aah.grandChildAgreements.put(agrList.Apttus__Account__c,al);
                            aah.agreementList.add(agrList.Id);
                        }
                    for(Apttus__APTS_Agreement__c agrList:[SELECT Id,RecordTypeId,Apttus__Account__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Status__c =: AGREE_STATUS_ACTIVATED and Apttus__Account__c in (select Id from account where ParentId = :accountId)])
                        {
                            al=aah.childAgreements.get(agrList.Apttus__Account__c)==null?new list<Agreement>():aah.childAgreements.get(agrList.Apttus__Account__c);
                            agr =new Agreement();
                            agr.agreementId=agrList.Id;
                            agr.agreementType=getRecordTypeNameById('Apttus__APTS_Agreement__c',agrList.RecordTypeId);
                            al.add(agr);
                            aah.childAgreements.put(agrList.Apttus__Account__c,al);
                            aah.agreementList.add(agrList.Id);
                        }   
                }
            else if(aah.currentLevel==2)
                {
                    for(Apttus__APTS_Agreement__c agrList:[SELECT Id,RecordTypeId,Apttus__Account__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Status__c =: AGREE_STATUS_ACTIVATED and Apttus__Account__c in (select Id from account where ParentId = :accountId)])
                        {
                            al=aah.childAgreements.get(agrList.Apttus__Account__c)==null?new list<Agreement>():aah.childAgreements.get(agrList.Apttus__Account__c);
                            agr =new Agreement();
                            agr.agreementId=agrList.Id;
                            agr.agreementType=getRecordTypeNameById('Apttus__APTS_Agreement__c',agrList.RecordTypeId);
                            al.add(agr);
                            aah.childAgreements.put(agrList.Apttus__Account__c,al);
                            aah.agreementList.add(agrList.Id);
                        }
                }
            else if(aah.currentLevel==0)
                {

                }       
    
            return aah;
        }*/
    public static List<Apttus__APTS_Agreement__c> getAccountAgreementHierarchyTopToBottom(List<Id> accountId)
        {
            if(accountId!=null)
                {
                    List<Account> a=[select Id,Parent.Parent.Id,Parent.Id,Purchasing_Organization__c from account where ID in :accountId];
                    return new List<Apttus__APTS_Agreement__c>([SELECT Id,RecordTypeId,Apttus__Account__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Status__c =: AGREE_STATUS_ACTIVATED and Apttus__Account__c in : a ]);
                }
            else 
                {
                    return new List<Apttus__APTS_Agreement__c>();       
                }       
            
        }       

/*  public static Map<Id,list<Id>> getContractedProductsForAccountHierarchyTopToBottom(Id accountID)
        {
            AccountAgreementHierarchyTopToBottom aah = getAccountAgreementHierarchyTopToBottom(accountID);
            Map<Id,list<Id>> productsList =new Map<Id,list<Id>>();
            list<Id> tempProductsList =new list<Id>();
            for(Apttus__AgreementLineItem__c aal:[select id,Apttus__AgreementId__c,Apttus_CMConfig__LineType__c,Apttus__ProductId__c,Apttus_CMConfig__OptionId__c from Apttus__AgreementLineItem__c where Apttus__AgreementId__c in:aah.agreementList])
                {
                    tempProductsList=productsList.get(aal.Apttus__AgreementId__c)==null?new list<Id>():productsList.get(aal.Apttus__AgreementId__c);
                    tempProductsList.add(PRODUCT_SERVICE.equalsIgnoreCase(aal.Apttus_CMConfig__LineType__c)?aal.Apttus__ProductId__c:aal.Apttus_CMConfig__OptionId__c);
                    productsList.put(aal.Apttus__AgreementId__c,tempProductsList);
                }
            return productsList;
        }*/
    public static Map<Id,Map<Id,List<AgreementLineItemChargeType>>> getContractedProductsForAgreement(Set<Id> agreements)
    {
        Map<Id,Map<Id,List<AgreementLineItemChargeType>>> contractedProducts=new Map<Id,Map<Id,List<AgreementLineItemChargeType>>>(); 
        Map<Id,List<AgreementLineItemChargeType>> productsList =new Map<Id,List<AgreementLineItemChargeType>>();
        List<AgreementLineItemChargeType> tempIdList =new List<AgreementLineItemChargeType>();
        AgreementLineItemChargeType alic =new AgreementLineItemChargeType();
        Id tempId;
        for(Apttus__AgreementLineItem__c aal:[select id,Apttus__AgreementId__c,Apttus_CMConfig__ChargeType__c,Apttus_CMConfig__LineType__c,Apttus__ProductId__c,Apttus_CMConfig__OptionId__c from Apttus__AgreementLineItem__c where Apttus__AgreementId__c in:agreements])
            {
                productsList =contractedProducts.get(aal.Apttus__AgreementId__c)!=null?contractedProducts.get(aal.Apttus__AgreementId__c):new Map<Id,List<AgreementLineItemChargeType>>();
                tempId=PRODUCT_SERVICE.equalsIgnoreCase(aal.Apttus_CMConfig__LineType__c)?aal.Apttus__ProductId__c:aal.Apttus_CMConfig__OptionId__c;
                tempIdList=productsList.get(tempId)!=null?productsList.get(tempId):new List<AgreementLineItemChargeType>();
                alic=new AgreementLineItemChargeType(); 
                alic.aliId=aal.Id;
                alic.aliChargeType=aal.Apttus_CMConfig__ChargeType__c;
                tempIdList.add(alic);
                productsList.put(tempId,tempIdList);
                contractedProducts.put(aal.Apttus__AgreementId__c,productsList);

            }
           return contractedProducts;
    }
    public static List<Test_GetPrice.GetPriceWrapper> getPrice(Id soldToAccountId,List<Id> productIdList,Integer limitValue,Integer offsetValue)
        {
            Id tempSoldToAccountId=getCerRecordAccountForRelatedAccount(soldToAccountId);
            decimal price=0.0;
            List<Test_GetPrice.GetPriceWrapper> returnObject =new List<Test_GetPrice.GetPriceWrapper>();
            List<Test_GetPrice.GetPriceWrapper> tempReturnObject =new List<Test_GetPrice.GetPriceWrapper>();
            Test_GetPrice.GetPriceWrapper gpw=new Test_GetPrice.GetPriceWrapper();
            List<String> bucketList=new List<String>{'Bucket 1','Bucket 2','Bucket 3','Bucket 4','Bucket 5'};
            Map<String,List<APTS_Contract_Entitlement_Repository__c>> tempGroupByBucket = new Map<String,List<APTS_Contract_Entitlement_Repository__c>>();
            Map<Id,Map<String,List<APTS_Contract_Entitlement_Repository__c>>> productMap = new Map<Id,Map<String,List<APTS_Contract_Entitlement_Repository__c>>>();
            Map<Id,Decimal> productStartPrice=new Map<Id,Decimal>();
            List<APTS_Contract_Entitlement_Repository__c> tempCerRecords= new List<APTS_Contract_Entitlement_Repository__c>();
            List<APTS_Contract_Entitlement_Repository__c> cerRecords =new List<APTS_Contract_Entitlement_Repository__c>();
            if(productIdList.size()>0)
                {
                    cerRecords=[Select id,APTS_Agreement_Line_Item__r.Apttus_CMConfig__BasePriceOverride__c,APTS_Agreement_Line_Item__r.Apttus_CMConfig__BasePrice__c,APTS_Charge_Type__c,APTS_Adjustment_Value__c,APTS_Adjustment_Type__c,APTS_Type__c,APTS_Sub_Type__c,APTS_Adjustment_Applies_To__c,APTS_Bucket__c,APTS_Product__c from APTS_Contract_Entitlement_Repository__c where APTS_Sold_to_Party__c =:tempSoldToAccountId and APTS_Product__c in:productIdList and APTS_Bucket__c != '' and APTS_Is_Pending__c=false ];
                }
            else
                {
                    cerRecords=[Select id,APTS_Agreement_Line_Item__r.Apttus_CMConfig__BasePriceOverride__c,APTS_Agreement_Line_Item__r.Apttus_CMConfig__BasePrice__c,APTS_Charge_Type__c,APTS_Adjustment_Value__c,APTS_Adjustment_Type__c,APTS_Type__c,APTS_Sub_Type__c,APTS_Adjustment_Applies_To__c,APTS_Bucket__c,APTS_Product__c from APTS_Contract_Entitlement_Repository__c where APTS_Sold_to_Party__c =:tempSoldToAccountId  and APTS_Bucket__c != '' and APTS_Is_Pending__c=false ORDER BY CreatedDate ASC];
                }    
            for(APTS_Contract_Entitlement_Repository__c cerRecord:cerRecords)
                {
                    tempGroupByBucket=productMap.get(cerRecord.APTS_Product__c)!=null?productMap.get(cerRecord.APTS_Product__c):new Map<String,List<APTS_Contract_Entitlement_Repository__c>>();
                    tempCerRecords=tempGroupByBucket.get(cerRecord.APTS_Bucket__c)!=null?tempGroupByBucket.get(cerRecord.APTS_Bucket__c):new List<APTS_Contract_Entitlement_Repository__c>();
                    tempCerRecords.add(cerRecord);
                    tempGroupByBucket.put(cerRecord.APTS_Bucket__c,tempCerRecords);
                    productMap.put(cerRecord.APTS_Product__c,tempGroupByBucket);
                    productStartPrice.put(cerRecord.APTS_Product__c,cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__BasePriceOverride__c>0?cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__BasePriceOverride__c:cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__BasePrice__c);
                }
           
            Decimal tempPrice;
            for(Id pId:productMap.keySet())
                {
                    price=productStartPrice.get(pId);
                    if(price>0)
                        {
                            for(String s:bucketList)
                                {
                                    if(productMap.get(pId).get(s)!=null)
                                        {
                                            tempCerRecords=productMap.get(pId).get(s);
                                            tempPrice=0;
                                            for(APTS_Contract_Entitlement_Repository__c c:tempCerRecords)
                                                {
                                                    if(c.APTS_Adjustment_Type__c=='% Discount')
                                                        {
                                                            tempPrice=(tempPrice+(price*(c.APTS_Adjustment_Value__c/100)));
                                                        }
                                                    else if(c.APTS_Adjustment_Type__c=='Discount Amount')
                                                        {
                                                            tempPrice=(tempPrice+c.APTS_Adjustment_Value__c);
                                                        } 
                                                    else if(c.APTS_Adjustment_Type__c=='% Markup')
                                                        {
                                                            tempPrice=(tempPrice-(price*(c.APTS_Adjustment_Value__c/100)));
                                                        }
                                                    else if(c.APTS_Adjustment_Type__c=='Markup Amount')
                                                        {
                                                            tempPrice=(tempPrice-c.APTS_Adjustment_Value__c);
                                                        } 
                                                    else if(c.APTS_Adjustment_Type__c=='Price Override')
                                                        {
                                                            tempPrice=c.APTS_Adjustment_Value__c;
                                                        }
                                                    else continue;             
                                                }
                                            price=price-tempPrice;
                                        }
                                }
                        }
                    gpw =new Test_GetPrice.GetPriceWrapper();
                    gpw.productId=pId;
                    gpw.price=price;
                    tempReturnObject.add(gpw);    
                }  
                if(productIdList.size()>0) 
                    {
                        returnObject.addAll(tempReturnObject);
                    }
                else
                    {
                        Integer lim=tempReturnObject.size()>limitValue?limitValue:tempReturnObject.size();
                        Integer counter=0;
                        for(Integer i=offsetValue-1;counter<lim;i++)
                            {
                                returnObject.add(tempReturnObject[i]);
                                counter++;
                            }

                    }    
            return  returnObject; 
        }
    
    public static List<APTS_Contract_Entitlement_Repository__c> getContractedProductsWithDiscounts(Id soldToAccountId) {
        List<APTS_Contract_Entitlement_Repository__c> cerList = [select Id, Name, APTS_Agreement_Adjustment_Line_Item__c, APTS_Adjustment_Type__c,
                                                                    APTS_Adjustment_Value__c, APTS_Agreement_Line_Item__c, APTS_Category__c,
                                                                    APTS_Category_Level__c, APTS_Contributing_Agreement__c, APTS_Contributing_Agreement_Level__c,
                                                                    APTS_Exclusion_Exception_Available__c, APTS_Max_Volume__c, APTS_Pricing_Sub_Type__c, 
                                                                    APTS_Pricing_Type__c, APTS_Product__c, APTS_Rebate__c, APTS_Sold_to_Party__c, 
                                                                    Total_Cumulative_Consumption_Currency__c, Total_Cumulative_Consumption_Quantity__c,
                                                                    APTS_Adjustment_Applies_To__c,APTS_Type__c,APTS_Sub_Type__c,APTS_Bucket__c,
                                                                    APTS_UOM__c, APTS_Category_Label__c
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :soldToAccountId
                                                                 and APTS_Type__c IN ('PPR','TPR','BMC','BDF','EFF','Promotion')];
        
        return cerList;
    } 
    public static Map<Id,List<APTS_Contract_Entitlement_Repository__c>> getContractedProductsWithDiscounts(Id soldToAccountId, Set<Id> productId) 
        {
        //Modified by Venky
            Map<Id,List<APTS_Contract_Entitlement_Repository__c>> returnObject =new Map<Id,List<APTS_Contract_Entitlement_Repository__c>>();
            List<APTS_Contract_Entitlement_Repository__c> cerList =new List<APTS_Contract_Entitlement_Repository__c>();
            List<APTS_Contract_Entitlement_Repository__c> categoryCerList =new List<APTS_Contract_Entitlement_Repository__c>();
            List<APTS_Contract_Entitlement_Repository__c> tempCerList =new List<APTS_Contract_Entitlement_Repository__c>();
            Set<Id> tempCategorySet =new Set<Id>();
            CategoryHierarchy ch=new CategoryHierarchy();
            Map<Id,CategoryHierarchy> productCategories =new Map<Id,CategoryHierarchy>();
            Id tempSoldToAccountId=getCerRecordAccountForRelatedAccount(soldToAccountId);
            String categoryId,subCategoryId,subSubCategoryId;
            Integer level;
            cerList = [select Id, Name, APTS_Agreement_Adjustment_Line_Item__c, APTS_Adjustment_Type__c,
                                                                        APTS_Adjustment_Value__c, APTS_Agreement_Line_Item__c, APTS_Category__c,
                                                                        APTS_Category_Level__c, APTS_Contributing_Agreement__c, APTS_Contributing_Agreement_Level__c,
                                                                        APTS_Exclusion_Exception_Available__c, APTS_Max_Volume__c, APTS_Pricing_Sub_Type__c, 
                                                                        APTS_Pricing_Type__c, APTS_Product__c, APTS_Rebate__c, APTS_Sold_to_Party__c, 
                                                                        Total_Cumulative_Consumption_Currency__c, Total_Cumulative_Consumption_Quantity__c,
                                                                        APTS_Adjustment_Applies_To__c,APTS_Type__c,APTS_Sub_Type__c,APTS_Bucket__c,
                                                                        APTS_UOM__c,APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Id,APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Apttus_Config2__PrimordialId__c,APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Apttus_Config2__AncestorId__c,APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Apttus_Config2__Level__c
                                                                     from APTS_Contract_Entitlement_Repository__c 
                                                                     where APTS_Sold_to_Party__c = :tempSoldToAccountId
                                                                       and APTS_Product__c in :productId and APTS_Agreement_Adjustment_Line_Item__c!=''];
            if(cerList.size()>0)
                {
                    for(APTS_Contract_Entitlement_Repository__c cerRecord:cerList)
                        {
                            if(!productCategories.containsKey(cerRecord.APTS_Product__c))
                                {
                                    ch=new CategoryHierarchy();
                                    ch.level= Integer.valueOf(cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Apttus_Config2__Level__c);
                                    if(ch.level==0)
                                        {
                                            ch.categoryId=cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Id;
                                        }
                                    else if(ch.level==1)
                                        {
                                            ch.subCategoryId=cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Id;
                                            ch.categoryId=cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Apttus_Config2__PrimordialId__c;
                                        }    
                                    else 
                                        {
                                            ch.subSubCategoryId=cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Id;
                                            ch.subCategoryId=cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Apttus_Config2__AncestorId__c;
                                            ch.categoryId=cerRecord.APTS_Agreement_Line_Item__r.Apttus_CMConfig__ClassificationId__r.Apttus_Config2__PrimordialId__c;
                                        }
                                    if(ch.subSubCategoryId!=null && ch.subSubCategoryId !='' && !(tempCategorySet.contains(ch.subSubCategoryId)))
                                        {
                                            tempCategorySet.add(ch.subSubCategoryId);
                                        }  
                                    if(ch.subCategoryId!=null && ch.subCategoryId !='' && !(tempCategorySet.contains(ch.subCategoryId)))
                                        {
                                            tempCategorySet.add(ch.subCategoryId);
                                        }
                                    if(ch.categoryId!=null && ch.categoryId !='' && !(tempCategorySet.contains(ch.categoryId)))
                                        {
                                            tempCategorySet.add(ch.categoryId);
                                        }          
                                    
                                    productCategories.put(cerRecord.APTS_Product__c,ch);     
                                }
                            else
                                {
                                    continue;
                                }    
                                 
                        }
                    categoryCerList=[select Id, Name, APTS_Agreement_Adjustment_Line_Item__c, APTS_Adjustment_Type__c,APTS_Adjustment_Value__c, APTS_Agreement_Line_Item__c, APTS_Category__c,
                                                                        APTS_Category_Level__c, APTS_Contributing_Agreement__c, APTS_Contributing_Agreement_Level__c,
                                                                        APTS_Exclusion_Exception_Available__c, APTS_Max_Volume__c, APTS_Pricing_Sub_Type__c, 
                                                                        APTS_Pricing_Type__c, APTS_Product__c, APTS_Rebate__c, APTS_Sold_to_Party__c, 
                                                                        Total_Cumulative_Consumption_Currency__c, Total_Cumulative_Consumption_Quantity__c,
                                                                        APTS_Adjustment_Applies_To__c,APTS_Type__c,APTS_Sub_Type__c,APTS_Bucket__c,
                                                                        APTS_UOM__c,APTS_Pending_Line_Item__c,APTS_Pending_Adjustment_Line_Item__c,APTS_CategoryCER__c,APTS_Sub_Category__c,APTS_Sub_Sub_Category__c
                                                                     from APTS_Contract_Entitlement_Repository__c 
                                                                     where APTS_Sold_to_Party__c = :tempSoldToAccountId and APTS_Category_Level__c!=''  and ( APTS_Sub_Sub_Category__c in :tempCategorySet or  APTS_Sub_Category__c in :tempCategorySet or APTS_CategoryCER__c in :tempCategorySet)
                                                                     ORDER BY APTS_Category_Level__c DESC  ]; 
                    if(categoryCerList.size()>0)
                        {
                            boolean check=true;
                            for(Id pID: productCategories.keySet())
                                {
                                    for(APTS_Contract_Entitlement_Repository__c categoryCerRecord:categoryCerList)
                                        {
                                            check=true;
                                            for(APTS_Contract_Entitlement_Repository__c cerRecord:cerList)
                                                {
                                                    if(cerRecord.APTS_Type__c==categoryCerRecord.APTS_Type__c && cerRecord.APTS_Sub_Type__c==categoryCerRecord.APTS_Sub_Type__c )
                                                        {
                                                        check=false; 
                                                        }
                                                }
                                            CategoryHierarchy cch= productCategories.get(pID);   
                                            if(check && cch.categoryId==categoryCerRecord.APTS_CategoryCER__c&& cch.subCategoryId==categoryCerRecord.APTS_Sub_Category__c&& cch.subSubCategoryId==categoryCerRecord.APTS_Sub_Sub_Category__c) 
                                                {
                                                    tempCerList=returnObject.get(pID)!=null?returnObject.get(pID) : new List<APTS_Contract_Entitlement_Repository__c>();
                                                    tempCerList.add(categoryCerRecord);
                                                    returnObject.put(pID,tempCerList);
                                                }   

                                        }
                                }
                        } 
                   /*  tempCerList= new List<APTS_Contract_Entitlement_Repository__c>();     
                    categoryCerList=[select Id, Name, APTS_Agreement_Adjustment_Line_Item__c, APTS_Adjustment_Type__c,APTS_Adjustment_Value__c, APTS_Agreement_Line_Item__c, APTS_Category__c,
                                                                        APTS_Category_Level__c, APTS_Contributing_Agreement__c, APTS_Contributing_Agreement_Level__c,
                                                                        APTS_Exclusion_Exception_Available__c, APTS_Max_Volume__c, APTS_Pricing_Sub_Type__c, 
                                                                        APTS_Pricing_Type__c, APTS_Product__c, APTS_Rebate__c, APTS_Sold_to_Party__c, 
                                                                        Total_Cumulative_Consumption_Currency__c, Total_Cumulative_Consumption_Quantity__c,
                                                                        APTS_Adjustment_Applies_To__c,APTS_Type__c,APTS_Sub_Type__c,APTS_Bucket__c,
                                                                        APTS_UOM__c,APTS_Pending_Line_Item__c,APTS_Pending_Adjustment_Line_Item__c
                                                                     from APTS_Contract_Entitlement_Repository__c 
                                                                     where APTS_Sold_to_Party__c = :tempSoldToAccountId  and APTS_Sub_Category__c=:subCategoryId];  
                    if(categoryCerList.size()>0)
                        {
                            boolean check=true;
                            for(APTS_Contract_Entitlement_Repository__c categoryCerRecord:categoryCerList)
                                {
                                    check=true;
                                    for(APTS_Contract_Entitlement_Repository__c cerRecord:cerList)
                                        {
                                            if(cerRecord.APTS_Type__c==categoryCerRecord.APTS_Type__c && cerRecord.APTS_Sub_Type__c==categoryCerRecord.APTS_Sub_Type__c )
                                                {
                                                   check=false; 
                                                }
                                        }
                                    if(check) 
                                        {
                                            tempCerList.add(categoryCerRecord);
                                        }   

                                }
                            cerList.addAll(tempCerList);  
                        } 
                    tempCerList= new List<APTS_Contract_Entitlement_Repository__c>();     
                    categoryCerList=[select Id, Name, APTS_Agreement_Adjustment_Line_Item__c, APTS_Adjustment_Type__c,APTS_Adjustment_Value__c, APTS_Agreement_Line_Item__c, APTS_Category__c,
                                                                        APTS_Category_Level__c, APTS_Contributing_Agreement__c, APTS_Contributing_Agreement_Level__c,
                                                                        APTS_Exclusion_Exception_Available__c, APTS_Max_Volume__c, APTS_Pricing_Sub_Type__c, 
                                                                        APTS_Pricing_Type__c, APTS_Product__c, APTS_Rebate__c, APTS_Sold_to_Party__c, 
                                                                        Total_Cumulative_Consumption_Currency__c, Total_Cumulative_Consumption_Quantity__c,
                                                                        APTS_Adjustment_Applies_To__c,APTS_Type__c,APTS_Sub_Type__c,APTS_Bucket__c,
                                                                        APTS_UOM__c,APTS_Pending_Line_Item__c,APTS_Pending_Adjustment_Line_Item__c
                                                                     from APTS_Contract_Entitlement_Repository__c 
                                                                     where APTS_Sold_to_Party__c = :tempSoldToAccountId  and APTS_CategoryCER__c=:categoryId]; 
                    if(categoryCerList.size()>0)
                        {
                            boolean check=true;
                            for(APTS_Contract_Entitlement_Repository__c categoryCerRecord:categoryCerList)
                                {
                                    check=true;
                                    for(APTS_Contract_Entitlement_Repository__c cerRecord:cerList)
                                        {
                                            if(cerRecord.APTS_Type__c==categoryCerRecord.APTS_Type__c && cerRecord.APTS_Sub_Type__c==categoryCerRecord.APTS_Sub_Type__c )
                                                {
                                                   check=false; 
                                                }
                                        }
                                    if(check) 
                                        {
                                            tempCerList.add(categoryCerRecord);
                                        }   

                                }
                            cerList.addAll(tempCerList);  
                        }  */                                                          
                }
            return returnObject;
        }
    
    public static List<APTS_Contract_Entitlement_Repository__c> getCategoryProducts(Id soldToAccountId, Id productId, String categoryLevel) {
        List<APTS_Contract_Entitlement_Repository__c> cerList = [select Id, Name, APTS_Agreement_Adjustment_Line_Item__c, APTS_Adjustment_Type__c,
                                                                    APTS_Adjustment_Value__c, APTS_Agreement_Line_Item__c, APTS_Category__c, APTS_Category__r.Name,
                                                                    APTS_Category_Level__c, APTS_Contributing_Agreement__c, APTS_Contributing_Agreement_Level__c,
                                                                    APTS_Exclusion_Exception_Available__c, APTS_Max_Volume__c, APTS_Pricing_Sub_Type__c, 
                                                                    APTS_Pricing_Type__c, APTS_Product__c, APTS_Rebate__c, APTS_Sold_to_Party__c, 
                                                                    Total_Cumulative_Consumption_Currency__c, Total_Cumulative_Consumption_Quantity__c,
                                                                    APTS_Adjustment_Applies_To__c,APTS_Type__c,APTS_Sub_Type__c,APTS_Bucket__c,
                                                                    APTS_UOM__c, APTS_Category_Label__c, APTS_CategoryCER__c, APTS_Sub_Category__c, APTS_Sub_Sub_Category__c 
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :soldToAccountId
                                                                   and APTS_Product__c = :productId
                                                                   and APTS_Category_Level__c = :categoryLevel];
        
        return cerList;
    }
}