@RestResource(urlMapping='/GetPrice/*')
global with sharing class Test_GetPrice  {

  

    @HttpPost
    global static List<GetPriceWrapper> doPost(Id soldToId,List<Id> productIdList,Integer limitValue,Integer offsetValue) {
        return APTS_CERUtility.getPrice(soldToId,productIdList,limitValue,offsetValue);
    }
    global class GetPriceWrapper
        {
            public Id  productId;
            public Decimal price;
            
        } 
    

}