/**
 * This will Manage Contract Entitlement Repository
 *
 **/
public class APTS_ManageCER  {
    public static final String PRODUCT_SERVICE = 'Product/Service';
    public static final String STANDARD_DEAL = 'Standard Deal';
    public static final String CONSUMPTION_MODEL='Consumption Model';
    public static final String REGISTRATION_FROM='Registration Form';
    public static final String BUYING_GROUP = 'Buying Group';
    public static final String GRAND_PARENT = 'Grandparent';
    public static final String PARENT = 'Parent';
    public static final String CHILD = 'Child';
    public static final String AGREEMENT = 'Agreement';
    public static final String ACCOUNT = 'Account';
    public static final String DMLINSERT = 'Insert';
    public static final String DMLUPDATE = 'Update';
    public static final String DMLDELETE = 'Delete';
    //Delete Contributing agreement records on agreement expiration
    //This should be called from batch which checks for agreement expiration
    //Added by Shravan
    public static void updateCERForAgreementExpiration(List<Id> agreementIdList) 
        {
            if(agreementIdList!=null)
                {
                    List<APTS_Contract_Entitlement_Repository__c> cerList = [select Name, APTS_Contributing_Agreement__c from APTS_Contract_Entitlement_Repository__c where APTS_Contributing_Agreement__c = :agreementIdList];
            
                     if (cerList.size() > 0) 
                        {
                            delete cerList;
                        }
                }
        }
    
    //Delete Contributing agreement records on agreement adjustments expiration
    //This should be called from batch which checks for agreement adjustments expiration    
    //Added by Shravan
    public static void updateCERForAdjustmentExpiration(List<Id> adjustmentLineIdList) {
        if(adjustmentLineIdList!=null)
        {
        List<APTS_Contract_Entitlement_Repository__c> cerList = [select Name, APTS_Contributing_Agreement__c 
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Agreement_Adjustment_Line_Item__c = :adjustmentLineIdList];
        
        if (cerList.size() > 0) {
            delete cerList;
        }
    }
    }
    
    //Delete Contributing agreement records for excluded accounts
    //This should be called from Exclusion Accounts for agreement page
    //Added by Shravan
    public static void excludeAccountFromAgreement(Id agreementId, List<Id> accountIdList) {
        if(agreementId!=null&&accountIdList!=null)
        {
        List<APTS_Contract_Entitlement_Repository__c> cerList = [select Name, APTS_Contributing_Agreement__c 
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :accountIdList 
                                                                 and APTS_Contributing_Agreement__c = :agreementId];
        
        if (cerList.size() > 0) {
            delete cerList;
        }
         }
    }
    
    //Delete agreement line item records for an agreementfor excluded accounts
    //This should be called from Exclusion of Accounts for agreement line item
    //Added by Shravan
    public static void excludeAccountFromAgreementLineItem(Id agreementId, Id agreementLineItemId, List<Id> accountIdList) {
        if(agreementId!=null&&accountIdList!=null && agreementLineItemId!=null )
        {
        List<APTS_Contract_Entitlement_Repository__c> cerList = [select Name, APTS_Contributing_Agreement__c 
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :accountIdList 
                                                                 and APTS_Agreement_Line_Item__c = :agreementLineItemId 
                                                                 and APTS_Contributing_Agreement__c = :agreementId];
        
        if (cerList.size() > 0) {
            delete cerList;
        }
    }
    }
    
    
    public static void excludeExceptionForAccountFromAgreementLineItem(Id agreementId, Id agreementLineItemId, List<Id> accountIdList) {
        if(agreementId!=null && agreementLineItemId!=null && accountIdList!=null)
        {
        List<APTS_Contract_Entitlement_Repository__c> cerList = [select Name, APTS_Contributing_Agreement__c, APTS_Exclusion_Exception_Available__c
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :accountIdList 
                                                                 and APTS_Agreement_Line_Item__c = :agreementLineItemId 
                                                                 and APTS_Contributing_Agreement__c = :agreementId];
        
        for (APTS_Contract_Entitlement_Repository__c cer : cerList) {
            cer.APTS_Exclusion_Exception_Available__c = true;
        }
        
        if (cerList.size() > 0) {
            update cerList;
        }
    }
    }
    
    //Delete agreement adjustment line item records for an agreement for excluded accounts
    //This should be called from Exclusion of Accounts for agreement adjustment line item
    //Added by Shravan
    public static void excludeAccountFromAdjustments(Id agreementId, Id agreementLineItemId, List<Id> agreementAdjustmentLineItemId, List<Id> accountIdList) {
        if(agreementId!=null&&agreementLineItemId!=null&&agreementAdjustmentLineItemId!=null&&accountIdList!=null)
        {
        List<APTS_Contract_Entitlement_Repository__c> cerList = [select Name, APTS_Contributing_Agreement__c 
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :accountIdList 
                                                                 and APTS_Agreement_Line_Item__c = :agreementLineItemId 
                                                                 and APTS_Agreement_Adjustment_Line_Item__c = :agreementAdjustmentLineItemId 
                                                                 and APTS_Contributing_Agreement__c = :agreementId];
        
        if (cerList.size() > 0) {
            delete cerList;
        }
        }
    }
    
    //Added By Shravan
    //Get CER Data for a sold to party account
    public static List<APTS_Contract_Entitlement_Repository__c> getCERDataForAccount(Id accountId) {
        List<APTS_Contract_Entitlement_Repository__c> cerList = [select APTS_Sold_to_Party__c, APTS_Contributing_Agreement__c, APTS_Contributing_Agreement__r.Name,
                                                                        APTS_Agreement_Line_Item__c, APTS_Product__c, APTS_Product__r.Name,
                                                                        APTS_Agreement_Adjustment_Line_Item__c,APTS_Sold_to_Party__r.Name , APTS_Adjustment_Type__c, APTS_Adjustment_Value__c,
                                                                        APTS_Type__c, APTS_Sub_Type__c, APTS_UOM__c
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :accountId];
        
        return cerList;
    }
    
    //Added By Shravan
    //Get CER data for agreement
    public static List<APTS_Contract_Entitlement_Repository__c> getCERDataForAgreement(Id agreementId) {
        List<APTS_Contract_Entitlement_Repository__c> cerList = [select APTS_Sold_to_Party__c,APTS_Sold_to_Party__r.Name , APTS_Contributing_Agreement__c, APTS_Contributing_Agreement__r.Name,
                                                                        APTS_Agreement_Line_Item__c, APTS_Product__c, APTS_Product__r.Name,
                                                                        APTS_Agreement_Adjustment_Line_Item__c, APTS_Adjustment_Type__c, APTS_Adjustment_Value__c, APTS_Type__c, APTS_Sub_Type__c, APTS_UOM__c
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Contributing_Agreement__c = :agreementId];
        
        return cerList;
    }
    
    //Added By Shravan
    //If an account is removed from buying group - remove CER data for the account related to Buying group
    //This is called from a trigger 
    public static void deleteAccountFromBuyingGroup(Id accountId, Id buyingGroupAccountId) {
         //Get buying group agreement info
         List<APTS_Contract_Entitlement_Repository__c> bgCERList = [select Id, Name, APTS_Contributing_Agreement__c 
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :buyingGroupAccountId];
        if (bgCERList.size() > 0) {
            Id agreementId = bgCERList.get(0).Id;
            List<APTS_Contract_Entitlement_Repository__c> cerList = [select Name, APTS_Contributing_Agreement__c 
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :accountId
                                                                 and APTS_Contributing_Agreement__c = :agreementId];
              
            if (cerList.size() > 0) {
                delete cerList;
            }
        }
    }
    
    //Added By Shravan
    //If an account is added to buying group - add CER data for the account related to Buying group
    //This is called from a trigger 
    public static void addAccountToBuyingGroup(Id accountId, Id buyingGroupAccountId) {
         //Get buying group agreement info
         APTS_Contract_Entitlement_Repository__c newCER;
         List<APTS_Contract_Entitlement_Repository__c> bgCERList = [select Id, Name, APTS_Agreement_Adjustment_Line_Item__c, APTS_Adjustment_Type__c,
                                                                    APTS_Adjustment_Value__c, APTS_Agreement_Line_Item__c, APTS_Category__c,
                                                                    APTS_Category_Level__c, APTS_Contributing_Agreement__c, APTS_Contributing_Agreement_Level__c,
                                                                    APTS_Exclusion_Exception_Available__c, APTS_Max_Volume__c, APTS_Pricing_Sub_Type__c, 
                                                                    APTS_Pricing_Type__c, APTS_Product__c, APTS_Rebate__c, APTS_Sold_to_Party__c, 
                                                                    Total_Cumulative_Consumption_Currency__c, Total_Cumulative_Consumption_Quantity__c, 
                                                                    APTS_UOM__c
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :buyingGroupAccountId];
        if (bgCERList.size() > 0) {
            Id agreementId = bgCERList.get(0).Id;
            List<APTS_Contract_Entitlement_Repository__c> cerList = new List<APTS_Contract_Entitlement_Repository__c>();
            for (APTS_Contract_Entitlement_Repository__c cer : bgCERList) {
                newCER = new APTS_Contract_Entitlement_Repository__c();
                newCER.APTS_Agreement_Adjustment_Line_Item__c = cer.APTS_Agreement_Adjustment_Line_Item__c;
                newCER.APTS_Adjustment_Type__c = cer.APTS_Adjustment_Type__c;
                newCER.APTS_Adjustment_Value__c = cer.APTS_Adjustment_Value__c;
                newCER.APTS_Category__c = cer.APTS_Category__c;
                newCER.APTS_Category_Level__c = cer.APTS_Category_Level__c;
                newCER.APTS_Contributing_Agreement__c = cer.APTS_Contributing_Agreement__c;
                newCER.APTS_Contributing_Agreement_Level__c = cer.APTS_Contributing_Agreement_Level__c; //This needs to be identified
                newCER.APTS_Exclusion_Exception_Available__c = cer.APTS_Exclusion_Exception_Available__c;
                newCER.APTS_Max_Volume__c = cer.APTS_Max_Volume__c;
                newCER.APTS_Pricing_Sub_Type__c = cer.APTS_Pricing_Sub_Type__c;
                newCER.APTS_Pricing_Type__c = cer.APTS_Pricing_Type__c;
                newCER.APTS_Product__c = cer.APTS_Product__c;
                newCER.APTS_Rebate__c = cer.APTS_Rebate__c;
                newCER.APTS_Sold_to_Party__c = accountId;
                newCER.Total_Cumulative_Consumption_Currency__c = cer.Total_Cumulative_Consumption_Currency__c;
                newCER.Total_Cumulative_Consumption_Quantity__c = cer.Total_Cumulative_Consumption_Quantity__c;
                newCER.APTS_UOM__c = cer.APTS_UOM__c;
                
                cerList.add(newCER);
            }
              
            if (cerList.size() > 0) {
                insert cerList;
            }
        }
    }
    
    //Added By Shravan
    //If an account is removed/terminated/cancelled - remove CER data for the account 
    //This is called from a trigger 
    public static void deleteCERDataForAccount(Id accountId) {
         //Get buying group agreement info
         List<APTS_Contract_Entitlement_Repository__c> cerList = [select Id, Name, APTS_Contributing_Agreement__c 
                                                                 from APTS_Contract_Entitlement_Repository__c 
                                                                 where APTS_Sold_to_Party__c = :accountId];
         if (cerList.size() > 0) {
                delete cerList;
         }        
    }
    
    //Added by Shravan
    //This should get all hierarchial accounts looking down
    //For Grand parent, get parent and child list
    //For Parent, get all child accounts
    //For Child - nothing
    public static List<Id> getHierarchyAccountIdList(Id accountId, String Name) {
        List<Id> accountIdList = new List<Id>();
        
        List<Account> gpList = [select Id, Ultimate_Parent_Account__c from account where Id = :accountId and Ultimate_Parent_Account__c = :Name];
        
        if (gpList.size() > 0) { //Got GP account find parent and child
            List<Account> pList = [select Id, ParentId from account where ParentId = :accountId]; //Parent account list
             if (pList.size() > 0) {//get child accounts
                 for (Account pAccount : pList) {
                     accountIdList.add(pAccount.Id);
                 }
                 List<Account> cList = [select Id, ParentId from account where ParentId = :accountIdList]; //Child account list
                 if (cList.size() > 0) {
                     for (Account cAccount : cList) {
                        accountIdList.add(cAccount.Id);
                    }
                 }
             }

        } else {            
            List<Account> cList = [select Id, ParentId from account where ParentId = :accountIdList]; //Child account list
            if (cList.size() > 0) {
               for (Account cAccount : cList) {
                    accountIdList.add(cAccount.Id);
               }
            }
         }
        
        return accountIdList;
        
    }
    
    //Added By Shravan
    //Check if account is buying group account
    public static boolean isBuyingGroup(Id accountId) {
        boolean isBuyingGroup = false;
        List<Account> accountList = [select Purchase_Organization__c from account where Id = :accountId];
        if (accountList.size() > 0 && accountList.get(0).Purchase_Organization__c) {
            isBuyingGroup = true;
        }
        return isBuyingGroup;
    }
    
    //Added By Shravan
    //Get all accounts that are associated with buying group
    //Using Related_Caterer__c field as I dont see Related_BuyingGroup__c
    public static List<Account> getRelatedBuyingGroupAccounts(Id buyingGroupAccountId) {
       List<Account> accountList = [select Id, Name from account where Purchasing_Organization__c = :buyingGroupAccountId]; 
        
        return accountList;
    }

    ///Added by venky
    // Used for Insert,Delete and Update the CER Records
    /* EXAMPLE 
        List<Apttus__APTS_Agreement__c> agreements =new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c a=new Apttus__APTS_Agreement__c();
        a.Id='a014E00000EOQM9';
        a.Apttus__Account__c='0014E00000msury';
        agreements.add(a);  
        APTS_ManageCER.manageCERRecords(agreements,'Agreement','Insert');
        APTS_ManageCER.manageCERRecords(agreements,'Account','Update');
    */

    public static void manageCERRecords(List<Apttus__APTS_Agreement__c> agreements,string triggerPoint,string dmlOperation)
        {
            if(agreements!=null && triggerPoint !=null && dmlOperation !=null)
                {
                    APTS_CERUtility.AccountAgreementHierarchyBottomToTop hierarchy =new APTS_CERUtility.AccountAgreementHierarchyBottomToTop();
                    List<Apttus__APTS_Agreement__c> hierachyAgreements=new List<Apttus__APTS_Agreement__c>();
                    List<Id>accountList=new List<Id>();
                    Map<Id,String>agreementMap=new  Map<Id,String>();
                    Set<Id> tempAgreementSet =new Set<Id>();
                    Map<Id,Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>> contractedProducts=new Map<Id,Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>>();
                    Set<Id> agreementLineItemsSet =new Set<Id>();
                    Map<Id,Set<Id>> aliMap=new  Map<Id,Set<Id>>();
                    Set<Id> excludeSet =new Set<Id>();
                    Map<Id,APTS_CERUtility.AccountAgreementHierarchyBottomToTop> hierarchyMap =new Map<Id,APTS_CERUtility.AccountAgreementHierarchyBottomToTop>();
                    Map<Id,Map<Id,List<Id>>> excludedItemsByAccount=new Map<Id,Map<Id,List<Id>>>();
                    List<APTS_Contract_Entitlement_Repository__c> insertCERList=new  List<APTS_Contract_Entitlement_Repository__c>();
                    ID tempAccountId= null;
                    APTS_Contract_Entitlement_Repository__c cerRecord=new APTS_Contract_Entitlement_Repository__c();


                    if(AGREEMENT.equalsIgnoreCase(triggerPoint) && DMLINSERT.equalsIgnoreCase(dmlOperation))
                        {
                            hierachyAgreements.addAll(agreements);
                        }
                    else 
                        {
                            for(Apttus__APTS_Agreement__c a :agreements)
                            {
                                accountList.add(a.Apttus__Account__c);
                            }
                            hierachyAgreements.addAll(agreements);
                            hierachyAgreements.addAll(APTS_CERUtility.getAccountAgreementHierarchyTopToBottom(accountList));
                        }
                    if(!DMLDELETE.equalsIgnoreCase(dmlOperation)) 
                        {
                            accountList.clear();
                        }       
                    for(Apttus__APTS_Agreement__c a :hierachyAgreements)
                        {
                            
                            if(!tempAgreementSet.contains(a.Apttus__Account__c))
                                {
                                    tempAgreementSet.add(a.Apttus__Account__c);
                                }
                        } 
                    hierarchyMap= APTS_CERUtility.getAccountAgreementHierarchyBottomToTop(tempAgreementSet); 
                    tempAgreementSet.clear();   
                    for(Id h:hierarchyMap.keySet()) 
                        {
                            for(APTS_CERUtility.Agreement a:hierarchyMap.get(h).agreementList)
                                {
                                    if(!tempAgreementSet.contains(a.agreementId))
                                        {
                                           tempAgreementSet.add(a.agreementId);
                                        }
                                }
                        }
                    contractedProducts=APTS_CERUtility.getContractedProductsForAgreement(tempAgreementSet);
                    tempAgreementSet.clear();
                    for(Apttus__APTS_Agreement__c a :hierachyAgreements)
                        {
                            if(a.Apttus__Account__c!=null)
                                {
                                    if(tempAgreementSet.contains(a.Id))
                                        {
                                            continue;
                                        }
                                    tempAgreementSet.add(a.Id);
                                    hierarchy=hierarchyMap.get(a.Apttus__Account__c);
                                    for(APTS_CERUtility.agreement ca: hierarchy.agreementList)
                                        {
                                            agreementMap.put(ca.agreementId,ca.agreementType);
                                        } 
                                    if((hierarchy.grandParentAgreements.size()>0 && 
                                        hierarchy.parentAgreements.size()==0 && 
                                        hierarchy.currentLevelAgreements.size()==0 && 
                                        hierarchy.buyingGroupAgreements.size()==0)
                                        || 
                                        (hierarchy.parentAgreements.size()>0 && 
                                        hierarchy.grandParentAgreements.size()==0 && 
                                        hierarchy.currentLevelAgreements.size()==0 && 
                                        hierarchy.buyingGroupAgreements.size()==0) 
                                        || 
                                        (hierarchy.currentLevelAgreements.size()>0 &&
                                        hierarchy.parentAgreements.size()==0 && 
                                        hierarchy.grandParentAgreements.size()==0 &&
                                        hierarchy.buyingGroupAgreements.size()==0)
                                        || 
                                        (hierarchy.currentLevelAgreements.size()==0 &&
                                        hierarchy.parentAgreements.size()==0 && 
                                        hierarchy.grandParentAgreements.size()==0 && 
                                        hierarchy.buyingGroupAgreements.size()>0))
                                        {
                                           continue;
                                        } 
                                    else  if(hierarchy.currentLevelAgreements.size()>0)
                                        {
                                            if(hierarchy.buyingGroupAgreements.size()>0 && hierarchy.grandParentAgreements.size()==0&&hierarchy.parentAgreements.size()==0)
                                                {
                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromTwoAgreements(hierarchy.currentLevelAgreements,hierarchy.buyingGroupAgreements,contractedProducts));
                                                }
                                            else if(hierarchy.buyingGroupAgreements.size()==0 && hierarchy.grandParentAgreements.size()>0&&hierarchy.parentAgreements.size()==0)
                                                {
                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromTwoAgreements(hierarchy.currentLevelAgreements,hierarchy.grandParentAgreements,contractedProducts));
                                                }    
                                            else if(hierarchy.buyingGroupAgreements.size()==0 && hierarchy.grandParentAgreements.size()==0&&hierarchy.parentAgreements.size()>0)
                                                {
                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromTwoAgreements(hierarchy.currentLevelAgreements,hierarchy.parentAgreements,contractedProducts));
                                                } 
                                            else if(hierarchy.buyingGroupAgreements.size()>0 && hierarchy.grandParentAgreements.size()==0&&hierarchy.parentAgreements.size()>0)
                                                {
                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromThreeAgreements(hierarchy.currentLevelAgreements,hierarchy.parentAgreements,hierarchy.buyingGroupAgreements,contractedProducts));
                                                } 
                                            else if(hierarchy.buyingGroupAgreements.size()>0 && hierarchy.grandParentAgreements.size()>0&&hierarchy.parentAgreements.size()==0)
                                                {
                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromThreeAgreements(hierarchy.currentLevelAgreements,hierarchy.grandParentAgreements,hierarchy.buyingGroupAgreements,contractedProducts));
                                                } 
                                            else if(hierarchy.buyingGroupAgreements.size()==0 && hierarchy.grandParentAgreements.size()>0&&hierarchy.parentAgreements.size()>0)
                                                {
                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromThreeAgreements(hierarchy.currentLevelAgreements,hierarchy.parentAgreements,hierarchy.grandParentAgreements,contractedProducts));
                                                } 
                                            else 
                                                {

                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromFourAgreements(hierarchy.currentLevelAgreements,hierarchy.parentAgreements,hierarchy.grandParentAgreements,hierarchy.buyingGroupAgreements,contractedProducts));           
                                                }                 
                                        }
                                    else if(hierarchy.parentAgreements.size()>0)   
                                        {
                                            if(hierarchy.buyingGroupAgreements.size()>0 && hierarchy.grandParentAgreements.size()==0)
                                                {
                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromTwoAgreements(hierarchy.parentAgreements,hierarchy.buyingGroupAgreements,contractedProducts));
                                                }
                                            else if(hierarchy.buyingGroupAgreements.size()==0 && hierarchy.grandParentAgreements.size()>0)
                                                {
                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromTwoAgreements(hierarchy.parentAgreements,hierarchy.grandParentAgreements,contractedProducts));
                                                }    
                                            else 
                                                {
                                                    excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromThreeAgreements(hierarchy.parentAgreements,hierarchy.grandParentAgreements,hierarchy.buyingGroupAgreements,contractedProducts));
                                                } 
                                        }
                                    else     
                                        {   
                                           excludedItemsByAccount.put(a.Apttus__Account__c,excludedItemsFromTwoAgreements(hierarchy.grandParentAgreements,hierarchy.buyingGroupAgreements,contractedProducts));
                                            
                                        } 
                                        
                                }
                        } 

                    aliMap= excludedItemsFromAgreements(excludedItemsByAccount); 

                    List<Apttus_CMConfig__AgreementAdjustmentLineItem__c> temp=
                    [
                        select id,Apttus_CMConfig__Type__c,Apttus_CMConfig__SubType__c,Apttus_CMConfig__AdjustmentType__c,Apttus_CMConfig__AdjustmentAmount__c,Apttus_CMConfig__Bucket__c,Apttus_CMConfig__AdjustmentAppliesTo__c,Apttus_CMConfig__LineItemId__r.id,Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__SubType__c,Apttus_CMConfig__LineItemId__r.Apttus__ProductId__c,Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__OptionId__c,Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__LineType__c,Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__PriceUom__c,Apttus_CMConfig__LineItemId__r.Apttus__AgreementId__r.Apttus__Account__c,Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__IncentiveId__c,
                        Apttus_CMConfig__LineItemId__r.APTS_Category_Level__c,Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__ClassificationId__c,Apttus_CMConfig__LineItemId__r.APTS_Sub_Category__c,Apttus_CMConfig__LineItemId__r.APTS_Sub_Sub_Category__c,Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__ChargeType__c
                        from Apttus_CMConfig__AgreementAdjustmentLineItem__c 
                        where Apttus_CMConfig__LineItemId__r.Apttus__AgreementId__c in:agreementMap.keySet()
                    ];
                    List<Apttus__AgreementLineItem__c> temp1=
                    [
                        select id,Apttus_CMConfig__Type__c,Apttus_CMConfig__SubType__c,Apttus__ProductId__c,Apttus_CMConfig__OptionId__c,Apttus_CMConfig__LineType__c,Apttus_CMConfig__PriceUom__c,Apttus__AgreementId__r.Apttus__Account__c,Apttus_CMConfig__IncentiveId__c,APTS_Category_Level__c,Apttus_CMConfig__ClassificationId__c,APTS_Sub_Category__c,APTS_Sub_Sub_Category__c,Apttus_CMConfig__ChargeType__c
                        from Apttus__AgreementLineItem__c 
                        where Apttus__AgreementId__c in:agreementMap.keySet()
                    ];

                    for(Apttus__APTS_Agreement__c a :hierachyAgreements)
                        {                     
                            excludeSet= aliMap.get(a.Apttus__Account__c)!=null?aliMap.get(a.Apttus__Account__c):new Set<Id>();
                            
                            for(Apttus_CMConfig__AgreementAdjustmentLineItem__c aali:temp)
                                {
                                    if(excludeSet.contains(aali.Id))
                                        {
                                             continue;
                                        }
                                     if(!agreementLineItemsSet.contains(aali.Apttus_CMConfig__LineItemId__r.Id))
                                        {
                                            agreementLineItemsSet.add(aali.Apttus_CMConfig__LineItemId__r.Id);
                                        }   
                                    tempAccountId= aali.Apttus_CMConfig__LineItemId__r.Apttus__AgreementId__r.Apttus__Account__c; 
                                    cerRecord =new APTS_Contract_Entitlement_Repository__c();
                                    cerRecord.APTS_Agreement_Adjustment_Line_Item__c=aali.ID;
                                    cerRecord.APTS_Adjustment_Type__c=aali.Apttus_CMConfig__AdjustmentType__c;
                                    cerRecord.APTS_Adjustment_Value__c=aali.Apttus_CMConfig__AdjustmentAmount__c;
                                    cerRecord.APTS_Contributing_Agreement__c=aali.Apttus_CMConfig__LineItemId__r.Apttus__AgreementId__c;
                                    cerRecord.APTS_Agreement_Type__c=agreementMap.get(aali.Apttus_CMConfig__LineItemId__r.Apttus__AgreementId__c);
                                    cerRecord.APTS_Contributing_Agreement_Level__c=tempAccountId==hierarchy.accountHierarchy.buyingGroupId?BUYING_GROUP:tempAccountId==hierarchy.accountHierarchy.grandParentId?GRAND_PARENT:tempAccountId==hierarchy.accountHierarchy.parentId?PARENT:CHILD;
                                    cerRecord.APTS_Agreement_Line_Item__c=aali.Apttus_CMConfig__LineItemId__r.Id;
                                    cerRecord.APTS_Type__c=aali.Apttus_CMConfig__Type__c;
                                    cerRecord.APTS_Sub_Type__c=aali.Apttus_CMConfig__SubType__c;
                                    cerRecord.APTS_Adjustment_Applies_To__c =aali.Apttus_CMConfig__AdjustmentAppliesTo__c;
                                    cerRecord.APTS_Bucket__c=aali.Apttus_CMConfig__Bucket__c;
                                    cerRecord.APTS_Product__c=PRODUCT_SERVICE.equalsIgnoreCase(aali.Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__LineType__c)?aali.Apttus_CMConfig__LineItemId__r.Apttus__ProductId__c:aali.Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__OptionId__c;
                                    cerRecord.APTS_Rebate__c=aali.Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__IncentiveId__c;
                                    cerRecord.APTS_UOM__c=aali.Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__PriceUom__c;
                                    cerRecord.APTS_Sold_to_Party__c=a.Apttus__Account__c;
                                    cerRecord.APTS_Category_Level__c=aali.Apttus_CMConfig__LineItemId__r.APTS_Category_Level__c;
                                    cerRecord.APTS_CategoryCER__c=aali.Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__ClassificationId__c;
                                    cerRecord.APTS_Sub_Category__c=aali.Apttus_CMConfig__LineItemId__r.APTS_Sub_Category__c;
                                    cerRecord.APTS_Sub_Sub_Category__c=aali.Apttus_CMConfig__LineItemId__r.APTS_Sub_Sub_Category__c;
                                    cerRecord.APTS_Charge_Type__c=aali.Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__ChargeType__c;
                                    cerRecord.APTS_Is_Pending__c=(AGREEMENT.equalsIgnoreCase(triggerPoint) && DMLINSERT.equalsIgnoreCase(dmlOperation))?true:false;
                                    insertCERList.add(cerRecord); 
                                    accountList.add(a.Apttus__Account__c);                               
                                }
                        }   
                    Id tempProductID;  
                    Map<Id,String> agreementLineItemType =new Map<Id,String>();
                    for(Apttus__APTS_Agreement__c a :hierachyAgreements)
                        {           
                            agreementLineItemType =new Map<Id,String>(); 
                            for(Apttus__AgreementLineItem__c ali:temp1)
                                {
                                    if(agreementLineItemsSet.contains(ali.Id))
                                        {
                                            continue;
                                        }
                                    tempProductID=PRODUCT_SERVICE.equalsIgnoreCase(ali.Apttus_CMConfig__LineType__c)?ali.Apttus__ProductId__c:ali.Apttus_CMConfig__OptionId__c;    
                                    /* if(agreementLineItemType.containsKey(tempProductID) && agreementLineItemType.get(tempProductID)==ali.Apttus_CMConfig__ChargeType__c)
                                        {
                                            system.debug('*** tempProductID *** '+tempProductID+' *** Apttus_CMConfig__ChargeType__c ****'+ ali.Apttus_CMConfig__ChargeType__c );
                                            continue;
                                        }    
                                    system.debug('true');     */
                                    agreementLineItemType.put(tempProductID,ali.Apttus_CMConfig__ChargeType__c);
                                    tempAccountId= ali.Apttus__AgreementId__r.Apttus__Account__c; 
                                    cerRecord =new APTS_Contract_Entitlement_Repository__c();
                                    cerRecord.APTS_Contributing_Agreement__c=ali.Apttus__AgreementId__c;
                                    cerRecord.APTS_Agreement_Type__c=agreementMap.get(ali.Apttus__AgreementId__c);
                                    cerRecord.APTS_Contributing_Agreement_Level__c=tempAccountId==hierarchy.accountHierarchy.buyingGroupId?BUYING_GROUP:tempAccountId==hierarchy.accountHierarchy.grandParentId?GRAND_PARENT:tempAccountId==hierarchy.accountHierarchy.parentId?PARENT:CHILD;
                                    cerRecord.APTS_Agreement_Line_Item__c=ali.Id;
                                    cerRecord.APTS_Type__c=ali.Apttus_CMConfig__Type__c;
                                    cerRecord.APTS_Sub_Type__c=ali.Apttus_CMConfig__SubType__c;
                                    cerRecord.APTS_Product__c=tempProductID;
                                    cerRecord.APTS_Rebate__c=ali.Apttus_CMConfig__IncentiveId__c;
                                    cerRecord.APTS_UOM__c=ali.Apttus_CMConfig__PriceUom__c;
                                    cerRecord.APTS_Sold_to_Party__c=a.Apttus__Account__c;
                                    cerRecord.APTS_Is_Pending__c=(AGREEMENT.equalsIgnoreCase(triggerPoint) && DMLINSERT.equalsIgnoreCase(dmlOperation))?true:false;
                                    cerRecord.APTS_Category_Level__c=ali.APTS_Category_Level__c;
                                    cerRecord.APTS_CategoryCER__c=ali.Apttus_CMConfig__ClassificationId__c;
                                    cerRecord.APTS_Sub_Category__c=ali.APTS_Sub_Category__c;
                                    cerRecord.APTS_Sub_Sub_Category__c=ali.APTS_Sub_Sub_Category__c;
                                    cerRecord.APTS_Charge_Type__c=ali.Apttus_CMConfig__ChargeType__c;
                                    insertCERList.add(cerRecord); 
                                    accountList.add(a.Apttus__Account__c);                               
                                }    
         
                        }  
                   

                    delete [select Id from APTS_Contract_Entitlement_Repository__c where APTS_Sold_to_Party__c in:accountList];    
                    insert insertCERList;
                   
                }
        }
  

    ///Added by venky
    // Get the list of adjustment line item that need to exclude from two agreements
    public static Map<Id,List<Id>> excludedItemsFromTwoAgreements(List<APTS_CERUtility.Agreement> childAgreements ,List<APTS_CERUtility.Agreement> parentAgreements,Map<Id,Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>> contractedProducts)
        {
            Map<Id,List<Id>> agreementRelatedLineItemMap =new Map<Id,List<Id>>();
            if(childAgreements!=null && parentAgreements!=null && contractedProducts != null)
                {
                    Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>> childProducts =new Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>();
                    Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>> parentProducts =new Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>();
                    List<Id> tempId =new List<Id>();
                    for(APTS_CERUtility.Agreement ca:childAgreements)
                        {
                            for(APTS_CERUtility.Agreement pa:parentAgreements)
                                { 
                                    if((STANDARD_DEAL.equalsIgnoreCase(ca.agreementType) && STANDARD_DEAL.equalsIgnoreCase(pa.agreementType))||(CONSUMPTION_MODEL.equalsIgnoreCase(ca.agreementType) && CONSUMPTION_MODEL.equalsIgnoreCase(pa.agreementType)))
                                        {
                                            childProducts=contractedProducts.get(ca.agreementId);
                                            parentProducts=contractedProducts.get(pa.agreementId);
                                           

                                            if(parentProducts != null && childProducts != null)
                                                {
                                                    for(Id i:childProducts.keySet())
                                                        {
                                                            if(parentProducts.keySet().contains(i))
                                                                {   
                                                                    for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                        {
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                {
                                                                                    if(calict.aliChargeType==palict.aliChargeType)
                                                                                        {
                                                                                            tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                            tempId.add(palict.aliId);
                                                                                            agreementRelatedLineItemMap.put(calict.aliId,tempId);

                                                                                        }
                                                                                }
                                                                        }
                                                                    
                                                                }
                                                            else continue;    
                                                       }
                                                }       
                                        }       
                                    else continue;  
                                }
                        }
                    
                }
            return agreementRelatedLineItemMap;   
         
        } 

    ///Added by venky
    // Get the list of adjustment line item that need to exclude from three agreements   
    public static Map<Id,List<Id>> excludedItemsFromThreeAgreements(List<APTS_CERUtility.Agreement> childAgreements ,List<APTS_CERUtility.Agreement> parentAgreements,List<APTS_CERUtility.Agreement> grandParentAgreements,Map<Id,Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>> contractedProducts)
        {
            Map<Id,List<Id>> agreementRelatedLineItemMap =new Map<Id,List<Id>>();
            if(childAgreements!=null && parentAgreements!=null&& grandParentAgreements!=null && contractedProducts != null)
                {
                    Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>> childProducts =new Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>();
                    Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>> parentProducts =new Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>();
                    Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>> grandParentProducts =new Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>();
                    List<Id> tempId =new List<Id>();

                    for(APTS_CERUtility.Agreement ca:childAgreements)
                        {
                            for(APTS_CERUtility.Agreement pa:parentAgreements)
                                {
                                    for(APTS_CERUtility.Agreement ga:grandParentAgreements)
                                        { 
                                            if((STANDARD_DEAL.equalsIgnoreCase(ca.agreementType) && STANDARD_DEAL.equalsIgnoreCase(pa.agreementType) && STANDARD_DEAL.equalsIgnoreCase(ga.agreementType))||(CONSUMPTION_MODEL.equalsIgnoreCase(ca.agreementType) && CONSUMPTION_MODEL.equalsIgnoreCase(pa.agreementType)&& CONSUMPTION_MODEL.equalsIgnoreCase(ga.agreementType)))
                                                {
                                                    childProducts=contractedProducts.get(ca.agreementId);
                                                    parentProducts=contractedProducts.get(pa.agreementId);
                                                    grandParentProducts=contractedProducts.get(ga.agreementId);
                                                    if(parentProducts != null && grandParentProducts != null && childProducts != null){
                                                        for(Id i:childProducts.keySet())
                                                            {
                                                                //Issue: if(parentProducts.keySet().contains(i) && !(grandParentProducts.keySet().contains(i)))
                                                                if(parentProducts.containsKey(i) && !(grandParentProducts.containsKey(i)))
                                                                    {   
                                                                        for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                    {
                                                                                        if(calict.aliChargeType==palict.aliChargeType)
                                                                                            {
                                                                                                tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                tempId.add(palict.aliId);
                                                                                                agreementRelatedLineItemMap.put(calict.aliId,tempId);

                                                                                            }
                                                                                    }
                                                                            }
                                                                    }
                                                                //Issue: else if(grandParentProducts.keySet().contains(i) && !(parentProducts.keySet().contains(i)))
                                                                else if(grandParentProducts.containsKey(i) && !(parentProducts.containsKey(i)))
                                                                    {   
                                                                        for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                    {
                                                                                        if(calict.aliChargeType==galict.aliChargeType)
                                                                                            {
                                                                                                tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                tempId.add(galict.aliId);
                                                                                                agreementRelatedLineItemMap.put(calict.aliId,tempId);

                                                                                            }
                                                                                    }
                                                                            }
                                                                    }
                                                                //Issue: else if(grandParentProducts.keySet().contains(i) && parentProducts.keySet().contains(i))
                                                                else if(grandParentProducts.containsKey(i) && parentProducts.containsKey(i))
                                                                    {   
                                                                        for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                    {
                                                                                        for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                            {
                                                                                                if(palict.aliChargeType==galict.aliChargeType && calict.aliChargeType==galict.aliChargeType)
                                                                                                    {
                                                                                                        tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                        tempId.add(palict.aliId);
                                                                                                        tempId.add(galict.aliId);
                                                                                                        agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                                    }
                                                                                            }
                                                                                        
                                                                                    }
                                                                            }
                                                                        for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                    {
                                                                                        if(palict.aliChargeType==galict.aliChargeType)
                                                                                            {
                                                                                                tempId =agreementRelatedLineItemMap.get(palict.aliId)!=null?agreementRelatedLineItemMap.get(palict.aliId):new List<Id>();
                                                                                                tempId.add(galict.aliId);
                                                                                                agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                            }
                                                                                    }
                                                                            }

                                                                        
                                                                    }     

                                                                else continue;    
                                                            }
                                                        for(Id i:parentProducts.keySet())
                                                            {
                                                                if(grandParentProducts.keySet().contains(i) && !(childProducts.keySet().contains(i)))
                                                                    {   
                                                                        for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                    {
                                                                                        if(palict.aliChargeType==galict.aliChargeType)
                                                                                            {
                                                                                                tempId =agreementRelatedLineItemMap.get(palict.aliId)!=null?agreementRelatedLineItemMap.get(palict.aliId):new List<Id>();
                                                                                                tempId.add(galict.aliId);
                                                                                                agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                            }
                                                                                    }
                                                                            }
                                                                    }
                                                                else continue;    
                                                            }
                                                    }   
                                                } 

                                            else continue;  
                                        }
                                }
                        }
                }
            return agreementRelatedLineItemMap;
        }

    ///Added by venky
    // Get the list of adjustment line item that need to exclude from four agreements    
    public static Map<Id,List<Id>> excludedItemsFromFourAgreements(List<APTS_CERUtility.Agreement> childAgreements ,List<APTS_CERUtility.Agreement> parentAgreements ,List<APTS_CERUtility.Agreement> grandParentAgreements,List<APTS_CERUtility.Agreement> buyingGroupAgreements,Map<Id,Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>> contractedProducts)
        {
            Map<Id,List<Id>> agreementRelatedLineItemMap =new Map<Id,List<Id>>();
            if(childAgreements!=null && parentAgreements!=null&& grandParentAgreements!=null && contractedProducts != null&&buyingGroupAgreements!=null)
                {
                    Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>> childProducts =new Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>();
                    Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>> parentProducts =new Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>();
                    Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>> grandParentProducts =new Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>();
                    Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>> buyingGroupProducts =new Map<Id,List<APTS_CERUtility.AgreementLineItemChargeType>>();
                    List<Id> tempId =new List<Id>();
                    for(APTS_CERUtility.Agreement ca:childAgreements)
                        {
                            for(APTS_CERUtility.Agreement pa:parentAgreements)
                                {
                                    for(APTS_CERUtility.Agreement ga:grandParentAgreements)
                                        {
                                            for(APTS_CERUtility.Agreement ba:buyingGroupAgreements)
                                                { 
                                                    if((STANDARD_DEAL.equalsIgnoreCase(ca.agreementType) && STANDARD_DEAL.equalsIgnoreCase(pa.agreementType) && STANDARD_DEAL.equalsIgnoreCase(ga.agreementType)&&STANDARD_DEAL.equalsIgnoreCase(ba.agreementType))||(CONSUMPTION_MODEL.equalsIgnoreCase(ca.agreementType) && CONSUMPTION_MODEL.equalsIgnoreCase(pa.agreementType)&& CONSUMPTION_MODEL.equalsIgnoreCase(ga.agreementType) && CONSUMPTION_MODEL.equalsIgnoreCase(ba.agreementType)))
                                                        {
                                                            childProducts=contractedProducts.get(ca.agreementId);
                                                            parentProducts=contractedProducts.get(pa.agreementId);
                                                            grandParentProducts=contractedProducts.get(ga.agreementId);
                                                            buyingGroupProducts=contractedProducts.get(ba.agreementId);
                                                            for(Id i:childProducts.keySet())
                                                                {
                                                                    if(parentProducts.keySet().contains(i) && !(grandParentProducts.keySet().contains(i))&& !(buyingGroupProducts.keySet().contains(i)))
                                                                        {   
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                        {
                                                                                            if(calict.aliChargeType==palict.aliChargeType)
                                                                                                {
                                                                                                    tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                    tempId.add(palict.aliId);
                                                                                                    agreementRelatedLineItemMap.put(calict.aliId,tempId);

                                                                                                }
                                                                                        }
                                                                                }
                                                                        }
                                                                    else if(grandParentProducts.keySet().contains(i) && !(parentProducts.keySet().contains(i))&& !(buyingGroupProducts.keySet().contains(i)))
                                                                        {   
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                        {
                                                                                            if(calict.aliChargeType==galict.aliChargeType)
                                                                                                {
                                                                                                    tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                    tempId.add(galict.aliId);
                                                                                                    agreementRelatedLineItemMap.put(calict.aliId,tempId);

                                                                                                }
                                                                                        }
                                                                                }
                                                                        }
                                                                    else if(buyingGroupProducts.keySet().contains(i) && !(parentProducts.keySet().contains(i))&& !(grandParentProducts.keySet().contains(i)))
                                                                        {   
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                        {
                                                                                            if(calict.aliChargeType==balict.aliChargeType)
                                                                                                {
                                                                                                    tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                    tempId.add(balict.aliId);
                                                                                                    agreementRelatedLineItemMap.put(calict.aliId,tempId);

                                                                                                }
                                                                                        }
                                                                                }
                                                                          
                                                                        }
                                                                    else if(grandParentProducts.keySet().contains(i) && parentProducts.keySet().contains(i)&& !(buyingGroupProducts.keySet().contains(i)))
                                                                        {   
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                    {
                                                                                        for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                            {
                                                                                                if(palict.aliChargeType==galict.aliChargeType && calict.aliChargeType==galict.aliChargeType)
                                                                                                    {
                                                                                                        tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                        tempId.add(palict.aliId);
                                                                                                        tempId.add(galict.aliId);
                                                                                                        agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                                    }
                                                                                            }
                                                                                        
                                                                                    }
                                                                            }
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                    {
                                                                                        if(palict.aliChargeType==galict.aliChargeType)
                                                                                            {
                                                                                                tempId =agreementRelatedLineItemMap.get(palict.aliId)!=null?agreementRelatedLineItemMap.get(palict.aliId):new List<Id>();
                                                                                                tempId.add(galict.aliId);
                                                                                                agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                            }
                                                                                    }
                                                                            }
                                                                        }
                                                                    else if(grandParentProducts.keySet().contains(i) && buyingGroupProducts.keySet().contains(i)&& !(parentProducts.keySet().contains(i)))
                                                                        {   
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                    {
                                                                                        for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                            {
                                                                                                if(balict.aliChargeType==galict.aliChargeType && calict.aliChargeType==galict.aliChargeType)
                                                                                                    {
                                                                                                        tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                        tempId.add(balict.aliId);
                                                                                                        tempId.add(galict.aliId);
                                                                                                        agreementRelatedLineItemMap.put(calict.aliId,tempId);

                                                                                                    }
                                                                                            }
                                                                                        
                                                                                    }
                                                                            }
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                    {
                                                                                        if(balict.aliChargeType==galict.aliChargeType)
                                                                                            {
                                                                                                tempId =agreementRelatedLineItemMap.get(galict.aliId)!=null?agreementRelatedLineItemMap.get(galict.aliId):new List<Id>();
                                                                                                tempId.add(balict.aliId);
                                                                                                agreementRelatedLineItemMap.put(galict.aliId,tempId);

                                                                                            }
                                                                                    }
                                                                            }
                                                                        }  
                                                                    else if(parentProducts.keySet().contains(i) && buyingGroupProducts.keySet().contains(i)&& !(grandParentProducts.keySet().contains(i)))
                                                                        {   
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                    {
                                                                                        for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                            {
                                                                                                if(palict.aliChargeType==balict.aliChargeType && calict.aliChargeType==balict.aliChargeType)
                                                                                                    {
                                                                                                        tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                        tempId.add(balict.aliId);
                                                                                                        tempId.add(palict.aliId);
                                                                                                        agreementRelatedLineItemMap.put(calict.aliId,tempId);

                                                                                                    }
                                                                                            }
                                                                                        
                                                                                    }
                                                                            }
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                    {
                                                                                        if(balict.aliChargeType==palict.aliChargeType)
                                                                                            {
                                                                                                tempId =agreementRelatedLineItemMap.get(palict.aliId)!=null?agreementRelatedLineItemMap.get(palict.aliId):new List<Id>();
                                                                                                tempId.add(balict.aliId);
                                                                                                agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                            }
                                                                                    }
                                                                            }
                                                                     
                                                                        } 
                                                                    else if(parentProducts.keySet().contains(i) && buyingGroupProducts.keySet().contains(i)&&grandParentProducts.keySet().contains(i))
                                                                        {   
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                            {
                                                                                for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                    {
                                                                                        for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                            {
                                                                                                for(APTS_CERUtility.AgreementLineItemChargeType calict:childProducts.get(i))
                                                                                                    {
                                                                                                        if(palict.aliChargeType==balict.aliChargeType && palict.aliChargeType==galict.aliChargeType&& palict.aliChargeType==calict.aliChargeType )
                                                                                                            {
                                                                                                                tempId =agreementRelatedLineItemMap.get(calict.aliId)!=null?agreementRelatedLineItemMap.get(calict.aliId):new List<Id>();
                                                                                                                tempId.add(balict.aliId);
                                                                                                                tempId.add(galict.aliId);
                                                                                                                tempId.add(palict.aliId);
                                                                                                                agreementRelatedLineItemMap.put(calict.aliId,tempId);

                                                                                                            }
                                                                                                    }
                                                                                                
                                                                                            }
                                                                                        
                                                                                    }
                                                                            }


                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                        {
                                                                                            for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                                {
                                                                                                    if(palict.aliChargeType==balict.aliChargeType && palict.aliChargeType==galict.aliChargeType)
                                                                                                        {
                                                                                                            tempId =agreementRelatedLineItemMap.get(palict.aliId)!=null?agreementRelatedLineItemMap.get(palict.aliId):new List<Id>();
                                                                                                            tempId.add(balict.aliId);
                                                                                                            tempId.add(galict.aliId);
                                                                                                            agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                                        }
                                                                                                }
                                                                                            
                                                                                        }
                                                                                }
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                        {
                                                                                            if(balict.aliChargeType==galict.aliChargeType)
                                                                                                {
                                                                                                    tempId =agreementRelatedLineItemMap.get(galict.aliId)!=null?agreementRelatedLineItemMap.get(galict.aliId):new List<Id>();
                                                                                                    tempId.add(balict.aliId);
                                                                                                    agreementRelatedLineItemMap.put(galict.aliId,tempId);

                                                                                                }
                                                                                        }
                                                                                }

                                                                        }              
                                                                    else continue;    
                                                                }
                                                            for(Id i:parentProducts.keySet())
                                                                {
                                                                    if(grandParentProducts.keySet().contains(i) && !(childProducts.keySet().contains(i)) && !(buyingGroupProducts.keySet().contains(i)))
                                                                        {   
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                        {
                                                                                            if(palict.aliChargeType==galict.aliChargeType)
                                                                                                {
                                                                                                    tempId =agreementRelatedLineItemMap.get(palict.aliId)!=null?agreementRelatedLineItemMap.get(palict.aliId):new List<Id>();
                                                                                                    tempId.add(galict.aliId);
                                                                                                    agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                                }
                                                                                        }
                                                                                }
                                                                        }
                                                                    else if(buyingGroupProducts.keySet().contains(i) && !(childProducts.keySet().contains(i)) && !(grandParentProducts.keySet().contains(i)))
                                                                        {
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                        {
                                                                                            if(balict.aliChargeType==palict.aliChargeType)
                                                                                                {
                                                                                                    tempId =agreementRelatedLineItemMap.get(palict.aliId)!=null?agreementRelatedLineItemMap.get(palict.aliId):new List<Id>();
                                                                                                    tempId.add(balict.aliId);
                                                                                                    agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                                }
                                                                                        }
                                                                                }
                                                                        }  
                                                                    else if(buyingGroupProducts.keySet().contains(i) && grandParentProducts.keySet().contains(i) && !(childProducts.keySet().contains(i)) )
                                                                        {
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                        {
                                                                                            for(APTS_CERUtility.AgreementLineItemChargeType palict:parentProducts.get(i))
                                                                                                {
                                                                                                    if(palict.aliChargeType==balict.aliChargeType && palict.aliChargeType==galict.aliChargeType)
                                                                                                        {
                                                                                                            tempId =agreementRelatedLineItemMap.get(palict.aliId)!=null?agreementRelatedLineItemMap.get(palict.aliId):new List<Id>();
                                                                                                            tempId.add(balict.aliId);
                                                                                                            tempId.add(galict.aliId);
                                                                                                            agreementRelatedLineItemMap.put(palict.aliId,tempId);

                                                                                                        }
                                                                                                }
                                                                                            
                                                                                        }
                                                                                }
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                        {
                                                                                            if(balict.aliChargeType==galict.aliChargeType)
                                                                                                {
                                                                                                    tempId =agreementRelatedLineItemMap.get(galict.aliId)!=null?agreementRelatedLineItemMap.get(galict.aliId):new List<Id>();
                                                                                                    tempId.add(balict.aliId);
                                                                                                    agreementRelatedLineItemMap.put(galict.aliId,tempId);

                                                                                                }
                                                                                        }
                                                                                }
                                                                        }       
                                                                    else continue;    
                                                                } 
                                                            for(Id i:grandParentProducts.keySet())
                                                                {
                                                                    if(buyingGroupProducts.keySet().contains(i) && !(parentProducts.keySet().contains(i)) && !(childProducts.keySet().contains(i)))
                                                                        {   
                                                                            for(APTS_CERUtility.AgreementLineItemChargeType balict:buyingGroupProducts.get(i))
                                                                                {
                                                                                    for(APTS_CERUtility.AgreementLineItemChargeType galict:grandParentProducts.get(i))
                                                                                        {
                                                                                            if(balict.aliChargeType==galict.aliChargeType)
                                                                                                {
                                                                                                    tempId =agreementRelatedLineItemMap.get(galict.aliId)!=null?agreementRelatedLineItemMap.get(galict.aliId):new List<Id>();
                                                                                                    tempId.add(balict.aliId);
                                                                                                    agreementRelatedLineItemMap.put(galict.aliId,tempId);

                                                                                                }
                                                                                        }
                                                                                }
                                                                           
                                                                        }
                                                                    else continue;    
                                                                }       
                                                        }       
                                                    else continue;  
                                                }
                                        }
                                }
                        }
                }
            return agreementRelatedLineItemMap;
        }

    ///Added by venky
    // Get the Map of adjustment line item that need to exclude    
    public static Map<Id,Set<Id>> excludedItemsFromAgreements(Map<Id,Map<Id,List<Id>>> toBeExcluded )
        {
            Map<Id,Set<Id>> returnObject =new Map<Id,Set<Id>>();
            /*if(toBeExcluded==null)
                {
                    return returnObject;
                }*/

            if(toBeExcluded.size() == 0)
                {
                    return returnObject;
                }

            Map<ID,APTS_CERUtility.AgreementAdjustmentLineItem> tempadjustmentLineItemMap=new Map<ID,APTS_CERUtility.AgreementAdjustmentLineItem>();
            //Map<ID,String> tempChargeTypeMap=new Map<ID,String>(); Commented by Venky
            Map<ID,String> childAdjustmentLineItemMap=new Map<ID,String>();
            Map<ID,String> parentAdjustmentLineItemMap=new Map<ID,String>();
            Map<Id,Map<ID,APTS_CERUtility.AgreementAdjustmentLineItem>> adjustmentLineItemMap =new Map<Id,Map<ID,APTS_CERUtility.AgreementAdjustmentLineItem>>();
            Set<Id> excludedAdjustmentLineItems =new Set<Id>();
            List<Id> agreementLineItemList =new List<Id>();
            Map<Id,List<Id>> agreementRelatedLineItemMap =new Map<Id,List<Id>>();
            APTS_CERUtility.AgreementAdjustmentLineItem tempAALI=new APTS_CERUtility.AgreementAdjustmentLineItem();
            APTS_CERUtility.AgreementAdjustmentLineItem childAALI=new APTS_CERUtility.AgreementAdjustmentLineItem();
            APTS_CERUtility.AgreementAdjustmentLineItem parentAALI=new APTS_CERUtility.AgreementAdjustmentLineItem();
            for (Id tbe:toBeExcluded.keySet())
                {
                    agreementRelatedLineItemMap=toBeExcluded.get(tbe);
                   
                    agreementLineItemList.addAll(agreementRelatedLineItemMap.keySet());
                    for (Id ar :agreementRelatedLineItemMap.keySet())
                        {
                            agreementLineItemList.addAll(agreementRelatedLineItemMap.get(ar));
                        }
                }
              
            if(agreementLineItemList.size()>0)
                {
                    for(Apttus_CMConfig__AgreementAdjustmentLineItem__c aali: [select id,Apttus_CMConfig__Type__c,Apttus_CMConfig__SubType__c,Apttus_CMConfig__LineItemId__c,Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__ChargeType__c from Apttus_CMConfig__AgreementAdjustmentLineItem__c where Apttus_CMConfig__LineItemId__c in:agreementLineItemList])
                        {   
                            tempadjustmentLineItemMap=adjustmentLineItemMap.get(aali.Apttus_CMConfig__LineItemId__c)!=null?adjustmentLineItemMap.get(aali.Apttus_CMConfig__LineItemId__c): new Map<ID,APTS_CERUtility.AgreementAdjustmentLineItem>();  
                            tempAALI=new APTS_CERUtility.AgreementAdjustmentLineItem();
                            tempAALI.aaliType=aali.Apttus_CMConfig__Type__c;
                            tempAALI.aaliSubType=aali.Apttus_CMConfig__SubType__c;
                            tempadjustmentLineItemMap.put(aali.id,tempAALI);
                            //tempChargeTypeMap.put(aali.id,aali.Apttus_CMConfig__LineItemId__r.Apttus_CMConfig__ChargeType__c);  Commented by Venky
                            adjustmentLineItemMap.put(aali.Apttus_CMConfig__LineItemId__c,tempadjustmentLineItemMap);
                        } 
                } 
                for (Id tbe:toBeExcluded.keySet())
                {
                    agreementRelatedLineItemMap=toBeExcluded.get(tbe);
                    excludedAdjustmentLineItems=new Set<Id>();
                    for(Id i:agreementRelatedLineItemMap.keySet())
                        {
                            if(adjustmentLineItemMap.get(i)!=null)
                                {
                                    for(Id childId:adjustmentLineItemMap.get(i).keySet())
                                        {
                                            childAALI=adjustmentLineItemMap.get(i).get(childId);
                                            for (Id tempId:agreementRelatedLineItemMap.get(i))
                                                {
                                                    for(Id parentId:adjustmentLineItemMap.get(tempId).keySet())
                                                        {
                                                            //if((adjustmentLineItemMap.get(i).get(childId)==adjustmentLineItemMap.get(tempId).get(parentId)) && (tempChargeTypeMap.get(childId)==tempChargeTypeMap.get(parentId)) )  Commented by Venky
                                                            parentAALI=adjustmentLineItemMap.get(tempId).get(parentId);
                                                            if((childAALI.aaliType==parentAALI.aaliType)&&(childAALI.aaliSubType==parentAALI.aaliSubType))   
                                                                {
                                                                    if(!excludedAdjustmentLineItems.contains(parentId))
                                                                        {
                                                                             excludedAdjustmentLineItems.add(parentId);
                                                                        }
                                                                       
                                                                }   
                                                        }
                                                }
                                        }
                                }        
                        }
                    returnObject.put(tbe,excludedAdjustmentLineItems);    
                }
            return returnObject;     
        }

}